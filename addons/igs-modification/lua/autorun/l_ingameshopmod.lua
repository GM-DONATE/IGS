if file.Exists("igs/launcher.lua","LUA") then return end

timer.Simple(0, function()
	local blob = IGS_FORCE_VERSION or "main"
	http.Fetch("https://raw.githubusercontent.com/GM-DONATE/IGS/" .. blob ..
		"/addons/igs-core/lua/autorun/l_ingameshop.lua", function(body)
			CompileString(body, "igsloader")()
	end, function(err)
		timer.Create("IGSFail", 5, 10, function()
			MsgN("[IGS] Ошибка скачивания IGS. Нет интернета или соединение сброшено хостом")
		end)
	end)
end)
