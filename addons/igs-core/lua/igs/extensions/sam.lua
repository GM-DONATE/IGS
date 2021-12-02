local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetSAMGroup(sUserGroup)
	return self:SetInstaller(function(pl)
		pl:sam_set_rank(sUserGroup)
	end):AddHook("IGS.PlayerPurchasesLoaded", function(pl, purchases) -- #TODO упростить хук. badmin использует тот же
		if CLIENT or not purchases then return end

		local priority_item = self

		for uid in pairs(purchases) do
			local ITEM = IGS.GetItemByUID(uid)
			if ITEM:GetMeta("samgroup") and ITEM.id > self.id then
				priority_item = ITEM
			end
		end

		if priority_item == self then
			self:Setup(pl)
			self.igs_active_sam_item = self
		end
	end):SetMeta("samgroup", sUserGroup)
end

hook.Add("PlayerDisconnected", "IGS_SAM", function(pl)
	if pl.igs_active_sam_item then
		pl:sam_set_rank("user")
	end
end)
