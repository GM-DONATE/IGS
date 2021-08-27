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


-- Есть xAdmin.SetGroup(pl, sUserGroup)
-- но тогда будет сложнее контроллировать снятие прав, тк идет запись в БД
function STORE_ITEM:SetXAdmin2Group(sUserGroup)
	return self:SetInstaller(function(pl)
		local sid64 = pl:SteamID64()
		local oldgroup = pl:GetUserGroup()

		xAdmin.UserData[sid64] = xAdmin.UserData[sid64] or {SteamID = sid64}
		xAdmin.UserData[sid64].UserGroup = sUserGroup

		pl:SetUserGroup(sUserGroup)

		xAdmin.UpdateGroupMembers(player.GetAll(), sUserGroup)

		hook.Run("xAdminUserGroupUpdated", pl, sUserGroup, oldgroup)
	end):AddHook("IGS.PlayerPurchasesLoaded", function(pl, purchases)
		if CLIENT or not purchases then return end

		local priority_item = self

		for uid in pairs(purchases) do
			local ITEM = IGS.GetItemByUID(uid)
			if ITEM:GetMeta("badmin2group") and ITEM.id > self.id then
				priority_item = ITEM
			end
		end

		if priority_item == self then
			self:Setup(pl)
		end
	end):SetMeta("badmin2group", sUserGroup)
end
