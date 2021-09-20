file.CreateDir("igs")

-- Вы можете сделать форк основного репозитория, сделать там изменения и указать его имя здесь
-- Таким образом IGS будет грузиться у всех с вашего репозитория
IGS_REPO = "GM-DONATE/IGS" -- "AMD-NICK/IGS-1"
if not IGS_REPO or file.Exists("autorun/l_ingameshop.lua", "LUA") then return end -- force lua


local function checkRunString()
	RunString("IGS_Test_RS = true", "IGS_Test_RS")
	assert(IGS_Test_RS, "[IGSmod] RunString doesn't work")
	IGS_Test_RS = nil
end

checkRunString() -- сразу может быть, а потом пропасть



local function wrapFetch(url, cb)
	local patt = "IGS Не может выполнить HTTP запрос и загрузить скрипт\nURL: %s\nError: %s\n"
	timer.Simple(0, function()
		http.Fetch(url, cb, function(err)
			error(patt:format(url, err))
		end)
	end)
end

local function downloadSuperfile(version, cb)
	local url = "https://github.com/" .. IGS_REPO .. "/releases/download/" .. version .. "/superfile.json"
	wrapFetch(url, function(superfile)
		file.Write("igs/superfile.txt", superfile)
		cb(superfile)
	end)
end

local function loadFromFile(superfile)
	checkRunString()

	local path = "autorun/l_ingameshop.lua"
	IGS_MOUNT  = util.JSONToTable(superfile)

	local err_msg = SERVER and
			"Ошибка загрузки superfile. Удалите /data/superfile.txt и попробуйте снова или обратитесь в gm-donate.ru/support"
		or 	"Ошибка загрузки superfile. Перезайдите на сервер " ..                    "или обратитесь в gm-donate.ru/support"

	assert(IGS_MOUNT and IGS_MOUNT[path], err_msg)
	RunString(IGS_MOUNT[path], path)
end

local function findFreshestVersion(cb)
	wrapFetch("https://api.github.com/repos/" .. IGS_REPO .. "/releases", function(json)
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
	local version   = cookie.GetString("igs_version")

	if superfile and version then -- 2 может не быть, если сервер перенесли без sv.db
		loadFromFile(superfile)

	elseif not version then
		findFreshestVersion(function(freshest_version)
			cookie.Set("igs_version", freshest_version)
			downloadSuperfile(freshest_version, loadFromFile)
		end)

	else -- version
		downloadSuperfile(version, loadFromFile)
	end

elseif CLIENT then
	CreateConVar("igs_version", "", {FCVAR_REPLICATED})
	local version = GetConVarString("igs_version")
	assert(tonumber(version), "cvar igs_version не передался клиенту. " .. tostring(version))
	downloadSuperfile(version, loadFromFile)
end