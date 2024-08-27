local function isMounted(path)
	return file.Exists(path, "LUA")
end

local function isWorkshopped(path)
	return file.Exists("lua/" .. path, "WORKSHOP")
end

local function isDownloaded(path)
	return IGS_MOUNT and IGS_MOUNT[path]
end



local function isUnpacked(path)
	return isMounted(path) and not (isWorkshopped(path) or isDownloaded(path))
end

hook.Add("IGS.Initialized", "installation_check", function()
	local path = "igs/launcher.lua"
	if isUnpacked(path) then
		IGS.print(IGS.GetPhrase("isunpacked"))
	end

	if isWorkshopped(path) and isDownloaded(path) then
		IGS.print(IGS.GetPhrase("isworkshop"))
	end
end)


-- PRINT(file.Find("*", "LUA")) -- mediaplayer, wire
-- PRINT(file.Find("lua/*", "THIRDPARTY")) -- mediaplayer, wire


-- print(isUnpacked("wire/wireshared.lua"))
