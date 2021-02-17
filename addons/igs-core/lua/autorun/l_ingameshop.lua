IGS = IGS or {}
IGS.Version = 200125 -- #TODO версия должна получаться и устанавливаться в самом главном файле (фетча этого с гита)

file.CreateDir("igs/" .. IGS.Version)


local i = {} -- lua files only
i.sv = SERVER and include or function() end
i.cl = SERVER and AddCSLuaFile or include
i.sh = function(f) return i.cl(f) or i.sv(f) end

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
		if (sRealm == "sh")
		or (sRealm == "sv" and SERVER)
		or (sRealm == "cl" and CLIENT) then
			print(string.format("%s Иклюд с DATA. Путь: %s", sRealm, path_in_data))
			local content  = file.Read(path_in_data, "DATA")
			local executer = CompileString(content, path_in_data)
			return executer()
		end
	else
		print(string.format("IGS: Файл %s не найден. Путь: %s", iam_inside and ("внутри " .. iam_inside) or "", sPath))
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

IGS.sh("igs/launcher.lua")
