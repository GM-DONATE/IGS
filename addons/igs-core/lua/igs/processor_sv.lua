-- #FUSC# --

local function giveLvlBonuses(pl, from_lvl, to_lvl)
	for i = from_lvl,to_lvl do
		local lvl = IGS.LVL.Get(i)

		if lvl.bonus then
			lvl.bonus(pl)
		end

		IGS.NotifyAll(pl:Name() .. " получил новый (" .. i .. ") бизнес уровень - " .. lvl:Name())
	end
end

local function recalcTransactionsAndBonuses(pl, bGiveBonuses)
	-- Сумма операций
	IGS.GetPlayerTransactionsBypassingLimit(function(dat)
		local tt = 0
		for _,v in ipairs(dat) do
			tt = v.Sum > 0 and tt + v.Sum or tt
		end

		local prev_lvl = IGS.PlayerLVL(pl) or 0 -- не двигать под igs_lvl!
		pl:SetIGSVar("igs_lvl",IGS.LVL.GetByCost( tt ):LVL())
		pl:SetIGSVar("igs_total_transactions",tt)

		if bGiveBonuses and IGS.PlayerLVL(pl) > prev_lvl then
			giveLvlBonuses(pl, prev_lvl + 1, IGS.PlayerLVL(pl))
		end
	end, pl:SteamID64())
end


-- Указать bGiveBonuses, если нужно пересчитать бонусы
local function updateBalance(pl, fOnFinish, bGiveBonuses)
	IGS.GetPlayer(pl:SteamID64(),function(pld_)
		if not IsValid(pl) then return end
		local now_igs_ = pld_ and pld_.Balance
		local now_score_ = pld_ and pld_.Score

		local was_igs = pl:IGSFunds()
		local diff = (now_igs_ or 0) - was_igs

		if diff ~= 0 then -- баланс ~= nil и не 0 (? https://t.me/c/1353676159/45001)
			pl:SetIGSVar("igs_balance", now_igs_) -- НЕ ДОЛЖНО ВЫПОЛНЯТЬСЯ НА НЕ_КЛИЕНТОВ
			pl.igs_score = now_score_ -- #todo make netvar
		end

		if now_igs_ then -- значит есть транзакции
			recalcTransactionsAndBonuses(pl, bGiveBonuses)
		end

		if fOnFinish then
			fOnFinish(now_igs_, diff)
		end
	end)
end


hook.Add("PlayerInitialSpawn", "IGS.LoadPlayer", function(pl)
	if pl:IsBot() then return end

	-- Устанавливаем баланс донат счета и донат уровень игрока
	updateBalance(pl, function(now_igs_)
		if (not IsValid(pl)) then return end

		IGS.LoadPlayerPurchases(pl)
		IGS.LoadInventory(pl)

		if now_igs_ and now_igs_ > 0 then
			IGS.UpdatePlayerName(pl:SteamID64(), pl:Name())
		end
	end)
end)

local function repairBrokenPurchases(pl,purchases)
	for uid in pairs(purchases) do -- , count
		local ITEM = IGS.GetItemByUID(uid)

		if ITEM:IsValid(pl) == false then
			ITEM:Setup(pl) -- не первый раз, скипаем onactivate
		end
	end
end

-- Восстановление слетевших прав
hook.Add("IGS.PlayerPurchasesLoaded", "RestorePex", function(pl,purchases)
	if purchases then
		repairBrokenPurchases(pl, purchases)
	end
end)


-- Отладка начисления бонусов за лвл:
-- https://gist.github.com/1b41e1f869752d4750440619339e4085
hook.Add("IGS.PaymentStatusUpdated","NoRejoiningCharge",function(pl,dat)
	if dat.method ~= "pay" then return end

	--timer.Simple(1,function() -- даем успеть в БД обновить данные

		updateBalance(pl,function(new_bal, diff)
			hook.Run("IGS.PlayerDonate", pl, diff, new_bal)
		end, true) -- updateBalance with bGiveBonuses

	--end) -- timer 1
end)
