local ITEM = MT_IGSItem

function ITEM:SetEvolveRank(rank)
	return self:SetInstaller(function(pl)
		evolve.PlayerInfo[pl:UniqueID()]["Rank"] = rank
	end):SetValidator(function(pl)
		return evolve.PlayerInfo[pl:UniqueID()]["Rank"] == rank
	end):SetMeta("ev_rank", rank)
end
