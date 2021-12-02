local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetBAdminGroup(rank)
	return self:SetInstaller(function(pl)
		pl:SetNetVar("UserGroup", ba.ranks.Get(rank):GetID())
	end):AddHook("IGS.PlayerPurchasesLoaded", function(pl, purchases) -- #TODO упростить хук. sam использует тот же
		if CLIENT or not purchases then return end

		local priority_item = self

		for uid in pairs(purchases) do
			local ITEM = IGS.GetItemByUID(uid)
			if ITEM:GetMeta("bagroup") and ITEM.id > self.id then
				priority_item = ITEM
			end
		end

		if priority_item == self then
			self:Setup(pl)

		end
	end):SetMeta("bagroup", sUserGroup)
end
