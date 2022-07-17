local STORE_ITEM = FindMetaTable("IGSItem")

local is_on_sale_ranks = {}

function STORE_ITEM:SetSGGroup(sUserGroup)
	is_on_sale_ranks[sUserGroup] = true

	return self:SetInstaller(function(pl)
		local rankData = serverguard.ranks:GetRank(sUserGroup)
		assert(rankData, "IGS: В SetSGGroup указана несуществующая группа")
		serverguard.player:SetRank(pl, sUserGroup, 0)
		serverguard.player:SetImmunity(pl, rankData.immunity)
		serverguard.player:SetTargetableRank(pl, rankData.targetable)
		serverguard.player:SetBanLimit(pl, rankData.banlimit)
	end):SetMeta("sggroup", sUserGroup)
end

if CLIENT then return end

-- addhook не подойдет (не будет автоснятия. Можно и отдельно, конечно)
hook.Add("IGS.PlayerPurchasesLoaded", "sggroup", function(pl, purchases)
	if not serverguard then hook.Remove("IGS.PlayerPurchasesLoaded", "sggroup") return end
	if hook.Run("IGS.SkipSGRestore", pl) then return end

	local prior

	for uid in pairs(purchases or {}) do
		local ITEM = IGS.GetItemByUID(uid)
		if ITEM:GetMeta("sggroup") and (not prior or ITEM.id >= prior.id) then
			prior = ITEM
		end
	end

	if prior then
		prior:Setup(pl)
	else -- ни один не куплен (срок истек?)
		local player_rank = serverguard.player:GetRank(pl) -- default: user
		if is_on_sale_ranks[player_rank] then -- но ранг, который у игрока продается
			serverguard.player:SetRank(pl, "user", 0) -- снимаем
		end
	end
end)
