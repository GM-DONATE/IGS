IGS = IGS or {}
IGS.FILEHASHES = IGS.FILEHASHES or {}

IGS.Version = 200125 -- #TODO версия должна получаться и устанавливаться в самом главном файле (фетча этого с гита)






--[[-------------------------------------------------------------------------
	Часть которая ниже должна быть в главном fetch файле
---------------------------------------------------------------------------]]

local i = {} -- lua files only
i.sv = SERVER and include or function() end
i.cl = SERVER and AddCSLuaFile or include
i.sh = function(f) return i.cl(f) or i.sv(f) end

local function contentIsSafe(content, true_crc)
	local crc = util.CRC(content)
	return crc == true_crc
end

local function include_data(sRealm, sPath)
	local path_in_data = "igs/" .. IGS.Version .. "/" .. sPath:StripExtension() .. ".txt"

	if (sRealm == "sh")
	or (sRealm == "sv" and SERVER)
	or (sRealm == "cl" and CLIENT) then
		print(string.format("%s Иклюд с DATA. Путь: %s", sRealm, path_in_data))
		local content  = file.Read(path_in_data, "DATA")
		local true_crc = IGS.FILEHASHES[sPath]
		local error_txt = "IGS Хеш файла " .. path_in_data .. " не соответствует требованиям"
		assert(SERVER or contentIsSafe(content, true_crc), error_txt)

		local executer = CompileString(content, path_in_data)
		return executer()
	end
end

-- "Костыль" для работы IGS.sh/sv/cl изнутри модульных _main.lua файлов
-- с указанием относительного пути
-- не работает с ../file (наверн. Не чекал)
local iam_inside

local function incl(sRealm, sPath)
	-- Не сработает, если например в лаунчере в sh() для файлов убрать приставку "igs/"
	local isRelativePath = iam_inside and not sPath:StartWith(iam_inside)

	-- Мб внутри модуля уже указан full путь, а не относительный
	-- (обычно путь к _main.lua)
	if isRelativePath then
		sPath = iam_inside .. "/" .. sPath
	end

	local path_in_data = "igs/" .. IGS.Version .. "/" .. sPath:StripExtension() .. ".txt"

	if file.Exists(sPath, "LUA") then
		print(string.format("%s Иклюд с LUA. Путь: %s", sRealm, sPath))
		local fIncluder = i[sRealm]
		return fIncluder(sPath)
	elseif file.Exists(path_in_data, "DATA") then
		return include_data(sRealm, sPath)
	else
		print(string.format("IGS: Файл%s не найден. Путь: %s", iam_inside and (" внутри " .. iam_inside) or "", sPath))
	end
end

function IGS.sh(sPath) return incl("sh", sPath) end
function IGS.sv(sPath) return incl("sv", sPath) end
function IGS.cl(sPath) return incl("cl", sPath) end

function IGS.include_files(sPath, fIncluder) -- igs/extensions
	local data_files = file.Find("igs/" .. IGS.Version .. "/" .. sPath .. "/*.txt","DATA")
	local lua_files  = file.Find(sPath .. "/*.lua","LUA")
	table.Add(data_files, lua_files)

	for _,fileName in ipairs(data_files) do
		fIncluder(sPath .. "/" .. fileName)
	end
end

function IGS.load_modules(sBasePath) -- igs/modules
	local _,data_modules = file.Find("igs/" .. IGS.Version .. "/" .. sBasePath .. "/*","DATA")
	local _,lua_modules  = file.Find(sBasePath .. "/*","LUA")
	table.Add(data_modules, lua_modules)

	for _,mod in ipairs(data_modules) do
		local sModPath = sBasePath .. "/" .. mod
		iam_inside = sModPath
		IGS.sh(sModPath .. "/_main.lua")
	end
	iam_inside = nil
end


local function file_ForceWrite(path, content)
	file.CreateDir(path:match("(.+)/"))
	file.Write(path, content)
end

local function unpackSuperfile(content, extract_to)
	local lines = string.Split(content, "\n")

	for _,line in ipairs(lines) do
		local path,code = line:match("^(.-) (.*)$")
		if path then -- !last_line
			file_ForceWrite(extract_to .. "/" .. path, code)
		end
	end
end



local function wrapFetch(url, cb)
	http.Fetch(url, cb, function(err)
		for i = 1,10 do print("\n\nIGS Не может выполнить HTTP запрос и загрузить скрипт\nURL: " .. url .."\nError: " .. err) end
	end)
end

local function downloadAndRunSuperfile(url)
	wrapFetch(url, function(code_lines)
		unpackSuperfile(code_lines, "igs/" .. IGS.Version .. "/igs")
		IGS.sh("igs/launcher.lua")
	end)
end

local function findSuperfileUrl(cb)
	if true then
		cb("https://pastebin.com/raw/UvwGMfAZ")
		return
	end

	wrapFetch("https://api.github.com/repos/wiremod/advdupe2/releases", function(json)
		local t = util.JSONToTable(json)
		IGS.Version = IGS.Version or t[1].tag_name

		local found
		for _,release in ipairs(t) do
			if release.tag_name == IGS.Version then
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
				cb(superfile_url)
				return
			end
		end

		print("IGS Не может найти superfile в дополнениях к релизу")
	end)
end

if file.Exists("igs/launcher.lua", "LUA") then
	print("IGS Загружаемся с lua")
	IGS.sh("igs/launcher.lua")
	return
end

-- else
timer.Simple(0, function()
	findSuperfileUrl(downloadAndRunSuperfile)
end)

-- if SERVER then
-- 	util.AddNetworkString("IGS.FILEHASHES")

-- 	local function net_WriteHashes()
-- 		net.WriteUInt(table.Count(IGS.FILEHASHES), 16)
-- 		for sPath,crc in pairs(IGS.FILEHASHES) do
-- 			net.WriteString(sPath)
-- 			net.WriteUInt(crc, 32)
-- 		end
-- 	end

-- 	local function calcHashes()
-- 	end

-- 	net.Receive("IGS.FILEHASHES", function(_, pl)
-- 		net.Start("IGS.FILEHASHES")
-- 		if next(IGS.FILEHASHES) then
-- 			net_WriteHashes()
-- 		else
-- 			findSuperfileUrl(downloadAndRunSuperfile)
-- 		end
-- 		net.Send(pl)
-- 	end)
-- end

-- findSuperfileUrl(downloadAndRunSuperfile)


