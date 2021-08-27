--[[-------------------------------------------------------------------------
	Веб загрузчик IGS 13.03.2021
	https://blog.amd-nick.me/github-workshop-garrysmod/
	Изначально эта задача представлялась в 3 строки
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
	print("IGS Logging " .. (enable and "enabled" or "disabled"))
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

		local content  = IGS_MOUNT[sAbsolutePath]
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

	if IGS_MOUNT and IGS_MOUNT[sAbsolutePath] then -- 1st check for lua load (not web)
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
	return IGS_MOUNT and findKeys(IGS_MOUNT, patt) or {}
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

function IGS.load_entities()
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


concommand.Add("igs_flushversion", function(pl)
	if IsValid(pl) then print("console only") return end
	cookie.Set("igs_version", nil)
	print("OK. После перезагрузки сервер скачает новую версию")
end)

-- мб ему место в launcher?
local igs_version = CreateConVar("igs_version", "", {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

if SERVER and igs_version:GetString() == "" then
	local version = cookie.GetString("igs_version")
	igs_version:SetString(version or "777") -- "or" for case when igsmod isn't ran (core hosted locally)
end

IGS.sh("igs/launcher.lua")
IGS.load_entities()
