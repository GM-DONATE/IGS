setmetatable(IGS,{
	__call = function(self,...)
		return self.AddItem(...)
	end
})


--[[-------------------------------------------------------------------------
	МАКСИМАЛЬНОЕ КОЛ-ВО УЛУЧШЕНИЙ 255
---------------------------------------------------------------------------]]

local STORE_ITEM = MT_IGSItem or {}
STORE_ITEM.__index = STORE_ITEM
MT_IGSItem = STORE_ITEM

local function set(self,var,val)
	self[var] = val
	return self
end


--[[-------------------------------------------------------------------------
	GET values (для тех значений, что нельзя Set)
---------------------------------------------------------------------------]]
function STORE_ITEM:Name()
	return self.name
end

function STORE_ITEM:UID()
	return self.uid
end

function STORE_ITEM:ID()
	return self.id
end

-- VIP, Huntsman Knifes. Присваивается через GROUP:AddItem
function STORE_ITEM:Group()
	return self.group
end

--[[-------------------------------------------------------------------------
	SET/GET values
---------------------------------------------------------------------------]]
-- Double цена товара в реальной валюте (не автодоната)
function STORE_ITEM:SetPrice(iPrice)
	return set(self,"price",iPrice)
end

-- TODO УСТАРЕЛО. БУДЕТ УДАЛЕНО В БЛИЖАЙШИХ ВЕРСИЯХ
-- Подробнее: https://forum.gm-donate.net/t/kak-sdelat-skidku-na-moder-esli-u-igroka-vip/1441/18?u=gmd
function STORE_ITEM:Price()
	return self.price
end


-- function(pl, self) return pl:IsUserGroup("vip") and 50 end
-- если return ничего не вернул, то будет стандартная цена
function STORE_ITEM:SetGetPrice(fGetPrice)
	return set(self,"getprice",fGetPrice)
end

function STORE_ITEM:GetPrice(pl)
	local price_override = hook.Run("IGS.ItemPriceOverride", self, pl)
	if price_override then return price_override end

	local getprice = self.getprice and self.getprice(pl, self)
	return getprice or self.price
end

-- Сбрасывает текущее описание и устанавливает указанное, если не указать bAppand
function STORE_ITEM:SetDescription(sDesc,bAppend)
	return set(self,"description",bAppend and (self:Description() .. sDesc) or sDesc)
end

function STORE_ITEM:Description()
	return self.description
end

-- Ссылка на картинку иконки товара 1:1. Желательно минимум 100 px
-- Или же путь к модельке, но тогда вторым аргументом указать true
function STORE_ITEM:SetIcon(sIcon, bIsModel)
	return CLIENT and set(self,"icon",{
		icon    = sIcon,
		isModel = bIsModel,
	}) or self
end

function STORE_ITEM:ICON()
	if self.icon then
		return self.icon["icon"], self.icon["isModel"]
	end
end

-- Цвет подсветки заголовка итема в списке
function STORE_ITEM:SetHighlightColor(color)
	return CLIENT and set(self,"highlight",color) or self
end

function STORE_ITEM:GetHighlightColor()
	return self.highlight
end

-- Пермапушки, права, группы, уровни
function STORE_ITEM:SetCategory(sCat)
	return set(self,"category",sCat)
end

function STORE_ITEM:Category()
	return self.category
end

-- Срок в днях, на который выдается услуга. 0 если одноразовая. nil, если вечная
function STORE_ITEM:SetTerm(iDays)
	return set(self,"termin",iDays)
end

function STORE_ITEM:SetPerma()
	return self:SetTerm(nil)
end

function STORE_ITEM:Term()
	return self.termin
end

-- Дает возможность мультипокупки. Полезно для лимита пропов, патронов при спавне и т.д.
function STORE_ITEM:SetStackable(b)
	return set(self,"stackable",b ~= false) -- nil = true; 1 = true; true = true; false = false
end

function STORE_ITEM:IsStackable()
	return self.stackable
end

-- Нужна ли информация о покупке на клиентсайде? (Будет в IGS.PlayerPurchases(ply))
function STORE_ITEM:SetNetworked(b)
	return set(self,"networked",b ~= false)
end

-- Баннер товара. Будет отображен под информацией о товаре. Рекомендуемый размер 1000х400
function STORE_ITEM:SetImage(sUrl)
	return set(self,"image_url",sUrl)
end

function STORE_ITEM:IMG()
	return self.image_url
end

-- Нельзя купить, но можно активировать с инвентаря.
-- Полезно, чтобы "удалять" ненужные, но еще активные у людей итемы
function STORE_ITEM:SetHidden(b)
	return set(self,"hidden",b ~= false)
end

function STORE_ITEM:IsHidden()
	return self.hidden
end

-- Для удобной установки метаданных итему вместо ITEM.key = val (полезно внутри функций, типа GROUP:Add(ITEM))
function STORE_ITEM:SetMeta(key, value)
	if (not self.meta) then self.meta = {} end
	self.meta[key] = value
	return self
end

function STORE_ITEM:GetMeta(key)
	return self.meta and self.meta[key]
end

function STORE_ITEM:SetDiscountedFrom(i) -- internal
	return set(self,"discounted_from", i)
end

-- function STORE_ITEM:DiscountedFrom()
-- 	return self.discounted_from
-- end



--[[-------------------------------------------------------------------------
	Функции
---------------------------------------------------------------------------]]
-- функции передается игрок
-- Должна вернуть ОШИБКУ (строку) или nil/false, если все ок
function STORE_ITEM:SetCanBuy(fCallback)
	return SERVER and set(self,"canbuy",fCallback) or self
end

-- После удачной покупки передает в каллбэк игрока
function STORE_ITEM:SetOnBuy(fCallback)
	return SERVER and set(self,"onbuy",fCallback) or self
end

-- "Установщик" услуги. Внутренняя функция, чтобы не оверрайдить :SetOnActivate
-- Осторожнее в комбинации с :SetValidator
function STORE_ITEM:SetInstaller(fCallback)
	return SERVER and set(self,"installer",fCallback) or self
end

-- Как и SetCanBuy, но для активации с инвентаря
function STORE_ITEM:SetCanActivate(fCallback)
	return SERVER and set(self,"canactivate",fCallback) or self
end

-- Для выдачи бонусов etc. Игрок в каллбэке
-- Выполнять только при реальной активации игроком или выдаче через панель,
-- а не автовосстановлении etc
function STORE_ITEM:SetOnActivate(fCallback)
	return SERVER and set(self,"onactivate",fCallback) or self
end

-- Если fChecker вернет false, то выполнится installer
function STORE_ITEM:SetValidator(fChecker)
	return SERVER and set(self,"validator",fChecker) or self
end

if SERVER then
	function STORE_ITEM:Setup(pl) -- внутренняя
		if self.installer then
			self.installer(pl)
		end
	end

	function STORE_ITEM:OnActivate(pl) -- публичная
		self:Setup(pl)

		if self.onactivate then
			self.onactivate(pl)
		end
	end

	-- Активация
	-- Возвращает boolErr и errMsg
	function STORE_ITEM:CanActivate(pl, iInvId)
		if (not self:IsStackable() and pl:HasPurchase( self:UID() )) then
			return false,"Услуга уже активна"
		end

		local canActivate,err = hook.Run("IGS.CanPlayerActivateItem", pl, self, iInvId)
		if canActivate ~= nil then
			return canActivate,err
		end

		if self.canactivate then
			local er = self.canactivate(pl, iInvId)
			if er then
				return false,er
			end
		end

		return true
	end

	-- Покупка
	function STORE_ITEM:CanBuy(pl)
		local canBuy,err = hook.Run("IGS.CanPlayerBuyItem", pl, self)
		if canBuy ~= nil then
			return canBuy,err
		end

		if self.canbuy then
			local er = self.canbuy(pl)
			if er then -- Обратная совместимость с SetCanBuy
				return false,er
			end
		end

		return true
	end
	function STORE_ITEM:Buy(pl)
		if self.onbuy then
			self.onbuy(pl)
		end
	end

	-- Разные функции
	function STORE_ITEM:IsValid(pl)
		if self.validator then
			return self.validator(pl)
		end
	end
end


--[[-------------------------------------------------------------------------
	MISC
---------------------------------------------------------------------------]]
-- Вставка этого итема в таблицу под указанным ключом
-- Используется при создании модулей для упрощения кода
-- До:    https://img.qweqwe.ovh/1494247121142.png
-- После: https://img.qweqwe.ovh/1494247134028.png
function STORE_ITEM:Insert(to, key)
	to[key] = to[key] or {}
	if not table.HasValue(to[key],self) then
		table.insert(to[key], self)
	end
	return key
end


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

function STORE_ITEM:AddServerHook(sHook, fCallback)
	return SERVER and self:AddHook(sHook, fCallback) or self
end

function STORE_ITEM:AddClientHook(sHook, fCallback)
	return CLIENT and self:AddHook(sHook, fCallback) or self
end

--[[-------------------------------------------------------------------------
	CORE
---------------------------------------------------------------------------]]
function IGS.Item(sName, sUID)
	return setmetatable({
		name = sName,
		uid  = sUID,
		-- id   = ,
		description = "",
		termin = 0 -- если не изменить, то услуга не добавится в покупки. Только в транзакции
	}, STORE_ITEM)
end



IGS.ITEMS = IGS.ITEMS or {
	STORED = {},
	MAP    = {},
}

function IGS.AddItem(sName, sUID, iPrice)
	sUID = sUID:lower()

	-- Поле БД 32. Но с "P: " UID надо сокращать
	-- P: entity_hpwand_spell_simple_wand
	if #sUID > 28 then
		IGS.print(Color(250,20,20),
			"UID " .. sUID .. " имеет длину свыше 28 символов, что не допускается\n" ..
			"Причиной также могут стать кириллические (русские) или иные (emoji) символы.\n" ..
			"UniqueID предмета должен состоять из маленьких английских (латинских) букв без пробелов и быть короче 28 символов"
		)
		-- return -- из-за этого в консоль вылезет ошибка, т.е. не вернется объект

		local old = sUID
		sUID = old:sub(1, 28)
		IGS.print(Color(250,20,20), "UID " .. old .. " сокращен до " .. sUID .. "\n")
	end

	-- Защита от сбивания айдишников из-за рефреша файла с добавлением итемов
	-- Чтобы счетчик не набивался
	local ITEM = IGS.ITEMS.MAP[sUID]
	if ITEM then
		ITEM:SetPrice(iPrice or ITEM.price) -- обновляем цену, вдруг изменилась
		ITEM.name = sName -- и имя

		return ITEM
	end

	local t = IGS.Item(sName, sUID)
	t.id = #IGS.ITEMS.STORED + 1

	if iPrice then
		t:SetPrice(iPrice)
	end

	IGS.ITEMS.MAP[t.uid]   = t
	IGS.ITEMS.STORED[t.id] = t -- just insert

	return t
end


local null = IGS.Item("null", "null"):SetPrice(0)
	:SetDescription("Этот предмет, скорее всего, когда-то существовал или существует на другом сервере, но не здесь")
	:SetIcon("http://i.imgur.com/NfpcFdy.png")
	:SetImage("http://i.imgur.com/32iTOFi.jpg")
	:SetCanBuy(function() return "Этого предмета на сервере нет. Как вы нашли его?" end)
	:SetCanActivate(function() return "Этого предмета на сервере нет. Можете уничтожить его" end) -- например купил в инвентарь, а потом uid сменился

null.isnull = true -- для проверки во время активации
null.id = 0 -- на всякий

-- IGS.NULL = null -- альтернативный способ сравнения

function IGS.GetItem(id_or_uid) -- AKA ItemExists
	return IGS.ITEMS.STORED[id_or_uid] or IGS.ITEMS.MAP[id_or_uid]
end

function IGS.GetItemByUID(sUID)
	return IGS.ITEMS.MAP[sUID:lower()] or null
end

function IGS.GetItems()
	return IGS.ITEMS.STORED
end
