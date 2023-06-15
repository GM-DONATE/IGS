local function map(t, f)
	local _t = {}
	for index,value in pairs(t) do
		local k, kv, v = index, f(value, index)
		_t[v and kv or k] = v or kv
	end
	return _t
end

local error_no_igsmod =
	"ABTogoHaT He HacTpoeH: Hy}{Ho ycTaHoBuTb igsmodificator. " ..
	"(CKa4auTe ero c cauTa gm-donate.net/panel)"

local error_invalid_credentials =
	"Не указаны или неверно указаны данные проекта в файле config_sv.lua"

local DELIMITER = "{up}"
function IGS.GetSign(tParams, secret)
	local s = ""
	for _,v in SortedPairs(tParams) do
		s = s .. tostring(v):Trim() .. DELIMITER
	end

	return util.SHA256(s .. (secret or IGS.C.ProjectKey))
end

function IGS.DoRequest(project_id, secret, sMethod, tParams, fSucc, fErr)
	tParams = map(tParams, tostring)

	local api_url = IGS_API_ENDPOINT or "https://gm-donate.net/api"
	http.Post(api_url .. sMethod, tParams, fSucc, fErr, {
		sign    = IGS.GetSign(tParams, secret),
		project = tostring(project_id)
	})
end

function IGS.RawQuery(sMethod, tParams, fOnSuccess, fOnError)
	if not IGS.C.ProjectKey then
		IGS.print(Color(255,0,0), error_no_igsmod)
		return
	end

	if #IGS.C.ProjectKey ~= 32 or not IGS.C.ProjectKey:match("^[a-f0-9]+$") or IGS.C.ProjectID == 0 then
		IGS.print(Color(255,0,0), error_invalid_credentials)
		return
	end

	IGS.DoRequest(IGS.C.ProjectID, IGS.C.ProjectKey, sMethod, tParams, fOnSuccess, fOnError)
end

local function wrapResponse(sMethod, tParams, fOnSuccess, fOnError)
	IGS.RawQuery(sMethod, tParams, function(sBody)
		local d = util.JSONToTable(sBody)

		if (not d) then
			IGS.print(Color(255,0,0), sBody)
			fOnError("invalid_response_format")
		elseif (not d.ok) then
			fOnError(d.error)
		else
			fOnSuccess(d)
		end
	end, function(err)
		IGS.print(Color(255,0,0), "HTTP Error: " .. err)
		fOnError("http_error")
	end)
end

function IGS.WrapQuery(sMethod, tParams, fOnSuccess, fOnError)
	wrapResponse(sMethod, tParams, function(tResponse)
		hook.Run("IGS.OnApiSuccess", sMethod, tResponse, tParams)
		if fOnSuccess then fOnSuccess(tResponse.data) end
	end, function(error_uid)
		hook.Run("IGS.OnApiError", sMethod, error_uid, tParams, fOnSuccess)
		if fOnError then fOnError(error_uid) end
	end)
end

function IGS.Query(sMethod, tParams, fOnSuccess)
	IGS.REPEATER:SafeQuery(sMethod, tParams, fOnSuccess)
end


-- Дебаг
-- local sid = "76561198071463189"



--[[
>----------------------------<
	ДЕЙСТВИЯ С ИГРОКОМ
>----------------------------<
]]
-- Обновление данных о нике, чтобы отображать в чартах и последних покупках, да и вообще, чтобы знать что за чел
-- Каллбэк бесполезен. Без важной инфы
function IGS.UpdatePlayerName(s64, sName, fCallback)
	IGS.Query("/donators/setName",{
		sid  = s64,
		name = sName
	},fCallback)
end
-- IGS.UpdatePlayerName(sid,"TEST !@#$%^&*()'",PRINT)

-- nil or {`Name`,`Balance`, `Score`}
function IGS.GetPlayer(s64, fCallback)
	IGS.Query("/donators/get",{
		sid = s64,
	}, fCallback)
end
-- IGS.GetPlayer(sid,PRINT)

-- В каллбэке nil или баланс донат валюты игрока
function IGS.GetBalance(s64, fCallback)
	IGS.GetPlayer(s64,function(player)
		fCallback(player and player["Balance"])
	end)
end
-- IGS.GetBalance(sid, PRINT)

-- nil or nick
function IGS.GetName(s64, fCallback)
	IGS.GetPlayer(s64,function(player)
		fCallback(player and player["Name"])
	end)
end
-- IGS.GetName(sid, PRINT)



--[[
>----------------------------<
	ТРАНЗАКЦИИ
>----------------------------<
]]
-- Макс длина примечания - 80 символов
-- Возвращает ID вставленной транзакции
function IGS.Transaction(s64, iSum, sNote_, fCallback)
	IGS.Query("/transactions/create",{
		sid  = s64,
		s    = IGS.SERVERS:ID(),
		sum  = iSum,
		note = sNote_ or nil,
	},fCallback and function(res)
		if res and res ~= 0 then
			fCallback(res)
		end
	end)
end
-- IGS.Transaction(sid,-2,"test . , !#$%^&*(",function(id)
-- 	PRINT("Вставленный ид: " .. id)
-- end)

-- `ID`, `Sum`, `Time`, `Note`, `Server`, `SteamID`
function IGS.GetTransactions(fCallback, s64_, bGlobal_, iLimit_, iOffset_) -- новые сверху
	IGS.Query("/transactions/get",{
		sid    = s64_ or nil,
		s      = (not bGlobal_) and IGS.SERVERS:ID() or nil,
		limit  = iLimit_ or nil, -- max 255
		offset = iOffset_ or nil,
	},fCallback)
end
-- IGS.GetTransactions(PRINT, sid, false, 10)

-- Последние 255 транзакций игрока (8 байт unsigned int) (net("IGS.MyTransactions")
function IGS.GetPlayerTransactions(fCallback, s64) -- новые сверху
	IGS.GetTransactions(fCallback, s64, true, 255)
end
-- IGS.GetPlayerTransactions(PRINT,sid)

-- Последние транзакции проекта. Без лимита вернет 255
function IGS.GetLatestTransactions(fCallback, iLimit_)
	IGS.GetTransactions(fCallback, nil, true, iLimit_)
end
-- IGS.GetLatestTransactions(PRINT, 10)




--[[
>----------------------------<
	ПОКУПКИ
>----------------------------<
]]
-- В каллбэке ИД покупки с БД. Если не указать iDaysTerm, то навсегда
function IGS.StorePurchase(s64, sItemUID, iDaysTerm_, iServerID, fCallback)
	IGS.Query("/purchases/create",{
		sid  = s64,
		s    = iServerID,
		item = sItemUID,
		term = iDaysTerm_ or nil, -- nil, чтобы навсегда
	},fCallback and function(last_ID)
		last_ID = tonumber(last_ID)
		if last_ID and last_ID ~= 0 then
			fCallback(last_ID)
		end
	end)
end

function IGS.StoreLocalPurchase(s64, sItemUID, iDaysTerm_, fCallback)
	IGS.StorePurchase(s64, sItemUID, iDaysTerm_, IGS.SERVERS:ID(), fCallback)
end
-- IGS.StoreLocalPurchase(sid,"item",2,function(id)
-- 	PRINT("Вставленный ид: " .. id)
-- end)

-- Перенос покупки. Если указать iNewServer nil, то покупка станет доступной на всех серверах
-- Кажется, всегда возвращает true (upd: https://t.me/c/1353676159/35765)
function IGS.MovePurchase(db_id, iNewServer_, fCallback)
	IGS.Query("/purchases/move",{
		id      = db_id,
		serv_to = iNewServer_ or nil -- nil для global #todo global истреблен, как вид
	},fCallback)
end
-- IGS.MovePurchase(10519, nil, PRINT)

-- Отключение покупки. ID получать через IGS.GetPurchases
function IGS.DisablePurchase(db_id, fCallback)
	IGS.MovePurchase(db_id, 0, fCallback)
end
-- IGS.DisablePurchase(123, PRINT)

-- available params: sid, limit (max 127), offset, s, only_active
-- return list of {`ID`,`Server`,`Item`,`Purchase`,`Expire`(таймштамп),`SteamID`, `Nick`}
-- https://img.qweqwe.ovh/1507920534081.png
function IGS.GetPurchases(fCallback, tParams)
	IGS.Query("/purchases/get", tParams, fCallback) -- таблица
end

function IGS.GetPlayerPurchases(s64, fCallback)
	IGS.GetPurchases(fCallback, {sid = s64, only_active = 1, s = IGS.SERVERS:ID()})
end
-- IGS.GetPlayerPurchases(sid, PRINT)

-- В коллбэке глобальный список последних покупок
-- (`Nick`,`Server`,`Item`,`DateExpire`)
function IGS.GetLatestPurchases(fCallback, iLimit_) -- max 127
	IGS.GetPurchases(fCallback, {limit = iLimit_ or 10})
end

-- IGS.GetLatestPurchases(function(t)
-- 	local res = fn.Foldl(function(a, v)
-- 		a[v.SteamID] = v.Nick
-- 		return a
-- 	end, {}, t)

-- 	PRINT(res)
-- end, 127)



--[[
>----------------------------<
	ССЫЛКИ
>----------------------------<
]]
function IGS.GetPaymentURL(fCallback, s64, iSum, sExtra)
	IGS.Query("/url/getPayment",{
		sid   = s64,
		sum   = iSum,
		extra = sExtra or nil, -- опционально. Если указать, то в хуке IGS.PaymentStatusUpdated (после оплаты) будет параметр .extraData с вашим значением
	}, fCallback) -- ссылка
end
-- IGS.GetPaymentURL(PRINT, sid, 10, "test")


--[[
>----------------------------<
	ПРОЕКТ (Конкретный проект)
>----------------------------<
]]
-- {settings = {["MinCharge"] = val,["CurrencyPrice"] = val},
-- name = "name",
-- coowners = {[sSid] = iAccess}}
function IGS.GetProjectData(fCallback)
	IGS.Query("/project/get",{},function(p)
		if p then
			-- Костыль 80го лвл, связанный с принципом обработки JSON в гмоде
			for s64,access in pairs(p.coowners) do
				p.coowners[s64] = nil
				p.coowners[s64:sub(2)] = access
			end
		end

		fCallback(p)
	end) -- таблица
end
-- IGS.GetProjectData(PRINT)

-- `MinCharge`,`CurrencyPrice`
function IGS.GetSettings(fCallback)
	IGS.GetProjectData(function(proj)
		fCallback(proj["settings"])
	end)
end
-- IGS.GetSettings(PRINT)

-- project/getPlayers



--[[
>----------------------------<
	СЕРВЕРЫ
>----------------------------<
]]
-- Добавляет сервер к проекту. Возвращает ID
function IGS.AddServer(ip, port, fCallback)
	IGS.Query("/servers/create",{
		ip   = ip,
		port = port,
	},fCallback) -- id добавленного сервера
end
-- IGS.AddServer("255.255.255.255", 65535, PRINT)

-- Получает список серверов проекта
-- `ID`,`Name`,`IP`,`Port`,`Disabled`
-- Если указать bIncludeDisabled, то получит и отключенные
function IGS.GetServers(fCallback, bIncludeDisabled_, iID_)
	IGS.Query("/servers/get",{
		s   = iID_ or nil,
		all = bIncludeDisabled_ and 1 or nil
	},fCallback) -- таблица
end
-- IGS.GetServers(PRINT, true, 10)

-- Возвращает внешний IP сервера
function IGS.GetExternalIP(fCallback)
	IGS.Query("/servers/getExternalIP",{},fCallback)
end
-- IGS.GetExternalIP(PRINT)

-- Нужно указать минимум один параметр (name, version, state, ip, hostport)
function IGS.UpdateServer(iServerID, tParams, fCallback)
	tParams.s = iServerID
	IGS.Query("/servers/update", tParams, fCallback)
end

function IGS.UpdateCurrentServer(tParams, fCallback)
	IGS.UpdateServer(IGS.SERVERS:ID(), tParams, fCallback)
end

-- Изменение отображаемого имени сервера в панели
function IGS.SetServerName(sName, fCallback)
	IGS.UpdateCurrentServer({name = sName}, fCallback) -- до 32 символов
end
-- IGS.SetServerName("12345678901234567890123456789012", PRINT)

-- Чисто техническая инфа для упрощения поддержки
function IGS.SetServerVersion(iVersion, fCallback)
	IGS.UpdateCurrentServer({version = iVersion}, fCallback) -- до 16777215
end
-- IGS.SetServerVersion(IGS.Version, PRINT)

function IGS.UpdateServerAddress(iServerID, ip, port, fCallback)
	IGS.UpdateServer(iServerID, {ip = ip, hostport = port}, fCallback)
end

-- Изменяет статус сервера. 0 - норм. 1 - отключен. 2 - скрыт
-- function IGS.SetServerState(iState, fCallback)
-- 	IGS.UpdateCurrentServer({state = iState}, fCallback)
-- end
-- IGS.SetServerState(0,PRINT)







--[[
>----------------------------<
	ИНВЕНТАРЬ
	local pl = player.GetBySteamID64(sid)
	IGS.LoadInventory(pl) -- перезагрузит данные инвентаря
>----------------------------<
]]
-- ID вставленной записи
function IGS.StoreInventoryItem(fCallback, s64, sUid)
	IGS.Query("/inventory/addItem",{
		sid    = s64,
		item   = sUid,
	}, fCallback)
end
-- IGS.StoreInventoryItem(PRINT,sid,"money_1mi")

-- array `ID`,`Item`
function IGS.FetchInventory(fCallback, s64)
	IGS.Query("/inventory/get",{
		sid = s64
	}, fCallback) -- таблица
end
-- IGS.FetchInventory(PRINT,sid)

-- bool deleted
function IGS.DeleteInventoryItem(fCallback, iID)
	IGS.Query("/inventory/deleteItem",{
		id = iID
	}, fCallback)
end
-- IGS.DeleteInventoryItem(PRINT,22091)




--[[
>----------------------------<
	КУПОНЫ
>----------------------------<
]]
-- В колбэке код купона.
-- iGiveMoney указывается в донат ВАЛЮТЕ. Т.е. для созданяи купона на 5 Alc, нужно писать IGS.CreateCoupon(5 ...
-- iDaysTerm это срок действия купона в днях. Спустя столько дней его нельзя будет активировать. Укажите nil, чтобы купон был вечным
-- Имейте в виду, что все купоны одноразовые. Если хотите раздать многим людям по X Alc - создайте много купонов
function IGS.CreateCoupon(iGiveMoney, iDaysTerm_, sNote_, fCallback)
	IGS.Query("/coupons/create",{
		value = iGiveMoney, -- донат валюта
		term  = iDaysTerm_, -- срок действия
		note  = sNote_      -- до 50 символов
	},fCallback)
end
-- IGS.CreateCoupon(1,nil,nil,PRINT)

-- В каллбэке table купона (Value, UsedBy, DateExpire(таймштамп))
-- + bool истекший ли + bool использован ли
function IGS.GetCoupon(sCouponCode, fCallback)
	IGS.Query("/coupons/get",{
		coupon = sCouponCode,
	},function(c)
		if (not c) then fCallback() return end
		c.DateExpire = c.DateExpire and tonumber(c.DateExpire)

		--    купон             истекший ли                      использован ли
		fCallback(c, c.DateExpire and c.DateExpire < os.time() or false,c.UsedBy ~= nil)
	end)
end
-- IGS.GetCoupon("fe436044ee31a52205662275a7861220",function(c,expired,used)
-- 	PRINT({coup = c, expired = expired, used = used})
-- end)

-- В каллбэке true, если купон успешно деактивирован
-- false, если не существует или деактивирован ранее
function IGS.DeactivateCoupon(sActivatorSteamID, sCouponCode, fCallback)
	IGS.Query("/coupons/deactivate",{
		coupon        = sCouponCode,
		sid_activator = sActivatorSteamID,
	},fCallback)
end
-- IGS.DeactivateCoupon(sid,"c22b70d2c41578ad6d287e3a71d12eda",PRINT) -- true/false


--[[
>----------------------------<
	META
>----------------------------<
]]

-- #todo перенести в отдельный файл
kvapi = kvapi or {}

function kvapi.set(key, value, ttl, cb)
	http.Post("https://kv.gmod.app/set", {
		key = key, -- без спецсимволов
		value = tostring(value),
		ttl = tostring(ttl), -- min 60 sec, max 1 year, else error 400
	}, cb, error)
end

function kvapi.get(key, cb)
	http.Post("https://kv.gmod.app/get", {
		key = key,
	}, function(value, _, headers)
		cb(value ~= "" and value or nil, tonumber(headers.Expires))
	end, error)
end

-- kvapi.set("key:key", "value", 60, PRINT)
-- kvapi.get("key:key", fn.Flip(fc{PRINT, fp{fn.Sub, os.time()}}))

function IGS.SetSharedKV(key, value, ttl, cb)
	kvapi.set(IGS.C.ProjectKey .. ":" .. key:URLEncode(), value, ttl, cb)
end
-- IGS.SetSharedKV("test4", "тест", 60, PRINT)

function IGS.GetSharedKV(key, cb)
	kvapi.get(IGS.C.ProjectKey .. ":" .. key:URLEncode(), cb)
end
-- IGS.GetSharedKV("test3", print)
