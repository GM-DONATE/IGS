IGS.C = IGS.C or {} -- config

local function sh(path) return IGS.sh("igs/" .. path) end
local function sv(path) return IGS.sv("igs/" .. path) end
local function cl(path) return IGS.cl("igs/" .. path) end

local function dir(path, fIncluder) return IGS.include_files("igs/" .. path, fIncluder) end
local function mods(path) return IGS.load_modules("igs/" .. path) end


sh("dependencies/plurals.lua")
sh("dependencies/chatprint.lua")
sv("dependencies/stack.lua")
sh("dependencies/scc.lua")
sv("dependencies/resources.lua") -- иконки, моделька дропнутого итема
sh("dependencies/bib.lua")
sh("dependencies/permasents.lua")

-- #todo сделать через require
-- lua/includes/modules отсюда
-- уберет костыль внутри kupol
-- +при фетче оверрайд require
sh("dependencies/lolib.lua") -- должна быть перед kupol
-- sh("dependencies/kupol.lua") -- решил поставлять с модулем

-- Антиконфликт с https://trello.com/c/3ti6xIjW/
sh("dependencies/dash/nw.lua")

-- if !dash then
sh("dependencies/dash/hash.lua")
sh("dependencies/dash/misc.lua")
cl("dependencies/dash/wmat.lua")

sh("settings/config_sh.lua")
sv("settings/config_sv.lua") -- для фетча project key (Генерация подписи)

-- Метаобъекты
sh("objects/level.lua")
sh("objects/shop_group.lua")
sh("objects/shop_item.lua")

sh("network/nw_sh.lua") -- для igs_servers в serv_sv.lua

sv("core_sv.lua") -- для фетча подписи

sv("repeater.lua")
sv("apinator.lua")

-- После датапровайдера, хотя сработают все равно после первого входа игрока
sh("servers/serv_sh.lua")
sv("servers/serv_sv.lua")



--[[-------------------------------------------------------------------------
	Второй "этап" (для работы требовал загрузку серверов)
---------------------------------------------------------------------------]]
sh("utils/ut_sh.lua")
sv("utils/ut_sv.lua")
cl("utils/ut_cl.lua")


-- Нельзя ниже sh_additems
dir("extensions", IGS.sh)

sh("settings/sh_additems.lua")
sh("settings/sh_addlevels.lua")

sv("network/net_sv.lua")
cl("network/net_cl.lua")


cl("interface/skin.lua")
-- cl("core_cl.lua")

-- Подключение VGUI компонентов
dir("interface/vgui", IGS.cl)

cl("interface/core.lua")

dir("interface/activities", IGS.cl)
dir("interface/windows", IGS.cl)

mods("modules")

sv("processor_sv.lua") -- начинаем обработку всего серверного в конце


--[[------------------------------
	Уродский кусок пост хуков
--------------------------------]]
if SERVER then
	hook.Add("IGS.ServersLoaded", "Loaded", function()
		IGS.GetSettings(function(t)
			IGS.UpdateMoneySettings(t["MinCharge"],t["CurrencyPrice"])
			hook.Run("IGS.Loaded")
		end)
	end)
else
	hook.Add("IGS.OnSettingsUpdated","Loaded",function()
		hook.Run("IGS.Loaded")
	end)
end

hook.Run("IGS.Initialized") -- можно создавать итемы
