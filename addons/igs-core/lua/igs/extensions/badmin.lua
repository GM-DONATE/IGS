local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetBAdminGroup(usergroup, weight)
	local rankId = ba.ranks.Get(usergroup):GetID()
	self:SetInstaller(function(pl)
		pl:SetNetVar("UserGroup", rankId)
		pl.IGSBAdminWeight = weight
	end)
	self:SetValidator(function(pl)
		if pl.IGSBAdminWeight then
			return weight < pl.IGSBAdminWeight
		else
			return pl:GetNetVar("UserGroup") == rankId
		end
	end)
	return self
end
