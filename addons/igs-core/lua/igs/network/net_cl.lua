-- Запрашивает покупку итема в инвентарь
function IGS.Purchase(sItemUID, callback)
	net.Start("IGS.Purchase")
		net.WriteString(sItemUID)
	net.SendToServer()

	net.Receive("IGS.Purchase",function()
		local errMsg  = net.ReadIGSError()

		local ITEM = IGS.GetItemByUID(sItemUID)
		if errMsg then
			if callback then callback(errMsg) end
			hook.Run("IGS.OnFailedPurchase", ITEM, errMsg)
		else
			local invDbID_ = IGS.C.Inv_Enabled and net.ReadUInt(IGS.BIT_INV_ID)
			if callback then callback(nil, invDbID_) end
			hook.Run("IGS.PlayerPurchasedItem", LocalPlayer(), ITEM, invDbID_)
		end
	end)
end

-- Активирует купленный итем (Только если IGS.C.Inv_Enabled)
function IGS.Activate(iInvID, callback)
	net.Start("IGS.Activate")
		net.WriteUInt(iInvID, IGS.BIT_INV_ID)
		net.WriteBool(callback)
	net.SendToServer()

	if not callback then return end
	net.Receive("IGS.Activate", function()
		local ok = net.ReadBool()
		local iPurchID = ok and net.ReadUInt(IGS.BIT_PURCH_ID)
		local sMsg_ = net.ReadIGSMessage()
		callback(ok, iPurchID, sMsg_)
	end)
end

function IGS.UseCoupon(sCoupon, callback)
	net.Start("IGS.UseCoupon")
		net.WriteString(sCoupon)
	net.SendToServer()

	net.Receive("IGS.UseCoupon", function()
		callback(net.ReadIGSError())
	end)
end

--[[-------------------------------------------------------------------------
	Ссылки
---------------------------------------------------------------------------]]
function IGS.GetPaymentURL(iSum,fCallback)
	net.Start("IGS.GetPaymentURL")
		net.WriteDouble(iSum)
	net.SendToServer()

	net.Receive("IGS.GetPaymentURL",function()
		fCallback(net.ReadString())
	end)
end



local cache,last_update = {},0 -- на сервере тоже кэширование
function IGS.GetLatestPurchases(fCallback)
	if last_update + 60 >= os.time() then
		fCallback(cache)
		return
	end

	net.Ping("IGS.GetLatestPurchases")
	net.Receive("IGS.GetLatestPurchases",function()
		local dat = {}
		for i = 1,net.ReadUInt(IGS.BIT_LATEST_PURCH) do
			dat[i] = net.ReadIGSPurchase() -- id и purchase не юзаются
		end

		cache = dat
		last_update = os.time()

		fCallback(dat)
	end)
end

-- тут таймаут не нужно. Даже если заспамить net - ничего не произойдет
function IGS.GetMyTransactions(fCallback)
	net.Ping("IGS.GetMyTransactions")

	net.Receive("IGS.GetMyTransactions",function()
		local dat = {}
		for i = 1,net.ReadUInt(IGS.BIT_TX) do
			dat[i] = net.ReadIGSTx()
		end

		fCallback(dat)
	end)
end

function IGS.GetMyPurchases(fCallback)
	net.Ping("IGS.GetMyPurchases")

	net.Receive("IGS.GetMyPurchases",function()
		local dat = {}
		for i = 1,net.ReadUInt(8) do
			dat[i] = net.ReadIGSPurchase()
		end

		fCallback(dat)
	end)
end




--[[-------------------------------------------------------------------------
	Инвентарь
---------------------------------------------------------------------------]]
function IGS.GetInventory(fCallback)
	net.Ping("IGS.GetInventory")

	net.Receive("IGS.GetInventory",function()
		local d = {}

		for i = 1,net.ReadUInt(7) do
			d[i] = net.ReadIGSInventoryItem()
		end

		fCallback(d)
	end)
end

function IGS.DropItem(iID,fCallback) -- энтити в каллбэке
	if not IGS.C.Inv_AllowDrop then
		IGS.ShowNotify("Дроп предметов отключен администратором", "Ошибка")
		return
	end

	net.Start("IGS.DropItem")
		net.WriteUInt(iID,IGS.BIT_INV_ID)
	net.SendToServer()

	net.Receive("IGS.DropItem",function()
		local ent = net.ReadEntity()

		if fCallback then
			fCallback(ent)
		end
	end)
end




net.Receive("IGS.PaymentStatusUpdated",function()
	local t = {}
	t.paymentType = net.ReadString()
	t.orderSum    = net.ReadString()
	t.method      = net.ReadString()

	if t.method == "error" then
		t.errorMessage = net.ReadString()
	end

	hook.Run("IGS.PaymentStatusUpdated",t)
end)

net.Receive("IGS.UI",function()
	IGS.UI()
end)
