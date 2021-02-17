if (not pcall(require,"socket")) then
	MsgC(Color(250,50,50), "luasocket .dll модуль в /lua/bin не установлен!!\n")
	return
end

local CLI = {} -- обертка, потому что на клиентский сокет нельзя присваивать значения
CLI.__index = function(self, k)
	if CLI[k] then
		return CLI[k]
	end

	-- Заместитель self. CLIOBJ:method проталкивает вместо CLIOBJ.sock сам CLIOBJ, но этот объект - лишь обертка
	-- Есть ли лучший способ протолкнуть через ":" CLIOBJ.sock?
	local found = getmetatable(self.sock).__index[k]
	if found and isfunction(found) then
		return function(...)
			found(self.sock, select(2,...))
		end
	end
end

local SERV = {}
SERV.__index = SERV

function SERV:Close()
	SOCKY.Close(self.port)
end

function SERV:Log(str)
	MsgC("[SOCK:" .. self.port .. "] " .. str .. "\n")
end

function SERV:AddWhitelistedIP(sIP)
	if (not self.wlist) then self.wlist = {} end

	self.wlist[sIP] = true
	return self
end

function SERV:BanIP(sIP, iTimeSec)
	self.blist[sIP] = os.time() + (iTimeSec or 0)
	return self
end

function SERV:SetBurstLimit(iConnLimit, iFrameTime) -- ограничивает количество запросов
	self.burst = {
		iConnLimit, iFrameTime,
		sessions = {}
	}

	return self
end

function SERV:AddCallback(func, uid)
	self.callbacks[uid] = func
end







local startThinking,stopThinking

if (not SOCKY) then
	SOCKY = setmetatable({},{
		__call = function(self, port)
			return self.Get(port)
		end
	})

	SOCKY.GetTable = setmetatable({},{
		__call = function(self) return self end
	})
end





-- Возвращает существующий или создает новый слушатель
function SOCKY.Get(port)
	local t = SOCKY.GetTable()
	if t[port] then return t[port] end

	local sock = socket.tcp() -- https://img.qweqwe.ovh/1519125947225.png (methods)
	assert(sock:settimeout(0))

	assert(sock:bind("0.0.0.0", port))
	assert(sock:listen(0))

	assert(sock:setoption("reuseaddr", true))
	assert(sock:setoption("linger",{on = true, timeout = 0}))

	startThinking()

	local OBJ = setmetatable({
		sock = sock,
		port = port,

		blist = {},
		callbacks = {}
	},SERV)

	OBJ:Log("Socket настроен")

	t[port] = OBJ
	return OBJ
end

-- timer.Simple(.1,function()
-- 	local PORT = 30004

-- 	prt(SOCKY.GetTable)


-- 	SOCKY.GetTable[PORT] = nil
-- 	-- SOCKY.Close(PORT)

-- 	assert(SOCKY.Get(PORT),"Сокет не открылся")
-- end)

function SOCKY.Close(port)
	local t = SOCKY.GetTable
	local OBJ = t[port]
	assert(OBJ,"Порт не прослушивается")

	OBJ.sock:close() -- хмм. Всегда возщвращает 1. Даже если уже закрыт
	t[port] = nil

	if (not next(t)) then
		stopThinking()
	end
end


function SOCKY.CloseAll()
	for _,OBJ in pairs( SOCKY.GetTable() ) do -- port first
		OBJ:Log("Closing socket")
		OBJ:Close()
	end
end


function SOCKY.assert(cl, expr, msg, banTime)
	if (not expr) then
		cl:close()

		if banTime then
			cl.SERVER:BanIP(cl.IP, banTime)
		end

		error("[SOCKY] " .. msg)
	else
		return expr
	end
end




local function filterHook(cl)
	local accept = hook.Run("SOCKY.NewMessage", cl, cl.SERVER, cl.IP)
	if accept ~= false then
		return true
	end
end

local function filterIP(cl)
	if (cl.SERVER.wlist and not cl.SERVER.wlist[cl.IP]) then
		return false, "Not whitelisted"
	end

	if cl.SERVER.blist[cl.IP] then
		local unban = cl.SERVER.blist[cl.IP]
		if unban == 0 or unban >= os.time() then
			return false, "Blacklisted " .. (unban - os.time())
		else
			cl.SERVER.blist[cl.IP] = nil
		end
	end

	return true
end

local function filterBurst(cl)
	if (not cl.SERVER.burst) then return true end

	if (not cl.SERVER.burst.sessions[cl.IP]) then
		cl.SERVER.burst.sessions[cl.IP] = {0, 0} -- iConnections, iLastTime
	end

	local b = cl.SERVER.burst
	local s = b.sessions[cl.IP]


	-- По этой схеме возможны проблемы, если, например установить размер фрейма 60 сек и burst 5
	-- а затем каждые 61 сек 5+1 раз отправить сообщение
	local iLastTime = os.time() % b[2]
	if iLastTime < s[2] then
		s[1] = 0 -- new frame, reset
	else
		s[1] = s[1] + 1
	end

	s[2] = iLastTime

	-- iConnections, iConnLimit
	if s[1] > b[1] then
		return false, "Connections limit"
	end

	return true
end

local function sock_assert(cl, assert_func)
	local expr,msg = assert_func(cl)
	if (not expr) then
		cl.SERVER:Log("Попытка подключения с " .. cl.IP .. " отклонена: " .. msg)
		cl:close()
		error("SOCKY Error. " .. msg)
	end
end

local function processSock(OBJ)
	local cl,err = OBJ.sock:accept()

	-- https://img.qweqwe.ovh/1518666959568.png
	if err == "Too many open files" then -- flood
		collectgarbage() -- решение, которое спасает
		OBJ:Log("Очиска мусора после " .. err)

		return
	end

	if cl then
		local ip    = cl:getpeername() -- ip, bytes?, name (inet)
		local clOBJ = setmetatable({sock = cl},CLI)
		clOBJ.SERVER = OBJ
		clOBJ.IP = ip

		-- if true then
		-- 	prt(getmetatable(cl))
		-- 	-- print( getmetatable(cl).__index )

		-- 	-- print(cl.settimeout)
		-- 	-- print(clOBJ.settimeout)

		-- 	print(cl.settimeout(cl, 2))
		-- 	print(clOBJ.settimeout(clOBJ.sock, 2))

		-- 	return
		-- end


		sock_assert(clOBJ, filterIP)
		sock_assert(clOBJ, filterBurst)
		sock_assert(clOBJ, filterHook)

		clOBJ:settimeout(2) -- если месседж приходит "без данных", значит надо увеличить

		-- print("cl:receive 1", clOBJ.sock:receive("*l"))
		-- print("cl:receive 2", clOBJ.sock:receive("*l"))
		-- print("cl:receive 3", clOBJ.sock:receive("*l"))

		for uid,func in pairs(OBJ.callbacks) do
			local ok,msg = func(clOBJ)
			if ok == false then
				clOBJ:close()

				if msg then
					OBJ:Log("Соединениие закрыто! " .. msg)
				end

				return
			end

			if msg then
				clOBJ:send(msg)
			end
		end

		clOBJ:close()
	end
end

function startThinking()
	-- print("SOCKY: startThinking")

	hook.Add("Think", "ListenSockets", function()
		for _,OBJ in pairs( SOCKY.GetTable() ) do -- port first
			processSock(OBJ)
		end
	end)
end

function stopThinking()
	-- print("SOCKY: stopThinking")
	hook.Remove("Think", "ListenSockets")
end

hook.Run("SOCKY.ImReady")
