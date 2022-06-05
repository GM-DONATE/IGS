-- #todo нужно переделывать, но только так:
-- https://trello.com/c/WfVYTIOF/544 (комменты)
CreateConVar("igs_debug", 0, FCVAR_NOTIFY)
cvars.AddChangeCallback("igs_debug", function(_, old, new)
	IGS.DEBUG = tobool(new)
	IGS.print("PEZuM OTJIA9Ku " .. (IGS.DEBUG and "AKTuBuPOBAH" or "BbIKJII04EH"))
end, "main")


local PLAYER = FindMetaTable("Player")

function PLAYER:IGSFunds()
	return self:GetIGSVar("igs_balance") or 0
end

function PLAYER:HasPurchase(sUID)
	return IGS.PlayerPurchases(self)[sUID]
end

-- true, если человек имеет хоть один итем из списка, nil, если итем не отслеживается, false, если нет права. Начало юзаться для упрощения кода модулей
function IGS.PlayerHasOneOf(pl,tItems)
	if !tItems then return end

	for _,ITEM in ipairs(tItems) do
		if pl:HasPurchase( ITEM:UID() ) then
			return ITEM
		end
	end

	return false
end

function IGS.isUser(pl) -- возвращает false, если чел никогда не юзал автодонат
	return pl:GetIGSVar("igs_balance") ~= nil
end


-- Может ли чел себе позволить покупку итема, ценой в sum IGS?
function IGS.CanAfford(pl,sum,assert)
	if sum >= 0 and pl:IGSFunds() - sum >= 0 then
		return true
	end

	if !assert then
		return false
	end

	if isfunction(assert) then
		assert()
	else
		local rub = IGS.RealPrice(sum)
		if SERVER then
			IGS.WIN.Deposit(pl,rub)
		else
			IGS.WIN.Deposit(rub)
		end
	end

	return false
end

-- Список активных покупок игрока
-- uid > amount
function IGS.PlayerPurchases(pl)
	return CLIENT and (pl:GetIGSVar("igs_purchases") or {}) or pl:GetVar("igs_purchases",{})
end

-- Сумма в донат валюте всех операций пополнения счета (включая купоны и выдачу денег администратором)
function IGS.TotalTransaction(pl)
	return pl:GetIGSVar("igs_total_transactions") or 0
end

-- возврат объекта ЛВЛ на клиенте, номера уровня на сервере
function IGS.PlayerLVL(pl)
	return pl:GetIGSVar("igs_lvl")
end


-- Конвертирует IGS в реальную валюту
function IGS.RealPrice(iCurrencyAmount)
	return iCurrencyAmount * IGS.GetCurrencyPrice()
end

-- Реальная валюта в IGS по текущему курсу
function IGS.PriceInCurrency(iRealPrice)
	return iRealPrice / IGS.GetCurrencyPrice()
end


function IGS.IsCurrencyEnabled()
	return IGS.GetCurrencyPrice() ~= 1
end

local function getSettings()
	return IGS.nw.GetGlobal("igs_settings")
end

-- Минимальная сумма пополнения в рублях
function IGS.GetMinCharge()
	return getSettings()[1]
end

-- Стоимость 1 донат валюты в рублях
function IGS.GetCurrencyPrice()
	return getSettings()[2]
end

-- Не смог загрузиться или выключен в панели, меню открывать нельзя
function IGS.IsLoaded()
	return getSettings() and IGS.SERVERS:ID() and !GetGlobalBool("IGS_DISABLED")
end




local terms = {
	[1] = "бесконечно",
	[2] = "единоразово",
	[3] = "%s"
}

function IGS.TermType(term)
	return
		!term     and 1 or -- бесконечно
		term == 0 and 2 or -- мгновенно
		term      and 3    -- кол-во дней
end

function IGS.TermToStr(term)
	return terms[ IGS.TermType(term) ]:format(term and PL_DAYS(term))
end

function IGS.TimestampToDate(ts,bShowFull) -- в "купил до"
	if !ts then return end
	return os.date(bShowFull and IGS.C.DATE_FORMAT or IGS.C.DATE_FORMAT_SHORT,ts)
end


function IGS.FormItemInfo(ITEM)
	return {
		["Категория"] = ITEM:Category(),
		["Действует"] = IGS.TermToStr(ITEM:Term()),
		["Цена"]       = PL_MONEY(ITEM:Price()),
		["Без скидки"] = ITEM.discounted_from and PL_MONEY(ITEM.discounted_from) or nil,
		["Покупки суммируются"]  = ITEM:IsStackable() and "да" or "нет",
	}
end


function IGS.print(...)
	local args = {...}
	if !IsColor(args[1]) then
		table.insert(args,1,color_white)
	end

	args[#args] = args[#args] .. "\n"
	MsgC(Color(50,200,255), "[IGS] ", unpack(args))
end

function IGS.dprint(...)
	if IGS.DEBUG then
		IGS.print("DEBUG: ", Color(50,250,50), ...)
	end
end




function IGS.SignPrice(iPrice) -- 10 Alc
	return math.Truncate(tonumber(iPrice),2) .. " " .. IGS.C.CURRENCY_SIGN
end

local rubs = {"рубль", "рубля", "рублей"}
PL_MONEY = PLUR(rubs)
PL_IGS   = PLUR(IGS.C.CurrencyPlurals or rubs)
PL_DAYS  = PLUR({"день", "дня", "дней"})


local PL_IGS_ORIGINAL
hook.Add("IGS.OnSettingsUpdated","PL_IGS = PL_MONEY",function()
	if !IGS.IsCurrencyEnabled() then -- Если донат валюта отключена
		PL_IGS_ORIGINAL = PL_IGS -- а это не таблица случайно? Мб table.copy?
		PL_IGS = PL_MONEY

	-- Валюта уже отключалась. Сейчас включилась
	elseif PL_IGS_ORIGINAL then
		PL_IGS = PL_IGS_ORIGINAL
	end
end)
