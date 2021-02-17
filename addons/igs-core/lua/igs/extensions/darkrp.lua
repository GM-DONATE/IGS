IGS.ITEMS.DRP = IGS.ITEMS.DRP or {
	ITEMS = {},
	JOBS  = {}
}


local STORE_ITEM = FindMetaTable("IGSItem")

-- Делает итем в магазине покупаемым только за донат
-- Это может быть ящик оружия, отдельная пушка или даже отдельная энтити
function STORE_ITEM:SetDarkRPItem(sEntClass)
	self.dpr_item = self:Insert(IGS.ITEMS.DRP.ITEMS, sEntClass)
	return self
end

-- Доступ к профессиям только тем, кто ее покупал
function STORE_ITEM:SetDarkRPTeams(...)
	-- https://trello.com/c/xxGiGpb2/319-улучшить-setdarkrpteam
	local tTeams = {...}
	for i,team in ipairs(tTeams) do
		if isnumber(team) then -- обратная совместимость (20.03.2019)
			local TEAM = RPExtraTeams[team]
			self:Insert(IGS.ITEMS.DRP.JOBS, TEAM.command)
			tTeams[i] = TEAM.command -- заменяем ENUM на cmd для ITEM.dpr_teams
		else -- строка (team.command) https://trello.com/c/BcbYbAb7/512
			self:Insert(IGS.ITEMS.DRP.JOBS, team)
		end
	end
	self.dpr_teams = tTeams
	return self
end
STORE_ITEM.SetDarkRPTeam = STORE_ITEM.SetDarkRPTeams -- обратная совместимость (20.03.2019)

function STORE_ITEM:SetDarkRPMoney(iSum)
	self:SetDescription("Мгновенно и без проблем пополняет баланс игровой валюты на " .. string.Comma(iSum) .. " валюты")
	self:SetInstaller(function(pl) pl:addMoney(iSum,"IGS") end)
	self:SetStackable()

	self.dpr_money = iSum
	return self
end

hook.Add("canBuyShipment", "IGS", function(pl, tItem)
	local ITEM = IGS.PlayerHasOneOf(pl, IGS.ITEMS.DRP.ITEMS[tItem.entity])
	if ITEM ~= nil then -- донатный итем
		local allow, message = hook.Run("IGS.canBuyShipment", pl, tItem)
		return allow or tobool(ITEM), false, message or "Это для донатеров (/donate)"
	end
end)

hook.Add("canBuyPistol", "IGS", function(pl, tItem)
	local ITEM = IGS.PlayerHasOneOf(pl, IGS.ITEMS.DRP.ITEMS[tItem.entity])
	if ITEM ~= nil then -- донатный итем
		local allow, message = hook.Run("IGS.canBuyPistol", pl, tItem)
		return allow or tobool(ITEM), false, message or "Это для донатеров (/donate)"
	end
end)

-- в DarkRP.hooks нет такого
-- https://img.qweqwe.ovh/1528097550183.png
hook.Add("canBuyCustomEntity", "IGS", function(pl, tItem)
	local ITEM = IGS.PlayerHasOneOf(pl, IGS.ITEMS.DRP.ITEMS[tItem.ent])
	if ITEM ~= nil then -- донатный итем
		local allow, message = hook.Run("IGS.canBuyCustomEntity", pl, tItem)
		return allow or tobool(ITEM), false, message or "Это для донатеров (/donate)"
	end
end)

-- нет suppress
-- print(IGS.PlayerHasOneOf(AMD(), IGS.ITEMS.DRP.JOBS[TEAM_LOCK]))
hook.Add("playerCanChangeTeam", "IGS", function(pl, iTeam, bForce)
	local TEAM = RPExtraTeams[iTeam]
	local ITEM = IGS.PlayerHasOneOf(pl, IGS.ITEMS.DRP.JOBS[TEAM.command])
	if ITEM ~= nil then -- донатный итем
		local allow, message = hook.Run("IGS.playerCanChangeTeam", pl, iTeam, bForce)
		return allow or tobool(ITEM), message or "Это для донатеров (/donate)"
	end
end)
