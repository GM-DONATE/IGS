util.AddNetworkString("IGS.PaymentStatusUpdated")
util.AddNetworkString("IGS.UI")
-- Остальные внутри net_ReceiveProtected


local SERIA_TIME   = 60 -- ~ каждые 60 сек будет сбрасываться счетчик
local MAX_QUERIES  = 30 -- 30 запросов в минуту, получается
local KICK_QUERIES = 60 -- 60 запросов в минуту с человека и кик

local function SeriaTime()
	return os.time() % SERIA_TIME
end

local function checkNotReady(pl) -- не даем совершать никакие операции, если автодонат не загрузился (Например, бэкенд сдох)
	local current_frame = SeriaTime()

	local d = pl:GetVar("igs_burst", {0,0})
	local last_frame,queries = d[1],d[2]

	queries = (current_frame < last_frame) and 0 or queries + 1
	last_frame = current_frame

	d[1],d[2] = last_frame,queries

	pl:SetVar("igs_burst",d)

	if queries > KICK_QUERIES then
		pl:Kick("Networking flood")
		return true
	end

	if queries > MAX_QUERIES then
		return true
	end

	if (not IGS.REPEATER:IsEmpty()) then
		IGS.Notify(pl,"Автодонат временно не работает")
		return true
	end
end

local function net_ReceiveProtected(sName, fCallback)
	util.AddNetworkString(sName)

	net.Receive(sName,function(_,pl)
		if checkNotReady(pl) then return end

		-- local iMsgID = net.ReadUInt(8) -- 255
		fCallback(pl)
	end)
end




--[[-------------------------------------------------------------------------
	ПОКУПКА
---------------------------------------------------------------------------]]
local function IGS_Purchase(pl, uid, cb)
	local ITEM = IGS.GetItemByUID(uid)

	local price = ITEM:GetPrice(pl)

	local err = -- не в ITEM:CanBuy, потому что в некоторых случаях эти проверки вредны, когда хочешь дать игроку итем, который ему не положен
		not ITEM:CanSee( pl ) and "Как вы меня нашли?"
		or not IGS.CanAfford(pl, price) and ("Для покупки нужно " .. PL_MONEY(price))
		or IGS.IsInventoryOverloaded(pl) and "У вас перегруз в донат инвентаре. А еще вы один из немногих, кто видел это!"
		or pl.igs_unfinished_purchase and "Запрос на покупку в процессе. Подождите, пожалуйста" -- в цикле с клиента вызов функции покупки

	-- инвентарь офнут, значит итем сразу должен иметь возможность активироваться
	if not IGS.C.Inv_Enabled then
		local can,e = ITEM:CanActivate(pl)
		if not can then
			err = e or "Ошибка 1"
		end
	end

	local can,e = ITEM:CanBuy(pl)
	if not can then
		err = e or "Ошибка 2"
	end

	if err then
		cb(nil, err)
		return
	end

	pl.igs_unfinished_purchase = true
	pl:AddIGSFunds(-price, "P: " .. uid, function()

		-- ложит в инвентарь или регает сразу как покупку если тот отключен
		IGS.PlayerPurchasedItemByUID(pl, uid, function(ok, id_or_err) -- inv_db or purch_id or err string
			pl.igs_unfinished_purchase = nil

			if not ok then
				cb(nil, id_or_err)
				return
			end

			if IGS.C.Inv_Enabled then
				IGS.Notify(pl, "Ваша покупка находится в /donate инвентаре")
			end

			cb(id_or_err)
		end)
	end)
end

-- Добавляет в инвентарь
net_ReceiveProtected("IGS.Purchase", function(pl)
	local sItemUID = net.ReadString()

	IGS_Purchase(pl, sItemUID, function(invDbID_, errMsg_)
		net.Start("IGS.Purchase")
			net.WriteIGSError(errMsg_)

			if IGS.C.Inv_Enabled and not errMsg_ then
				net.WriteUInt(invDbID_, IGS.BIT_INV_ID)
			end
		net.Send(pl)

		if errMsg_ then
			local ITEM = IGS.GetItemByUID(sItemUID)
			hook.Run("IGS.OnFailedPurchase", pl, ITEM, errMsg_)
			IGS.Notify(pl,"Ошибка покупки " .. sItemUID .. ": " .. errMsg_)
		end
	end)
end)





--[[-------------------------------------------------------------------------
	АКТИВАЦИЯ
---------------------------------------------------------------------------]]
local function IGS_Activate(pl, invDbID, cb)
	if not IGS.C.Inv_Enabled then
		cb(nil, "Инвентарь отключен. Активация предметов моментальная")
		return
	end

	local INVITEM = IGS.Inventory(pl,"map")[invDbID]
	if not INVITEM then -- если чел резко дважды кнопку нажал
		cb(nil, "Предмет уже активирован. ID: " .. tostring(invDbID))
		return
	end

	local IGSITEM = IGS.GetItemByUID(INVITEM.Item)

	local can,err = IGSITEM:CanActivate(pl, invDbID)
	if not can then
		cb(nil, err or "Ошибка")
		return
	end

	-- Выше еще проверка. Это лишняя, но не помешает
	local tRemoved = IGS.DeletePlayerInventoryItemLocally(pl, invDbID)
	if (not tRemoved) then
		cb(nil, "Предмет уже активирован #2")
		return
	end

	IGS.DeleteInventoryItem(function(ok)
		if not ok then -- например, через панель \/
			cb(nil, "Предмет не найден. Возможно, уже активирован")
			return
		end

		hook.Run("IGS.PlayerActivatedInventoryItem", pl, IGSITEM, invDbID) -- где-то нужно передать invDbID для log
		IGS.PlayerActivateItem(pl, IGSITEM:UID(), cb)
	end, invDbID)
end

-- Активирует услугу, забирая ее из инвентаря
net_ReceiveProtected("IGS.Activate", function(pl)
	IGS_Activate(pl, net.ReadUInt(IGS.BIT_INV_ID), net.ReadBool() and function(iPurchID, sMsg_)
		net.Start("IGS.Activate")
			net.WriteBool(iPurchID) -- OK
			if iPurchID then
				net.WriteUInt(iPurchID, IGS.BIT_PURCH_ID)
			end
			net.WriteIGSMessage(sMsg_) -- err || custom msg || nothing (сейчас error only)
		net.Send(pl)
	end or function() end)
end)



--[[-------------------------------------------------------------------------
	КУПОНЫ
---------------------------------------------------------------------------]]
local function IGS_EnterCoupon(pl,sCode,cb)
	if string.Trim(sCode) == "" then
		cb(false, "Введите код купона")
		return
	end

	-- хук юзается в beauty code. Внутри берется реальный купон из БД
	-- а также можно юзать для всякого разного, например купоны на скидку
	local override,err_ = hook.Run("IGS.PlayerEnterCoupon", pl, sCode)
	if override ~= nil then cb(override, err_) return end

	IGS.PlayerActivateCoupon(pl, sCode, cb)
end

net_ReceiveProtected("IGS.UseCoupon", function(pl)
	IGS_EnterCoupon(pl, net.ReadString(), function(ok, errMsg_)
		net.Start("IGS.UseCoupon")
			if not ok then
				net.WriteIGSError(errMsg_ or "unknown COUPON error")
			end
		net.Send(pl)
	end)
end)




--[[-------------------------------------------------------------------------
	ССЫЛКИ
---------------------------------------------------------------------------]]
net_ReceiveProtected("IGS.GetPaymentURL", function(pl)
	local sum  = net.ReadDouble()

	IGS.GetPaymentURL(function(url)
		net.Start("IGS.GetPaymentURL")
			net.WriteString(url)
		net.Send(pl)
	end, pl:SteamID64(), sum)
end)


--[[-------------------------------------------------------------------------
	ПОСЛЕДНИЕ ПОКУПКИ
---------------------------------------------------------------------------]]
local cache,last_update = {},0
hook.Add("IGS.PlayerPurchasedItem", "ResetLatestPurchasesCache", function()
	-- https://trello.com/c/hEgPItm0/
	table.Empty(cache)
	last_update = 0
end)

local function IGS_GetLatestPurchases(pl, cb)
	-- если кэш старее, чем N минут, то обновляем и отправляем игроку
	-- Иначе отправляем кэшированные данные без повторнгого обращения к БД
	if last_update + 5 * 60 >= os.time() then
		cb(cache)
		return
	end

	-- 10 можно поднимать вплоть до 63. Дальше будут ошибки
	IGS.GetLatestPurchases(function(dat)
		cache = dat
		last_update = os.time() -- CurTime не юзать, чтобы не получать пустую таблицу

		cb(dat)
	end,10)
end

net_ReceiveProtected("IGS.GetLatestPurchases", function(pl)
	IGS_GetLatestPurchases(pl,function(dat)
		net.Start("IGS.GetLatestPurchases")
			net.WriteUInt(#dat,IGS.BIT_LATEST_PURCH)

			for _,v in ipairs(dat) do
				net.WriteIGSPurchase(v)
			end
		net.Send(pl)
	end)
end)


--[[-------------------------------------------------------------------------
	СПИСОК СВОИХ ТРАНЗАКЦИЙ
---------------------------------------------------------------------------]]
local function IGS_GetMyTransactions(pl, cb)
	IGS.GetPlayerTransactions(cb, pl:SteamID64())
end

net_ReceiveProtected("IGS.GetMyTransactions", function(pl)
	IGS_GetMyTransactions(pl, function(dat)
		net.Start("IGS.GetMyTransactions")
			net.WriteUInt(#dat, IGS.BIT_TX)

			for _,v in ipairs(dat) do
				net.WriteIGSTx(v)
			end
		net.Send(pl)
	end)
end)


--[[-------------------------------------------------------------------------
	СПИСОК СВОИХ ПОКУПОК
---------------------------------------------------------------------------]]
local function IGS_GetMyPurchases(pl,cb)
	IGS.GetPlayerPurchases(pl:SteamID64(),cb)
end

net_ReceiveProtected("IGS.GetMyPurchases", function(pl)
	IGS_GetMyPurchases(pl,function(dat)
		net.Start("IGS.GetMyPurchases")
			net.WriteUInt(#dat,8) -- to 255

			for _,v in ipairs(dat) do
				net.WriteIGSPurchase(v)
			end
		net.Send(pl)
	end)
end)


--[[-------------------------------------------------------------------------
	ИНВЕНТАРЬ
---------------------------------------------------------------------------]]
local function IGS_GetInventory(pl,cb)
	cb( IGS.C.Inv_Enabled and IGS.Inventory(pl) or {} )
end

net_ReceiveProtected("IGS.GetInventory", function(pl)
	IGS_GetInventory(pl,function(inv)
		net.Start("IGS.GetInventory")
			net.WriteUInt(#inv,7) -- 127
			for _,v in ipairs(inv) do
				net.WriteIGSInventoryItem(v)
			end
		net.Send(pl)
	end)
end)


local function IGS_DropItem(pl,invId,cb)
	if not (IGS.C.Inv_Enabled and IGS.C.Inv_AllowDrop) then return end
	local canDrop = hook.Run("IGS.PlayerCanDropGift", pl, invId)
	if canDrop == false then
		return
	end

	IGS.PlayerEjectItem(function(ent)
		if (not ent) then return end -- ошибка

		timer.Simple(0,function() -- инициализация энтити
			cb(ent)
			hook.Run("IGS.PlayerDroppedGift", pl, ent:GetUID(), invId, ent)
		end)
	end, pl, invId)
end

net_ReceiveProtected("IGS.DropItem",function(pl)
	IGS_DropItem(pl,net.ReadUInt(IGS.BIT_INV_ID),function(ent)
		net.Start("IGS.DropItem")
			net.WriteEntity(ent)
		net.Send(pl)
	end)
end)






hook.Add("IGS.PaymentStatusUpdated","network",function(pl,d)
	if checkNotReady(pl) then return end

	net.Start("IGS.PaymentStatusUpdated")
		net.WriteString(d.paymentType) -- qiwi, card, sms
		net.WriteString(d.orderSum) -- 228.28
		net.WriteString(d.method) -- check, pay, error

		if d.errorMessage then
			net.WriteString(d.errorMessage)
		end
	net.Send(pl)
end)

-- Открытие менюшки на чубзике
function IGS.UI(pl)
	if checkNotReady(pl) then return end

	net.Ping("IGS.UI",pl)
end
