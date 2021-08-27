IGS.BADMIN_GROUPS = IGS.BADMIN_GROUPS or {}

local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetBAdminGroup(rank, rank_priority)
	local rankId = ba.ranks.Get(rank):GetID()
	IGS.BADMIN_GROUPS[rankId] = rank_priority or 0

	self:SetInstaller(function(pl)
		pl:SetNetVar("UserGroup", rankId)
	end)
	self:SetValidator(function(pl)
		local current_rank     = pl:GetNetVar("UserGroup")
		local current_priority = IGS.BADMIN_GROUPS[current_rank]
		if not current_priority then return end -- ранга игрока нет в продаже. Не сбрасываем

		return current_priority >= rank_priority -- меняем, если вес текущей меньше, чем новой
	end)
	return self
end
