IGS.ITEMS.XADMIN_USERS = IGS.ITEMS.XADMIN_USERS or {} -- by kip https://t.me/c/1353676159/1673

local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetXAdminGroup(sUserGroup)
	return self:SetInstaller(function(pl)
		xAdmin.UserGroups[pl:SteamID()] = sUserGroup
		pl:SetUserGroup(sUserGroup)
		IGS.ITEMS.XADMIN_USERS[pl:SteamID()] = true
	end):SetValidator(function()
		return false
	end)
end

hook.Add("PlayerDisconnected", "IGS.XAdminRemovePerm", function(pl)
	if IGS.ITEMS.XADMIN_USERS[pl:SteamID()] then
		xAdmin.UserGroups[pl:SteamID()] = nil
		IGS.ITEMS.XADMIN_USERS[pl:SteamID()] = nil
	end
end)
