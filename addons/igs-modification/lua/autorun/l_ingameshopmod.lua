if file.Exists("igs/launcher.lua", "LUA") and not IGS_FORCE_WEB then return end

-- Вы можете сделать форк основного репозитория, сделать там изменения и указать его имя здесь
-- Таким образом IGS будет грузиться у всех с вашего репозитория
-- IGS_REPO = "AMD-NICK/IGS-1"

timer.Simple(0, function()
	local test = CompileString("Test_CS = true", "IGS_Test_CS")
	if test then test() end
	if not Test_CS then print("[IGSmod] CompileString doesn't work") end
	Test_CS = nil


	local blob = IGS_FORCE_VERSION or "main"
	local repo = IGS_REPO or "GM-DONATE/IGS"
	http.Fetch("https://raw.githubusercontent.com/" .. repo .. "/" .. blob ..
		"/addons/igs-core/lua/autorun/l_ingameshop.lua", function(body)
			local executor = CompileString(body, "igsloader")
			if executor then
				executor()
			else
				print("[IGSmod] Shit Happens. Body is not a valid code")
				MsgN(body)
			end
	end, function(err)
		timer.Create("IGSFail", 5, 10, function()
			MsgN("[IGSmod] Ошибка скачивания IGS. Нет интернета или соединение сброшено хостом")
		end)
	end)
end)
