if file.Exists("igs/launcher.lua", "LUA") and not IGS_FORCE_WEB then return end

-- Вы можете сделать форк основного репозитория, сделать там изменения и указать его имя здесь
-- Таким образом IGS будет грузиться у всех с вашего репозитория
-- IGS_REPO = "AMD-NICK/IGS-1"

local IGS_START_LOADING = 0

timer.Simple(0, function()
	IGS_START_LOADING = SysTime()

	RunString("Test_RS = true", "IGS_Test_RS")
	if not Test_RS then print("[IGSmod] RunString doesn't work") end
	Test_RS = nil

	local blob = cookie.GetString("igsversion") or "main"
	local repo = IGS_REPO or "GM-DONATE/IGS"
	http.Fetch("https://raw.githubusercontent.com/" .. repo .. "/" .. blob ..
		"/addons/igs-core/lua/autorun/l_ingameshop.lua", function(body)
			local _, err = RunString(body, "igsloader")
			if err then
				print("[IGSmod] Shit Happens. Body is not a valid code")
				print("[IGSmod] Error:", err)
				MsgN(body)
			end
	end, function(err)
		timer.Create("IGSFail", 5, 10, function()
			MsgN("[IGSmod] Ошибка скачивания IGS. Нет интернета или соединение сброшено хостом")
		end)
	end)
end)

-- Для определения ошибки
-- This should never happen - datapack file entry has no data!
-- https://t.me/c/1353676159/55836
hook.Add("IGS.Initialized", "IGS.MeasureLoadingTime", function()
	print("[IGSmod] От скачивания до загрузки IGS прошло " .. (SysTime() - IGS_START_LOADING) .. " сек")
	hook.Remove("IGS.Initialized", "IGS.MeasureLoadingTime")
end)
