--[[-------------------------------------------------------------------------
	Веб загрузчик IGS 13.03.2021, _AMD_ (c)
	Кода мало, писался долго и здесь еще многому предстоит измениться

	Изначально эта задача представлялась в 3 строки,
		но в проекте до начала реализации накопилось несколько десятков нюансов,
		которые четырежды в корне изменяли подход к реализации

	Когда-нибудь возможно я даже расскажу в блоге несколько моментов
---------------------------------------------------------------------------]]

IGS = IGS or {}

local function log(s)
	if VERBOSE then
		print("[IGS] " .. s)
	end
end

local i = {} -- lua files only
i.sv = SERVER and include or function() end
i.cl = SERVER and AddCSLuaFile or include
i.sh = function(f) return i.cl(f) or i.sv(f) end


local function include_mount(sRealm, sAbsolutePath)
	if (sRealm == "sh")
	or (sRealm == "sv" and SERVER)
	or (sRealm == "cl" and CLIENT) then
		local content  = IGS.CODEMOUNT[sAbsolutePath]
		local executer = CompileString(content, sAbsolutePath)
		return executer()
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
		log(string.format("%s Иклюд с MOUNT. Путь: %s", sRealm, sAbsolutePath))
		return include_mount(sRealm, sAbsolutePath)
	else
		log(string.format("%s Иклюд с LUA. Путь: %s", sRealm, sAbsolutePath))
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
	local entities = findInMount("^entities/([^/]*)/(.*%.lua)$")
	entities = unique(entities)

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
	http.Fetch(url, cb, function(err)
		for i = 1,10 do print("\n\nIGS Не может выполнить HTTP запрос и загрузить скрипт\nURL: " .. url .."\nError: " .. err) end
	end)
end

-- Здесь также определяется версия
local function findSuperfileUrl(cb, version_)
	wrapFetch("https://api.github.com/repos/GM-DONATE/IGS/releases", function(json)
		local t = util.JSONToTable(json)
		version_ = version_ or t[1].tag_name -- or latest

		local found
		for _,release in ipairs(t) do
			if release.tag_name == version_ then
				found = release
				break
			end
		end

		if not found then
			print("IGS Не может найти релизную версию для скачивания")
			return
		end

		for _,asset in ipairs(found.assets) do
			if asset.name == "superfile.txt" then
				local superfile_url = asset.browser_download_url
				cb(superfile_url, version_) -- https://pastebin.com/raw/XHx8PQNL
				return
			end
		end

		print("IGS Не может найти superfile в дополнениях к релизу")
	end)
end




local function downloadAndRunCode(url)
	wrapFetch(url, function(content)
		IGS.CODEMOUNT = parseSuperfile(content)

		IGS.sh("igs/launcher.lua")
		loadEntities()

		if CLIENT then -- костыль, но другого способа не вижу
			hook.GetTable()["InitPostEntity"]["IGS.nw.InitPostEntity"]()
			hook.GetTable()["DarkRPFinishedLoading"]["SupressDarkRPF1"]()
		end
	end)
end

local function loadFromWeb()
	findSuperfileUrl(function(url, ver)
		-- local url, ver = "https://pastebin.com/raw/EYw95gsp", "200125"
		IGS.CODEURL = url
		IGS.Version = ver
		downloadAndRunCode(url)
	end, IGS_FORCE_VERSION)
end



if file.Exists("igs/launcher.lua", "LUA") then
	print("IGS Загружаемся с lua")
	IGS.Version = "666"
	IGS.sh("igs/launcher.lua")
	return
end


-- нет смысла на проде перескачивать сервер.
-- Это наоборот может привести к разным версиям CL и SV
-- убрать \/ если /\ станет проблемой
-- if IGS.CODEMOUNT then return end

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




