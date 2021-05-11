local function isMounted(path)
	return file.Exists(path, "LUA")
end

local function isWorkshopped(path)
	return file.Exists("lua/" .. path, "WORKSHOP")
end

local function isDownloaded(path)
	return IGS.CODEMOUNT and IGS.CODEMOUNT[path]
end



local function isUnpacked(path)
	return isMounted(path) and not (isWorkshopped(path) or isDownloaded(path))
end

hook.Add("IGS.Initialized", "installation_check", function()
	local path = "igs/launcher.lua"
	if isUnpacked(path) then
		IGS.print("Похоже, что автодонат распакован в /addons. Автоматические обновления недоступны")
	end

	if isWorkshopped(path) and isDownloaded(path) then
		IGS.print("Удалите автодонат из вашей коллекции в воркшопе. Обновления работают через GitHub")
	end
end)


-- PRINT(file.Find("*", "LUA")) -- mediaplayer, wire
-- PRINT(file.Find("lua/*", "THIRDPARTY")) -- mediaplayer, wire


-- print(isUnpacked("wire/wireshared.lua"))
