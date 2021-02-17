-- Кто-то использует FAdmin, как отдельный аддон к другим гейммодам? О_о

local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetFAdminGroup(sGroup, iWeight)
	return self:SetInstaller(function(pl)
		FAdmin.Access.PlayerSetGroup(pl, sGroup)
		pl.IGSFAdminWeight = iWeight
	end):SetValidator(function(pl)
		if pl.IGSFAdminWeight then
			return iWeight < pl.IGSFAdminWeight
		end

		return pl:IsUserGroup(sGroup)
	end)
end
