IGS.ITEMS.SG = IGS.ITEMS.SG or {
	GROUPS = {}
}

local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetSGGroup(sUserGroup, iGroupWeight)
	self:SetCanActivate(function(pl)
		if pl:IsUserGroup(sUserGroup) then
			return "У вас уже действует эта услуга"
		end
	end)
	self:SetInstaller(function(pl)
		local rankData = serverguard.ranks:GetRank(sUserGroup)
		if rankData then
			serverguard.player:SetRank(pl, sUserGroup, 0)
			serverguard.player:SetImmunity(pl, rankData.immunity)
			serverguard.player:SetTargetableRank(pl, rankData.targetable)
			serverguard.player:SetBanLimit(pl, rankData.banlimit)
			pl.IGSSGWeight = iGroupWeight
		end
	end)
	self:SetValidator(function(pl)
		if pl.IGSSGWeight then
			return iGroupWeight < pl.IGSSGWeight
		else
			return serverguard.player:GetRank(pl) == sUserGroup
		end
	end)

	self.sg_group = self:Insert(IGS.ITEMS.SG.GROUPS, sUserGroup)
	return self
end
if CLIENT then return end
local function checkGroups(pl)
	local hasAccess = IGS.PlayerHasOneOf(pl, IGS.ITEMS.SG.GROUPS[ serverguard.player:GetRank(pl) ])
	if hasAccess == nil then return end  -- не отслеживается

	if hasAccess then
		return -- если имеется хоть одна покупка, то не снимаем права
	end

	serverguard.player:SetRank(pl, "user", 0);
end

hook.Add("IGS.PlayerPurchasesLoaded", "SGGroups", function(pl)
	if next(IGS.ITEMS.SG.GROUPS) then -- группы продаются
		checkGroups(pl)
	end
end)
