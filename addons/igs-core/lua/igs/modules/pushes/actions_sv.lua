--[[-------------------------------------------------------------------------
	Мгновенные изменения
---------------------------------------------------------------------------]]
local function getPlayer(dat)
	return player.GetBySteamID64( dat.SteamID64 )
end

-- Обновление статуса платежа
hook.Add("IGS.IncomingMessage","PaymentStatus",function(d, method)
	if method ~= "payment.UpdateStatus" then return end

	local pl = getPlayer(d)
	if not pl then return end

	-- https://img.qweqwe.ovh/1537567538620.png
	-- https://img.qweqwe.ovh/1537568769298.png
	hook.Run("IGS.PaymentStatusUpdated",pl,d)
end)

-- Моментальная выдача услуги
hook.Add("IGS.IncomingMessage","GivePurchase",function(d, method)
	if method ~= "purchase.store" then return end

	local pl = getPlayer(d)
	if not pl then return end

	local ITEM = IGS.GivePurchase(pl,d.Item) -- выдает покупку без сохранения в БД
	IGS.Notify(pl, IGS.GetPhrase("panelgaveitem") .. " " .. ITEM:Name())
end)

-- Перенос услуги (в т.ч. отключение)
hook.Add("IGS.IncomingMessage","MovePurchase",function(d, method)
	if not (method == "purchase.move" and IGS.SERVERS:ID() == d.ServFrom) then return end

	local pl = getPlayer(d)
	if not pl then return end

	-- Просто перезагружаем данные
	-- Если перенос был на этот сервер, то услуга будет выдана (или забрана. С :HasPurchase)
	IGS.Notify(pl, IGS.GetPhrase("panelmoveordisableitem"))
	IGS.LoadPlayerPurchases(pl,function()
		IGS.Notify(pl, IGS.GetPhrase("paneltableresetted"))
	end)
end)


local INV_ACTIONS = {
	["inventory.storeItem"]  = true,
	["inventory.deleteItem"] = true,
}

-- Забираем вещь с инвентаря
-- Добавление итема в инвентарь
hook.Add("IGS.IncomingMessage","InventoryActions",function(d, method)
	if not INV_ACTIONS[method] then return end

	local pl = getPlayer(d)
	if not pl then return end

	IGS.Notify(pl, IGS.GetPhrase("panelinvreset"))
	IGS.LoadInventory(pl,function()
		IGS.Notify(pl, IGS.GetPhrase("panelinvresetted"))
	end)
end)

-- Отключаем сервер
hook.Add("IGS.IncomingMessage","DisableServer",function(d, method)
	if method ~= "servers.disable" then return end

	local endl = ""
	if d.Server == IGS.SERVERS:ID() then
		-- Относительно тяжелая, но кейс редкий. не критично
		-- https://img.qweqwe.ovh/1566303954304.png
		-- Можно заюзать lua broadcast переменной даже
		SetGlobalBool("IGS_DISABLED", true)
	else
		endl = " на " .. IGS.SERVERS(d.Server)
	end

	IGS.NotifyAll(IGS.GetPhrase("autodonatedisabled") .. endl)
end)

-- nomr
hook.Add("IGS.IncomingMessage", "nomr", function(d, method)
	if method ~= "transactions.create" then return end

	local pl = getPlayer(d)
	if not pl then return end

	if IGS.C.DisableAntiMultirun then return end

	if d.Server and d.Server ~= IGS.SERVERS:ID() then
		pl:Kick(IGS.GetPhrase("transactiononotherserver"))
	end
end)
