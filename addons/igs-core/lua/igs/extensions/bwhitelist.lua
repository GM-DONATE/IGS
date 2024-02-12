IGS.ITEMS.Whitelist = IGS.ITEMS.Whitelist or {}

local STORE_ITEM = MT_IGSItem

local function team_id(team_cmd)
	return DarkRP.getJobByCommand(team_cmd).team
end

function STORE_ITEM:SetBWhitelist(team_cmd)
	self:SetCanActivate(function(pl)
		if GAS.JobWhitelist:IsWhitelisted(pl, team_id(team_cmd)) then
			return "Вы в вайтлисте"
		end
	end)
	self:SetInstaller(function(pl)
		GAS.JobWhitelist:AddToWhitelist(team_id(team_cmd), GAS.JobWhitelist.LIST_TYPE_STEAMID, pl:SteamID())
	end)
	self:SetValidator(function(pl)
		return GAS.JobWhitelist:IsWhitelisted(pl, team_id(team_cmd))
	end)

	self.whitelist = self:Insert(IGS.ITEMS.Whitelist, team_cmd) -- not team_id из-за DarkRP = nil на этом этапе
	return self
end

if SERVER then
	hook.Add("IGS.PlayerPurchasesLoaded", "IGS.bWhitelist", function(pl)
		for team_cmd,_ in pairs(IGS.ITEMS.Whitelist) do
			GAS.JobWhitelist:RemoveFromWhitelist(team_id(team_cmd), GAS.JobWhitelist.LIST_TYPE_STEAMID, pl:SteamID())
		end
	end)
end
