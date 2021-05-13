--[[-------------------------------------------------------------------------
	Веб загрузчик IGS 13.03.2021, _AMD_ (c)
	Кода мало, писался долго и здесь еще многому предстоит измениться

	Изначально эта задача представлялась в 3 строки,
		но в проекте до начала реализации накопилось несколько десятков нюансов,
		которые четырежды в корне изменяли подход к реализации

	Когда-нибудь возможно я даже расскажу в блоге несколько моментов
---------------------------------------------------------------------------]]

IGS = IGS or {}

local function log(patt, ...)
	if cookie.GetNumber("igsverbose", 0) == 1 then
		print(string.format("[IGS] " .. patt, ...))
	end
end

concommand.Add("igsverbose", function(pl)
	if SERVER and IsValid(pl) then return end

	local enable = cookie.GetNumber("igsverbose", 0) == 0
	cookie.Set("igsverbose", enable and 1 or 0)
	print("IGS Logging now is " .. (enable and "on" or "off"))
end)

local i = {} -- lua files only
i.sv = SERVER and include or function() end
i.cl = SERVER and AddCSLuaFile or include
i.sh = function(f) return i.cl(f) or i.sv(f) end


local function include_mount(sRealm, sAbsolutePath)
	if (sRealm == "sh")
	or (sRealm == "sv" and SERVER)
	or (sRealm == "cl" and CLIENT) then
		-- Чистый RunString не воспринимает return внутри файлов
		-- Но CompileString 9 апреля 2021 теоретически был причиной ошибок
		-- Пока пусть будет RunString без ретурна
		-- Заметки: https://t.me/c/1353676159/55852

		-- local executer = CompileString(content, sAbsolutePath)
		-- return executer()

		local content  = IGS.CODEMOUNT[sAbsolutePath]
		RunString(content, sAbsolutePath)
	end
end

-- "Костыль" для работы IGS.sh/sv/cl изнутри модульных _main.lua файлов и энтити
-- с указанием относительного пути
-- не работает с ../file (наверн. Не чекал)
local iam_inside

local function incl(sRealm, sPath)
	-- Не сработает, если например в лаунчере в sh() для файлов убрать приставку "igs/"
	local isRelativePath = iam_inside and not sPath:StartWith(iam_inside)
	local sAbsolutePath  = isRelativePath and iam_inside .. "/" .. sPath or sPath
	-- /\ Мб внутри модуля уже указан full путь, а не относительный
	-- (обычно путь к _main.lua)

	-- print(sAbsolutePath)

	if IGS.CODEMOUNT and IGS.CODEMOUNT[sAbsolutePath] then -- 1st check for lua load (not web)
		log("%s Иклюд с MOUNT. Путь: %s", sRealm, sAbsolutePath)
		return include_mount(sRealm, sAbsolutePath)
	else
		log("%s Иклюд с LUA. Путь: %s", sRealm, sAbsolutePath)
		local fIncluder = i[sRealm]
		return fIncluder(sAbsolutePath)
	end
end

function IGS.sh(sPath) return incl("sh", sPath) end
function IGS.sv(sPath) return incl("sv", sPath) end
function IGS.cl(sPath) return incl("cl", sPath) end

local function findKeys(arr, patt)
	local found = {}
	for key,val in pairs(arr) do
		local match = key:match(patt)
		if match then
			table.insert(found, match)
		end
	end
	return found
end

-- Тяжелая, но пока в оптимизации не нуждается
-- При выборке модулей и энтити элементы повторяются
local function unique(arr)
	local ret = {}
	for _,v in ipairs(arr) do
		if not table.HasValue(ret, v) then
			table.insert(ret, v)
		end
	end
	return ret
end

local function findInMount(patt)
	return IGS.CODEMOUNT and findKeys(IGS.CODEMOUNT, patt) or {}
end

function IGS.include_files(sPath, fIncluder) -- igs/extensions
	local data_files = findInMount("^" .. sPath:PatternSafe() .. "/(.*%.lua)$")
	local lua_files  = file.Find(sPath .. "/*.lua","LUA")
	table.Add(data_files, lua_files)

	for _,fileName in ipairs(data_files) do
		fIncluder(sPath .. "/" .. fileName)
	end
end

function IGS.load_modules(sBasePath) -- igs/modules
	local data_modules  = findInMount("^" .. sBasePath .. "/([^/]*)/_main%.lua$")
	data_modules = unique(data_modules)
	local _,lua_modules = file.Find(sBasePath .. "/*","LUA")
	table.Add(data_modules, lua_modules)

	for _,mod in ipairs(data_modules) do
		local sModPath = sBasePath .. "/" .. mod
		iam_inside = sModPath
		IGS.sh(sModPath .. "/_main.lua") -- igs/modules/inv_log/_main.lua
	end
	iam_inside = nil
end

local function parseSuperfile(content)
	local lines = string.Split(content, "\n")
	local index = {}
	for _,line in ipairs(lines) do
		local sPath,code = line:match("^(.-) (.*)$")
		if sPath then -- !last_line
			index[sPath] = code
		end
	end
	return index
end

local function loadEntities()
	log("Загрузка энтити")
	local entities = findInMount("^entities/([^/]*)/(.*%.lua)$")
	entities = unique(entities) -- {ent_igs, npc_igs}

	for _,ent_class in ipairs(entities) do
		iam_inside = "entities/" .. ent_class
		ENT = {}
		ENT.Folder = iam_inside

		if SERVER then IGS.sv("init.lua")
		else IGS.cl("cl_init.lua") end
		scripted_ents.Register(ENT, ent_class)

		iam_inside = nil
		ENT = nil
	end
end

local function wrapFetch(url, cb)
	log("fetch(%s)", url)
	http.Fetch(url, cb, function(err)
		for i = 1,10 do print("\n\nIGS Не может выполнить HTTP запрос и загрузить скрипт\nURL: " .. url .."\nError: " .. err) end
	end)
end

-- local function findMajorFresher(releases, ver) end
-- local function findFresherAtAll(releases) end

local function filter(arr, f)
	local t = {}
	for _,v in ipairs(arr) do
		if f(v) then t[#t + 1] = v end
	end
	return t
end

-- #todo вынести check updates в другое место и не заниматься этим здесь
-- это говнит и без того запашной код
local function findSuperfileUrl(cb, major_version_)
	log("Ищем ссылку для скачивания %s", major_version_ or "последней версии")
	local repo = IGS_REPO or "GM-DONATE/IGS"
	wrapFetch("https://api.github.com/repos/" .. repo .. "/releases", function(json)
		local releases = util.JSONToTable(json)

		local releases_copy = table.Copy(releases) -- свежайшие версии сначала
		table.sort(releases_copy, function(a, b)
			return tonumber(a.tag_name) > tonumber(b.tag_name)
		end)

		local suitable = major_version_ and filter(releases_copy, function(release)
			return math.floor(release.tag_name) == math.floor(major_version_) -- 12345.6 >> 12345
		end) or {}

		-- среди той что форсим (если форсим)
		local freshest_suitable = suitable[1]
		local freshest_version  = releases_copy[1]
		log("suitable ver %s", freshest_suitable and freshest_suitable.tag_name)
		log("freshest ver %s", freshest_version  and freshest_version.tag_name)


		if major_version_ and not freshest_suitable then
			print("IGS Не можем найти " .. major_version_ .. " версию для скачивания")
			return
		end

		if not freshest_version then
			print("IGS Не может найти релизную версию для скачивания")
			return
		end

		local found = major_version_ and freshest_suitable or freshest_version
		for _,asset in ipairs(found.assets) do
			if asset.name == "superfile.txt" then
				local superfile_url = asset.browser_download_url
				log("Нашли версию %s. Ссылка: %s", found.tag_name, superfile_url)
				cb(superfile_url, found, freshest_version)
				return
			end
		end

		print("IGS Не может найти superfile в дополнениях к релизу")
	end)
end


local function runAfterhooks()
	if IGS.HOOKSFIRED then return end

	log("Выполнение 'опоздавших' хуков и spawnmenu_reload")
	if CLIENT then -- костыль, но другого способа не вижу
		hook.GetTable()["InitPostEntity"]["IGS.nw.InitPostEntity"]()
		hook.GetTable()["DarkRPFinishedLoading"]["SupressDarkRPF1"]()
		RunConsoleCommand("spawnmenu_reload") -- npc_igs
	else
		-- hook.GetTable()["InitPostEntity"]["IGS.PermaSents"]()
		-- "InitPostEntity", "InitializePermaProps"
	end

	IGS.HOOKSFIRED = true
end

local function downloadAndRunCode(url)
	wrapFetch(url, function(content, _, _, http_code)
		if http_code ~= 200 then
			print("IGS Версия удалена с GitHub или проблема доступа")
			return
		end

		IGS.CODEMOUNT = parseSuperfile(content)
		IGS.sh("igs/launcher.lua")
		loadEntities()

		runAfterhooks()
	end)
end

local function announceNewVersion(new_version)
	timer.Create("igs_new_version_announce", 10, 5, function()
		local repo = IGS_REPO or "GM-DONATE/IGS"
		local info_url = "https://github.com/" .. repo .. "/releases/tag/" .. math.floor(new_version)
		print("IGS Доступна новая версия: " .. new_version .. "\nИнформация здесь: " .. info_url)
	end)
end

local function loadFromWeb() -- #todo да убрать бля отсюда проверку обновлений
	findSuperfileUrl(function(url, found, freshest_version)
		local ver = found.tag_name
		cookie.Set("igsversion", ver)
		-- local url, ver = "https://pastebin.com/raw/EYw95gsp", "200125"
		IGS.CODEURL = url
		IGS.Version = ver
		downloadAndRunCode(url)

		local has_updates = tonumber(freshest_version.tag_name) > tonumber(found.tag_name)
		if has_updates then
			announceNewVersion(freshest_version.tag_name)
		end
	end, IGS_FORCE_VERSION or cookie.GetString("igsversion"))
end

concommand.Add("igsflushversion", function(pl)
	if IsValid(pl) then print("console only") return end
	cookie.Set("igsversion", nil)
	print("OK. После перезагрузки сервер скачает новую версию")
end)



if file.Exists("igs/launcher.lua", "LUA") and not IGS_FORCE_WEB then
	print("IGS Загружаемся с lua")
	IGS.Version = "666"
	IGS.sh("igs/launcher.lua")
	return
end



if SERVER then
	timer.Simple(0, loadFromWeb)

	-- #todo сделать, чтобы сервер в цикле пытался скачать IGS и только потом отправлял инфу
	util.AddNetworkString("IGS.PlayerReady")
	net.Receive("IGS.PlayerReady", function(_, pl) -- ping
		assert(IGS.CODEMOUNT, "IGS. Клиент загрузился раньше сервера?")
		net.Start("IGS.PlayerReady") -- pong
			net.WriteString(IGS.Version)
			net.WriteString(IGS.CODEURL)
		net.Send(pl)
	end)
else
	hook.Add("Think", "IGS.PlayerReady", function()
		hook.Remove("Think", "IGS.PlayerReady")

		net.Start("IGS.PlayerReady")
		net.SendToServer()

		net.Receive("IGS.PlayerReady", function()
			IGS.Version = net.ReadString()
			IGS.CODEURL = net.ReadString()
			downloadAndRunCode(IGS.CODEURL)
		end)
	end)
end




