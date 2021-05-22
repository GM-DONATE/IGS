if file.Exists("igs/launcher.lua", "LUA") and not IGS_FORCE_WEB then return end

-- Вы можете сделать форк основного репозитория, сделать там изменения и указать его имя здесь
-- Таким образом IGS будет грузиться у всех с вашего репозитория
-- IGS_REPO = "AMD-NICK/IGS-1"


file.CreateDir("igs")
local igs_version = CreateConVar("igs_version", "", {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

local function checkRunString()
	RunString("IGS_Test_RS = true", "IGS_Test_RS")
	assert(IGS_Test_RS, "[IGSmod] RunString doesn't work")
	IGS_Test_RS = nil
end

checkRunString()



local function wrapFetch(url, cb)
	local patt = "IGS Не может выполнить HTTP запрос и загрузить скрипт\nURL: %s\nError: %s\n"
	timer.Simple(0, function()
		http.Fetch(url, cb, function(err)
			for i = 1,10 do print(patt:format(url, err)) end
		end)
	end)
end

local function getSuperfileUrl(version)
	local ver  = cookie.GetString("igsversion")
	local repo = IGS_REPO or "GM-DONATE/IGS"
	local url  = "https://github.com/" .. repo .. "/releases/" .. ver .. "/download/superfile.txt"
	return url
end

local function downloadSuperfile(version, cb)
	local url = getSuperfileUrl(version)
	wrapFetch(url, function(superfile)
		file.Write("igs/superfile.txt", superfile)
		cb(superfile)
	end)
end

local function loadFromFile(superfile)
	checkRunString()

	if SERVER then
		local version = cookie.GetString("igsversion")
		igs_version:SetString(version)
	end

	local path  = "autorun/l_ingameshop.lua"
	IGS_MOUNT = util.JSONToTable(superfile)
	RunString(IGS_MOUNT[path], path)
end

local function findFreshestVersion(cb)
	local repo = IGS_REPO or "GM-DONATE/IGS"
	wrapFetch("https://api.github.com/repos/" .. repo .. "/releases", function(json)
		local releases = util.JSONToTable(json)
		table.sort(releases, function(a, b) -- свежайшие версии сначала
			return tonumber(a.tag_name) > tonumber(b.tag_name)
		end)

		local freshest_version = releases[1]
		assert(freshest_version, "Релизов нет. Нужно запустить CI")

		cb(freshest_version.tag_name)
	end)
end

if SERVER then
	local superfile = file.Read("igs/superfile.txt")
	local version   = cookie.GetString("igsversion")

	if superfile and version then -- 2 может не быть, если сервер перенесли без sv.db
		loadFromFile(superfile)

	elseif not version then
		findFreshestVersion(function(freshest_version)
			cookie.Set("igsversion", freshest_version)
			downloadSuperfile(freshest_version, loadFromFile)
		end)

	else -- version
		downloadSuperfile(version, loadFromFile)
	end

elseif CLIENT then
	local version = igs_version:GetString()
	downloadSuperfile(version, loadFromFile)
end
