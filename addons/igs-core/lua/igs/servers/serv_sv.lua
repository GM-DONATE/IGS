local function getHostPort()
	return tonumber( game.GetIPAddress():match(":(.+)$") )
end

local function dprint(...)
	if IGS.DEBUG and IGS.DEBUG <= 2 then -- debug, info, [warning, error]
		IGS.dprint("🐛 ", "", ...)
	end
end

-- После вызова этой функции загружается вторая часть скрипта
-- Т.е. не вызвать функцию - не запустится скрипт
-- Она не вызывается, если сервер отключен или произошла ошибка в ходе выполнения запроса на получение списка серверов
local function onReady()
	dprint("Мы готовы. ", "Запускаем IGS 🚀")
	IGS.SERVERS.Broadcast()
	hook.Run("IGS.ServersLoaded")
	IGS.SetServerVersion( cookie.GetString("igs_version", "123") )
end

local function addServerLocally(id, serv_name, enabled)
	if true    then IGS.SERVERS.TOTAL   = IGS.SERVERS.TOTAL   + 1 end
	if enabled then IGS.SERVERS.ENABLED = IGS.SERVERS.ENABLED + 1 end

	IGS.SERVERS.MAP[id] = serv_name
end

local function addCurrentServerLocally(id, serv_name)
	IGS.SERVERS.CURRENT = id
	addServerLocally(id, serv_name, true)

	-- было в registerCurrentServer до https://t.me/c/1353676159/17695
	bib.set("igs:serverid", id)
end

local function registerCurrentServer(local_ip,port, fOnSuccess)
	IGS.AddServer(local_ip, port, function(id)
		IGS.prints(
			"CEPBEP 3APEruCTPuPOBAH nOg ig: ", id, "\n" ..
			"HACTPOuKu B ", "gm-donate.net/panel/projects/" .. IGS.C.ProjectID
		)

		local serv_name = GetConVarString("hostname")
		addCurrentServerLocally(id, serv_name) -- нужно снаружи для IGS.SERVERS:ID()
		IGS.SetServerName( serv_name )
	end)
end

local function loadServersOrRegisterCurrent(d, local_ip)
	local serv_port = getHostPort()

	-- reset
	IGS.SERVERS.TOTAL   = 0
	IGS.SERVERS.ENABLED = 0

	local maxVisibleServerId = 0 -- больший ид может быть архивированным
	local isCurrentDisabled
	for _,v in ipairs(d) do -- -- `ID`,`Name`,`IP`,`Port`,`Disabled`
		local disabled = tobool(v.Disabled)
		maxVisibleServerId = math.max(v.ID, maxVisibleServerId)

		-- Текущий сервер
		if v.IP == local_ip and v.Port == serv_port then
			if disabled then isCurrentDisabled = true end
			addCurrentServerLocally(v.ID, v.Name)
			dprint("📍 ВКЛ: ", (disabled and "❌" or "✅"), " ID: ", v.ID, ". Название: ", v.Name)
		else
			addServerLocally(v.ID, v.Name, not disabled)
			dprint("📤 ВКЛ: ", (disabled and "❌" or "✅"), " ID: ", v.ID, ". Название: ", v.Name)
		end
	end

	dprint("ID самого младшего сервера: ", maxVisibleServerId)

	-- limit 50
	if maxVisibleServerId > 40 then
		IGS.prints(Color(255, 50, 50), "",
			"y IIpoekTa ", maxVisibleServerId, " 3arerucTpuPoBaHHbIx cepBepoB.\n" ..
			"IIo gocTu}{eHuIO 50 cepBepoB HoBbIe IIepectaHyT co3gaBaTbC9 u 3tot He 3arpy3uTc9.\n" ..
			"O6HoBJI9uTe IP IIpowJIbIX uJIu co3gauTe HoBbIu IIpoeKT"
		)
	end

	if isCurrentDisabled then
		IGS.prints(Color(255, 50, 50), "", "3TOT CEPBEP OTKJII04EH. 3ArPy3KA nPEKPAwEHA")
		return -- не даем выполнить onReady()
	end

	-- Сервер не зарегистрирован
	if not IGS.SERVERS.CURRENT then
		local id_before = bib.getNum("igs:serverid")
		if id_before and IGS.SERVERS(id_before) then
			IGS.prints("IIOXO}{E 3TOT CEPBEP IIEPEEXAJI (CMEHA IP)")
			IGS.UpdateServerAddress(id_before, local_ip, serv_port, function()
				IGS.GetServers(function(dat)
					loadServersOrRegisterCurrent(dat, local_ip)
				end, true)
			end)

		else
			IGS.prints("3TOT CEPBEP HE 3APEruCTPuPOBAH. CO39AEM!")
			registerCurrentServer(local_ip,serv_port, onReady)
		end
	else
		onReady()
	end
end


local function getAndLoadServers(local_ip)
	dprint("Наш IP: ", local_ip, ". Получаем список серверов проекта")
	IGS.GetServers(function(dat)
		dprint("Получили данные ", #dat, " сервера(ов). Сохраняем в ОЗУ")
		loadServersOrRegisterCurrent(dat, local_ip)
	end, true) -- include disabled
end

timer.Simple(0, function() -- фетч заработает только так в этот момент
	dprint("Загрузка серверов")
	IGS.GetExternalIP(getAndLoadServers)
end)

local function renewAddressAndReloadServers(ip)
	IGS.UpdateServerAddress(IGS.SERVERS:ID(), ip, getHostPort(), function()
		IGS.GetServers(function(dat)
			loadServersOrRegisterCurrent(dat, ip)
		end, true)
	end)
end

hook.Add("IGS.OnApiError","NotifyAboutImpossibleLoading",function(sMethod)
	if sMethod == "/servers/get" then
		IGS.prints(Color(255,0,0), "", "NEVOZMOZNO ZAGRUZIT SKRIPT. VAZNIE DANNIE NE POLUCHENI")
	end
end)

-- https://t.me/c/1353676159/10880
hook.Add("IGS.OnApiError","DuplicatedServerWarning",function(sMethod, error_uid)
	if sMethod == "/servers/get" and error_uid == "server_already_exists" then
		IGS.prints(Color(255,0,0), "", "Server s takim IP i PORTom uze zaregistrirovan v paneli. Nuzno izmenit ego tam na drugoy")
	end
end)
