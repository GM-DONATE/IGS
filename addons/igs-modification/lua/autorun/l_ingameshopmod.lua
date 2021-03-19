if file.Exists("igs/launcher.lua","LUA") then return end

-- IGS_REPO = "AMD-NICK/IGS-1"
-- IGS_FORCE_WEB = true

timer.Simple(0, function()
	local blob = IGS_FORCE_VERSION or "main"
	local repo = IGS_REPO or "GM-DONATE/IGS"
	http.Fetch("https://raw.githubusercontent.com/" .. repo .. "/" .. blob ..
		"/addons/igs-core/lua/autorun/l_ingameshop.lua", function(body)
			CompileString(body, "igsloader")()
	end, function(err)
		timer.Create("IGSFail", 5, 10, function()
			MsgN("[IGS] Ошибка скачивания IGS. Нет интернета или соединение сброшено хостом")
		end)
	end)
end)
