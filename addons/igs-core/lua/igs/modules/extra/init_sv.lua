--[[-------------------------------------------------------------------------
	Чат команды
---------------------------------------------------------------------------]]
scc.add("igs", IGS.UI)
for command in pairs(IGS.C.COMMANDS or {}) do
	scc.add(command, IGS.UI)
end




--[[-------------------------------------------------------------------------
	Консольная команда начисления денег
---------------------------------------------------------------------------]]
local n = function(pl, msg)
	if IsValid(pl) then
		IGS.Notify(pl,msg)
	else
		print(msg)
	end
end

concommand.Add("addfunds",function(pl,_,_,argss)
	if IsValid(pl) then
		IGS.print(Color(240, 173, 78), pl:Nick() .. " пытался выполнить addfunds " .. argss .. " через игровую консоль")
		n(pl, "Команда работает только с серверной консоли")
		return
	end

	local _,endpos, sid,amount = argss:find("^(STEAM_%d:%d:%d+) (%d+)")

	if not endpos then
		return n(pl,"Формат команды нарушен\nПример: addfunds STEAM_0:1:2345678 10 А вот это отметка транзакции")
	end

	-- Мы ведь в валюте счет должны пополнить, а не рублях
	amount = IGS.PriceInCurrency(amount)
	local note = argss:sub(endpos + 2)

	local targ = player.GetBySteamID(sid)
	if targ then
		targ:AddIGSFunds(amount,note,function()
			n(pl,"Транзакция успешно проведена. Баланс игрока: " .. PL_IGS(targ:IGSFunds()))
		end)

	-- Игрок оффлайн
	else
		IGS.Transaction(util.SteamIDTo64(sid),amount,note,function()
			n(pl,"Транзакция успешно проведена, но игрок не на сервере")
		end)

	end
end)


concommand.Add("igs_reload", function(pl, _, args)
	if pl == NULL then -- console only
		print(args[1]  and "Super Reload" or "Casual Reload")
		IGS.sh(args[1] and "autorun/l_ingameshop.lua" or "igs/launcher.lua")
	end
end)


--[[-------------------------------------------------------------------------
	Открытие интерфейса кнопкой на клаве
---------------------------------------------------------------------------]]
-- https://wiki.facepunch.com/gmod/Enums/KEY
hook.Add("PlayerButtonDown","IGS.UI",function(pl, iButton)
	if iButton == IGS.C.MENUBUTTON then
		scc.run(pl, "igs")
	end
end)


--[[-------------------------------------------------------------------------
	Глобальное оповещение о покупке итемов
	https://trello.com/c/SvZ8UE0F/472-сообщение-о-покупке
---------------------------------------------------------------------------]]
hook.Add("IGS.PlayerPurchasedItem","IGS.BroadcastPurchase",function(pl, ITEM)
	if IGS.C.BroadcastPurchase == false then return end -- #todo сделать модулем

	IGS.NotifyAll(pl:Nick() .. " купил " .. ITEM:Name())  --  .. " за " .. PL_MONEY(ITEM:Price())
end)


--[[-------------------------------------------------------------------------
	Оповещение о пополнении счета
	https://trello.com/c/6rMMH3cn/483-сообщение-о-пополнении-счета
---------------------------------------------------------------------------]]

hook.Add("IGS.PlayerDonate", "ThanksForDonate", function(pl, sum_igs)
	local score = pl.igs_score -- #todo make netvar

	IGS.Notify(pl, Format("Спасибо вам за пополнение счета. " ..
		"Ваш новый Score на всех проектах - %d. " ..
		"Что такое Score: vk.cc/caHTZi", score))

	local rub = IGS.RealPrice(sum_igs)

	local rub_str = PL_MONEY(rub)
	local full_str = Format("%s пополнил счет на %s. Его новый Score: %s", pl:Nick(), rub_str, score)

	IGS.NotifyAll(full_str)
end)

hook.Add("IGS.PlayerPurchasesLoaded", "BalanceRemember", function(pl)
	local balance = pl:IGSFunds()
	if balance >= 10 then
		timer.Simple(10, function()
			if not IsValid(pl) then return end
			IGS.Notify(pl, "Вы можете потратить " .. IGS.SignPrice(balance) .. " через /donate")
			IGS.Notify(pl, "Ваш Score " .. (pl.igs_score or 0) .. ". Подробнее: vk.cc/caHTZi") -- or 0 на всякий случай
		end)
	end
end)




--[[-------------------------------------------------------------------------
	Поиск новых версий
---------------------------------------------------------------------------]]
timer.Simple(1, function() -- http.Fetch
	print("IGS Поиск обновлений")
	if not IGS_REPO then return end
	http.Fetch("https://api.github.com/repos/" .. IGS_REPO .. "/releases", function(json)
		local releases = util.JSONToTable(json)
		assert(releases[1], "Релизов нет. Нужно запустить CI") -- форк

		table.sort(releases, function(a, b)
			return tonumber(a.tag_name) > tonumber(b.tag_name)
		end)

		local current_tag      = GetConVarString("igs_version")
		local freshest_version = math.floor(releases[1].tag_name)
		local current_version  = math.floor(current_tag)

		if freshest_version > current_version then
			local info_url = "https://github.com/" .. IGS_REPO .. "/releases/tag/" .. math.floor(freshest_version)
			print("IGS Доступна новая версия: " .. freshest_version .. ". Установлена: " .. current_version .. "\nИнформация здесь: " .. info_url)
		else
			print("IGS Major обновлений нет")
		end

		local freshest_suitable
		for _,release in ipairs(releases) do -- от свежайших
			if current_tag == release.tag_name then break end -- 123.1 current and 123.1 suitable
			if math.floor(release.tag_name) == current_version then
				freshest_suitable = release.tag_name
				break
			end
		end

		if freshest_suitable then
			print("IGS Найдено новое soft обновление. Текущая версия, новая:", current_tag, freshest_suitable)
			local url = "https://github.com/" .. IGS_REPO .. "/releases/download/" .. freshest_suitable .. "/superfile.json"
			http.Fetch(url, function(superfile)
				print("IGS Обновление загружено. Перезагрузите сервер для применения")
				file.Write("igs/superfile.txt", superfile)
				cookie.Set("igs_version", freshest_suitable)
			end, error)
		else
			print("IGS  Soft обновлений нет")
		end
	end, error)
end)
