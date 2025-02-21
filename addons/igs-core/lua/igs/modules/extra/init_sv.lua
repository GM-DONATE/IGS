--[[-------------------------------------------------------------------------
	Чат команды
---------------------------------------------------------------------------]]
scc.add("igs", IGS.UI)
for command in pairs(IGS.C.COMMANDS or {}) do
	scc.add(command, IGS.UI)
end

--[[-------------------------------------------------------------------------
	Консольная команда igs_info
---------------------------------------------------------------------------]]
local print_info = function()
	local info = {
		server_id = bib.get("igs:serverid"),
		server_ip = game.GetIPAddress(),
		igs_version = cookie.GetString("igs_version") or "unset",
		is_unpacked = file.Exists("igs/apinator.lua", "LUA"),
		-- log_tail = (file.Read("igs_errors.txt") or ""):sub(-1000)
	}
	local luainf do
		local inf = debug.getinfo(IGS.GetSign)
		luainf = {
			line_def = inf.linedefined,
			source = inf.source,
			short_src = inf.short_src,
		}
	end
	info.funcinfo = luainf
	print("\n\n" .. util.TableToJSON(info, true) .. "\n\n")

	print("Log Tail:")
	local log_lines = (file.Read("igs_errors.txt") or ""):Split("\n")
	for i = #log_lines - 100, #log_lines do
		print(i, log_lines[i])
	end
end
-- print_info()
concommand.Add("igs_info", function(pl)
	if IsValid(pl) and not pl:IsSuperAdmin() then return end
	print_info()
end)

--[[-------------------------------------------------------------------------
	Консольная команда начисления денег
---------------------------------------------------------------------------]]
concommand.Add("addfunds", function(pl, _, _, argss)
	if IsValid(pl) then
		IGS.prints(Color(240, 173, 78), "", pl:Nick(),  " пытался выполнить ", ("addfunds " .. argss),  " через игровую консоль")
		-- IGS.Notify(pl, "Команда работает только с серверной консоли")
		return
	end

	local sid, amount, note = argss:match("(STEAM_%d:%d:%d+) (%d+) ?(.*)")
	amount = tonumber(amount)
	if note == "" then note = nil end

	if not amount then
		IGS.prints("Формат команды нарушен. Пример:\n", "addfunds STEAM_0:1:2345678 10 Необязательное примечание")
		return
	end

	local targ = player.GetBySteamID(sid)
	if targ then
		targ:AddIGSFunds(amount, note, function()
			IGS.prints("Транзакция успешно проведена. ", "Баланс игрока: " .. PL_MONEY( targ:IGSFunds() ))
		end)

	-- Игрок оффлайн
	else
		IGS.Transaction(util.SteamIDTo64(sid), amount, note, function()
			IGS.prints("Транзакция успешно проведена, но игрок не на сервере")
		end)

	end
end)


concommand.Add("igs_reload", function(pl, _, args)
	if pl == NULL then -- console only
		IGS.prints(args[1] and "Super Reload" or "Casual Reload")
		IGS.sh(args[1] and "autorun/l_ingameshop.lua" or "igs/launcher.lua")
	end
end)


--[[-------------------------------------------------------------------------
	Открытие интерфейса кнопкой на клаве
---------------------------------------------------------------------------]]
-- https://wiki.facepunch.com/gmod/Enums/KEY
hook.Add("PlayerButtonDown", "IGS.UI", function(pl, iButton)
	if iButton == IGS.C.MENUBUTTON then
		scc.run(pl, "igs")
	end
end)


--[[-------------------------------------------------------------------------
	Глобальное оповещение о покупке итемов
	https://trello.com/c/SvZ8UE0F/472-сообщение-о-покупке
---------------------------------------------------------------------------]]
hook.Add("IGS.PlayerPurchasedItem", "IGS.BroadcastPurchase", function(pl, ITEM)
	if IGS.C.BroadcastPurchase == false then return end -- TODO сделать модулем

	IGS.NotifyAll(pl:Nick() .. " купил " .. ITEM:Name())
end)


--[[-------------------------------------------------------------------------
	Оповещение о пополнении счета
	https://trello.com/c/6rMMH3cn/483-сообщение-о-пополнении-счета
---------------------------------------------------------------------------]]

hook.Add("IGS.PlayerDonate", "ThanksForDonate", function(pl, rub)
	local score = pl.igs_score -- TODO: make netvar

	IGS.Notify(pl, Format("Спасибо вам за пополнение счета. " ..
		"Ваш новый Score на всех проектах - %d. " ..
		"Что такое Score: vk.cc/caHTZi", score))

	local rub_str  = PL_MONEY(rub)
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
	IGS.prints("Поиск обновлений")
	if not IGS_REPO then return end
	http.Fetch("https://api.github.com/repos/" .. IGS_REPO .. "/releases", function(json)
		local releases = util.JSONToTable(json)
		assert(releases[1], "Релизов нет. Нужно запустить CI") -- форк

		table.sort(releases, function(a, b)
			return tonumber(a.tag_name) > tonumber(b.tag_name)
		end)

		local current_ver    = cookie.GetNumber("igs_version") or 0 -- or 0 для постоянных напоминаний про обнову, если локальная установка
		local freshest_major = math.floor(releases[1].tag_name)
		local current_major  = math.floor(current_ver)

		if freshest_major > current_major then
			local info_url = "https://github.com/" .. IGS_REPO .. "/releases/tag/" .. freshest_major
			IGS.prints("🆕 Доступна новая Major версия: ", freshest_major, ". Установлена: ", (current_major == 0 and "распакованная 🚨" or current_major), "\nИнформация про обновление здесь: ", info_url)
			if current_major == 0 then
				IGS.prints("Для автообновления в addons должен быть только ", "igs-modification")
			end
		else
			IGS.prints("Major обновлений нет")
		end

		local freshest_suitable -- "123.2"
		for _, release in ipairs(releases) do -- от свежайших
			if current_ver == tonumber(release.tag_name) then break end -- 123.1 current and 123.1 suitable
			if math.floor(release.tag_name) == current_major then -- (123).1 == (123).2
				freshest_suitable = release.tag_name
				break
			end
		end

		if freshest_suitable then
			IGS.prints("🆕 Найдено новое soft обновление. Текущая версия: ", current_ver, ", новая: ", freshest_suitable)
			local url = "https://github.com/" .. IGS_REPO .. "/releases/download/" .. freshest_suitable .. "/superfile.json"
			http.Fetch(url, function(superfile)
				IGS.prints(Color(100, 250, 100), "", "Обновление загружено! ", "Перезагрузите сервер для применения")
				file.Write("igs/superfile.txt", superfile)
				cookie.Set("igs_version", freshest_suitable)
			end, error)
		else
			IGS.prints("Soft обновлений нет")
		end
	end, error)
end)
