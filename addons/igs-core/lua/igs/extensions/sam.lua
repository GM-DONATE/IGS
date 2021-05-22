IGS.ITEMS.SAM = IGS.ITEMS.SAM or {
	GROUPS = {}
}

local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetSAMGroup(sUserGroup, iGroupWeight)
	self:SetCategory("SAM (Админка)")

	self:SetCanActivate(function(pl) -- global, invDbID
		if pl:IsUserGroup(sUserGroup) then
			return "У вас уже действует эта услуга"
		end
	end)
	self:SetInstaller(function(pl)
		pl:sam_set_rank(sUserGroup)
	end)
	self:SetValidator(function(pl)
		if pl.IGSSAMWeight then
			return iGroupWeight < pl.IGSSAMWeight
		else
			return  pl:GetUserGroup() == sUserGroup
		end
	end)


	self.sg_group = self:Insert(IGS.ITEMS.SAM.GROUPS, sUserGroup)
	return self
end

if CLIENT then return end

local function checkGroups(pl)
	local hasAccess = IGS.PlayerHasOneOf(pl, IGS.ITEMS.SAM.GROUPS[ pl:GetUserGroup() ])
	if hasAccess == nil then return end  -- не отслеживается

	if hasAccess then
		return -- если имеется хоть одна покупка, то не снимаем права
	end

	pl:sam_set_rank("user")
end

hook.Add("IGS.PlayerPurchasesLoaded", "SAMGroups", function(pl)
	if next(IGS.ITEMS.SAM.GROUPS) then -- группы продаются
		checkGroups(pl)
	end
end)
