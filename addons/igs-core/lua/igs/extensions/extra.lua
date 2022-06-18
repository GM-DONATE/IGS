local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetMaxGlobalPurchases(iMax)
	IGS.nw.Register("total_purchases_" .. self:UID()) -- только внутри хука юз
		:Write(net.WriteUInt, 8)
		:Read(net.ReadUInt, 8)
	:SetGlobal():SetHook("total_purchases_" .. self:UID())

	if CLIENT then -- #todo nw не позволяет, но нужно сделать ОДИН клиентский хук
		hook.Add("total_purchases_" .. self:UID(), self:UID(), function(purchased)
			if self.user_icon == nil then -- чтобы про луа рефреше не стало true
				self.user_icon = tobool(self.icon) -- bool вместо ссылки. Нужен, чтобы не оверрайдить юзерские иконки
			end
			if not self.user_icon then
				local left = iMax - purchased
				local icon = left <= 0 and " 0 " or left -- потому что 0 сайт не пережевывает
				self:SetIcon("https://via.placeholder.com/90x90.png?text=" .. icon)
			end

			if purchased >= iMax then
				self:SetHidden()
			end
		end)
	else
		local purchased = bib.getNum("igs:total_purchases:" .. self:UID())
		IGS.nw.SetGlobal("total_purchases_" .. self:UID(), purchased or 0)
	end

	return self:SetMeta("global_limit", iMax)
end

hook.Add("IGS.CanPlayerBuyItem", "GlobalLimit", function(_, ITEM)
	if SERVER and ITEM:GetMeta("global_limit") then
		local limit     = ITEM:GetMeta("global_limit")
		local purchased = bib.getNum("igs:total_purchases:" .. ITEM:UID(), 0)

		if purchased >= limit then
			return false, "Этот предмет закончился"
		end
	end
end)

hook.Add("IGS.PlayerPurchasedItem", "GlobalLimit", function(_, ITEM)
	if SERVER and ITEM:GetMeta("global_limit") then
		local limit     = ITEM:GetMeta("global_limit")
		local purchased = bib.getNum("igs:total_purchases:" .. ITEM:UID(), 0)

		bib.setNum("igs:total_purchases:"   .. ITEM:UID(), purchased + 1)
		IGS.nw.SetGlobal("total_purchases_" .. ITEM:UID(), purchased + 1)

		if purchased >= limit then
			ITEM:SetHidden()
		end
	end
end)




-- Возволяет настроить максимальное количество ПОКУПОК одного предмета
-- Полезно для тестовых випок за рубль и тд
function STORE_ITEM:SetMaxPlayerPurchases(iLimit)
	local function bibKey(pid, iid) return string.format("igs:purchases:%s:%s", pid, iid) end

	return self:SetCanBuy(function(pl)
		local limit = self:GetMeta("purchasesLimit")
		local key = bibKey(pl:UniqueID(), self:UID())
		if bib.getNum(key, 0) >= limit then
			return "Этот предмет можно купить только " .. limit .. " раз(а)"
		end
	end):SetOnBuy(function(pl)
		local limit = self:GetMeta("purchasesLimit")
		if limit then
			local key = bibKey(pl:UniqueID(), self:UID())
			local now_purchased = bib.getNum(key, 0) + 1
			bib.setNum(key, now_purchased)
			IGS.Notify(pl, "Вы купили " .. self:Name() .. " " .. now_purchased .. " раз из " .. limit)
		end
	end):SetMeta("purchasesLimit", iLimit)
end




-- Глобальные итемы будут активированы на каждом сервере проекта
-- https://img.qweqwe.ovh/1574888071533.png
function STORE_ITEM:SetGlobal(b)
	return self:SetMeta("global", b ~= false)
end

hook.Add("IGS.PlayerActivatedItem", "IGS.GlobalPurchase", function(pl, ITEM)
	if SERVER and ITEM:GetMeta("global") then
		for sv_id in pairs(IGS.SERVERS.MAP) do
			if sv_id ~= IGS.SERVERS.CURRENT then -- еще не выдано
				IGS.StorePurchase(pl:SteamID64(), ITEM:UID(), ITEM:Term(), sv_id)
			end
		end

		IGS.Notify(pl, "Предмет выдан на " .. IGS.SERVERS.TOTAL .. " серверах")
	end
end)

-- Выдает рандомный предмет из указанных (аналог кейсов)
-- https://trello.com/c/hWRihJ1k/564
-- Заметка, почему не нужно делать tItemsUIDs
-- https://img.qweqwe.ovh/1568507799904.png
-- Использовать только с :SetStackable предметами
local function giveRandomItem(pl, tItems)
	local WINNED_ITEM = table.Random(tItems)

	IGS.PlayerActivateItem(pl, WINNED_ITEM:UID(), function()
		IGS.Notify(pl, "Вы получили " .. WINNED_ITEM:Name())
	end)
end

-- Сочетается с :SetTerm(0), :SetMaxPurchases() и :SetStackable()
function STORE_ITEM:SetRandom(tItems)
	return self:SetInstaller(function(pl)
		giveRandomItem(pl, self:GetMeta("random_items"))
	end):SetMeta("random_items", tItems)
end


local function giveItemsSet(pl, tItems)
	local added = 0
	for _,ITEM in ipairs(tItems) do
		IGS.AddToInventory(pl, ITEM:UID(), function()
			added = added + 1
			if added == #tItems then
				IGS.Notify(pl, "В ваш инвентарь добавлено " .. added .. " предметов")
			end
		end)
	end
end

-- Ложит В ИНВЕНТАРЬ набор указанных предметов (хотя можно и UID добавить)
-- Например 10 Hidden аптечек (как замена лимиту активаций в инвентаре)
function STORE_ITEM:SetItems(tItems) -- IGS.C.Inv_Enabled
	return self:SetInstaller(function(pl)
		giveItemsSet(pl, self:GetMeta("items_set"))
	end):SetMeta("items_set", tItems)
end
-- local ITEM = IGS("Тайный предмет", "secret", -10):SetStackable():SetHidden():SetOnActivate(fp{PRINT, "YEAH!!"})
-- IGS("2 тайных предмета", "secret_2", 5):SetStackable():SetItems({ITEM, ITEM})




--[[-------------------------------------------------------------------------
	Секция с возможным перемещением в ядро
	Переместить, если AddHook будет востребован для замены каких-то методов ядра
---------------------------------------------------------------------------]]

-- Должно использовать только те хуки,
-- где первым аргументом в колбеке идет игрок
-- ITEM:AddHook("PlayerLoadout", funciton(pl) pl:GiveAmmos() end)
function STORE_ITEM:AddHook(sHook, fCallback)
	local uid = self:UID()
	hook.Add(sHook, "item." .. uid, function(pl, ...)
		if pl:HasPurchase(uid) then
			return fCallback(pl, ...)
		end
	end)
	return self
end
