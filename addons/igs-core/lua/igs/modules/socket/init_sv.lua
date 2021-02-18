IGS.SOCKLOG = lolib.new()
local log = IGS.SOCKLOG

log.setFormat("{time} igsocket {message}")
log.setCvar("igsocket_logging_level", 3)

--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]
function IGS.TellSocketPort(port, fCallback)
	IGS.Query("/servers/setSocketPort",{
		port = port,
	},fCallback)
end
-- IGS.TellSocketPort(12345, PRINT)

local function getGamePort()
	return tonumber( game.GetIPAddress():match(":(.+)$") )
end

local function findFreeSocket(start_point, end_point)
	for port = start_point,end_point do
		log.debug("Проверяем порт {}", port)
		local ok,res = pcall(SOCKY, port)
		log.debug(ok and "Свободен" or "Занят")
		if ok then
			return res,port
		end
	end
end

local function new()
	log.debug("Ищем свободный порт недалеко от порта сервера")
	local start_point = getGamePort() + 10
	local sock,port   = findFreeSocket(start_point, start_point + 20)

	if sock then
		log.debug("Начали слушать свободный порт {}. Оповещаем GMD", port)
		IGS.TellSocketPort(port)

		timer.Create("IGS.SockHeartbeat", 60 * 60, 0, function()
			log.debug("Напоминаем GMD наш порт сокета: {}", port)
			IGS.TellSocketPort(port)
		end)

		return sock
	end
end
--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]
local function old()
	if not IGS.C.SOCKETPORT then
		log.warning("В панели не указан порт, который мы должны слушать")
		return
	end

	local ok,res = pcall(SOCKY, IGS.C.SOCKETPORT)
	if ok then
		log.debug("Порт, указанный в панели оказался не занят")
		return res
	end

	local port = tostring(IGS.C.SOCKETPORT)
	log.warning("Порт, указанный в панели ({}), занят на сервере", port)
end
--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]

local function prepareSocket()
	if not SOCKY then
		for i = 1,10 do
			log.warning(" >>> Сокет модуль не установлен. " ..
				"Убедитесь, что в /lua/bin есть .dll файл. " ..
				"ДЕНЬГИ БУДУТ НАЧИСЛЯТЬСЯ ПОСЛЕ ПЕРЕЗАХОДА <<< ")
		end

		return
	end

	if tonumber(IGS.Version) > 210201 then
		log.debug("Версия IGS {} (старше, чем 210201). Сами сообщим GMD, что слушаем сокет", IGS.Version)
		return new()
	else
		log.debug("Старая версия IGS. Работаем по старинке (GMD возьмет порт из БД)")
		return old()
	end
end



local function setupSocket(OBJ)
	OBJ:SetBurstLimit(50, 60) -- 50 messages per minute

	OBJ:AddCallback(function(clOBJ)
		local cl = clOBJ.sock -- :receive некорректно работает на объект

		-- local all = cl:receive("*a")
		-- print("all", all)

		log.info("Входящее сообщение")

		local pass = cl:receive(32)
		log.debug("Пароль {}", pass)
		SOCKY.assert(clOBJ, pass == IGS.C.ProjectKey, "Incorrect IGS pass: " .. tostring(pass), 5)

		local size = tonumber(cl:receive(6))
		log.debug("Размер {}", size)
		local sDat = cl:receive(size)

		local tDat = SOCKY.assert(clOBJ, util.JSONToTable(sDat), "Мусор вместо JSON: " .. sDat)
		if log.level == 1 or log.level == 2 then
			PrintTable(tDat)
		end

		if not tDat.ok then
			log.warning("GMD вернул ошибку: {}", tDat.error)
			return
		end

		-- {cp = true/false, data = {}, ok = true, method = "payment"}
		hook.Run("IGS.NewSocketMessage", tDat.data, tDat.method, tDat)
	end, "IGS")
end



hook.Add("IGS.Loaded", "SOCKET", function() -- IGS.C.SOCKETPORT будет лишь внутри
	log.debug("IGS загружен. Готовлю socket")
	IGS.SOCK = prepareSocket()

	if IGS.SOCK then
		setupSocket(IGS.SOCK)
		log.info("Socky слушает порт {} (мгновенные действия)", IGS.SOCK.port)
	else
		log.warning("Socky не определил порт для прослушивания")
	end
end)
