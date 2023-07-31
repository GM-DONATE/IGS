local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetBAdminGroup(rank)
	return self:SetInstaller(function(pl)
		assert(rank, "IGS Rank expected, got " .. type(rank))
		local RANK = assert(ba.ranks.Get(rank), "IGS Rank " .. rank .. " invalid")
		pl:SetNetVar("UserGroup", RANK:GetID())
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
	end):SetMeta("bagroup", rank)
end
