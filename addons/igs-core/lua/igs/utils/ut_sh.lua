-- #todo нужно переделывать, но только так:
-- https://trello.com/c/WfVYTIOF/544 (комменты)
CreateConVar("igs_debug", "0", FCVAR_NOTIFY)
cvars.AddChangeCallback("igs_debug", function(_, old, new)
	IGS.DEBUG = tonumber(new) -- level. 0: disabled, 1: debug, 2: info, 3: warning, 4: error
	if IGS.DEBUG == 0 then IGS.DEBUG = nil end
	IGS.prints("PEZuM OTJIA9Ku ", (IGS.DEBUG and "AKTuBuPOBAH" or "BbIKJII04EH"), ". Level: ", (IGS.DEBUG or 0))
end, "main")

--- @class Player
local PLAYER = FindMetaTable("Player")

function PLAYER:IGSFunds()
	return self:GetIGSVar("igs_balance") or 0
end

function PLAYER:HasPurchase(sUID)
	return IGS.PlayerPurchases(self)[sUID]
end

-- ITEM, если человек имеет хоть один итем из списка
-- nil, если итем не отслеживается
-- false, если нет права
function IGS.PlayerHasOneOf(pl, tItems)
	if not tItems then return end

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

	if not assert then
		return false
	end

	if isfunction(assert) then
		assert()
	else
		if SERVER then
			IGS.WIN.Deposit(pl, sum)
		else
			IGS.WIN.Deposit(sum)
		end
	end

	return false
end

-- Список активных покупок игрока
-- uid > amount
function IGS.PlayerPurchases(pl)
	return CLIENT and (pl:GetIGSVar("igs_purchases") or {}) or pl:GetVar("igs_purchases",{})
end

-- Сумма всех положительных операций по счету игрока
-- (включая пополнения, активацию купонов купоны и выдачу денег администратором)
function IGS.TotalTransaction(pl)
	return pl:GetIGSVar("igs_total_transactions") or 0
end

-- возврат объекта ЛВЛ на клиенте, номера уровня на сервере
function IGS.PlayerLVL(pl)
	return pl:GetIGSVar("igs_lvl")
end


-- Минимальная сумма пополнения в рублях
function IGS.GetMinCharge()
	return 10 -- TODO global var?
end

-- Не смог загрузиться или выключен в панели, меню открывать нельзя
function IGS.IsLoaded()
	return IGS.SERVERS:ID() and not GetGlobalBool("IGS_DISABLED")
end




local terms = {
	[1] = "бесконечно",
	[2] = "единоразово",
	[3] = "%s"
}

function IGS.TermType(term)
	return
		not term  and 1 or -- бесконечно
		term == 0 and 2 or -- мгновенно
		term      and 3    -- кол-во дней
end

function IGS.TermToStr(term)
	return terms[ IGS.TermType(term) ]:format(term and PL_DAYS(term))
end

function IGS.TimestampToDate(ts,bShowFull) -- в "купил до"
	if not ts then return end
	return os.date(bShowFull and IGS.C.DATE_FORMAT or IGS.C.DATE_FORMAT_SHORT,ts)
end

-- TODO: может удалить с sh (используется только на клиенте)
function IGS.FormItemInfo(ITEM, pl)
	return {
		["Категория"]  = ITEM:Category(),
		["Действует"]  = IGS.TermToStr(ITEM:Term()),
		["Цена"]       = PL_MONEY(ITEM:GetPrice(pl)),
		["Без скидки"] = ITEM.discounted_from and PL_MONEY(ITEM.discounted_from) or nil,
		["Покупки стакаются"]  = ITEM:IsStackable() and "да" or "нет",
	}
end

-- Упрощенная в применении версия IGS.print. Использует 2 цвета: основной и для выделений
-- Если первым указать цвет, то будет изменен цвет выделенного текста
-- Если вторым указать цвет, то будет изменен цвет обычного текста
-- Можно указать цвет текста, а первым аргументом использовать nil
function IGS.prints(...)
	local base_color = color_white
	local highlight_color = Color(50, 50, 255)

	local input = {...}
	if not input[1] then input[1] = highlight_color end -- если кто-то хочет поменять только цвет текста
	if istable( input[2] ) then base_color      = input[2] table.remove(input, 2) end
	if istable( input[1] ) then highlight_color = input[1] table.remove(input, 1) end

	local output = {}

	for i, psc in ipairs(input) do
		output[#output + 1] = (i % 2 == 0) and highlight_color or base_color
		output[#output + 1] = psc
	end

	output[#output + 1] = "\n"
	MsgC(Color(50, 200, 255), "[IGS] ", unpack(output))
end

-- Результат выполнения: https://file.def.pm/Jw9E7j7a.jpg
-- IGS.prints("одиночный текст базового (белого) цвета")
-- IGS.prints(nil, Color(255, 50, 50), "одиночный выделенным кастомным цветом текст")
-- IGS.prints(Color(255, 50, 50), "", "одиночный выделенным кастомным цветом текст") -- аналогичный вариант верхней записи
-- IGS.prints(Color(255, 50, 50), "обычный, ", "выделение кастомым цветом")
-- IGS.prints("обычный, ", "выделенный, ", "обычный, ", "выделенный")
-- IGS.prints("", "выделенный, ", "обычный, ", "выделенный, ", "обычный")
-- IGS.prints(Color(150, 150, 150), "обычный, ", "выделенный цветной, ", "обычный, ", "выделенный")
-- IGS.prints(Color(150, 150, 150), Color(255, 50, 50), "обычный, но красный, ", "выделенный серый, ", "красный, ", "серый")
-- IGS.prints(nil, Color(255, 50, 50), "обычный, но красный, ", "выделенный стандарт, ", "обычный, ", "выделенный")

-- #deprecated 01.09.2024, not used
function IGS.print(...)
	local args = {...}
	if not IsColor(args[1]) then
		table.insert(args,1,color_white)
	end

	args[#args] = args[#args] .. "\n"
	MsgC(Color(50,200,255), "[IGS] ", unpack(args))
end

function IGS.dprint(...)
	if IGS.DEBUG then
		IGS.prints(...)
	end
end


function IGS.SignPrice(iPrice) -- 10 Alc
	return math.Truncate(tonumber(iPrice) or -1, 2) .. " " .. IGS.C.CURRENCY_SIGN
end

PL_MONEY = PLUR(IGS.C.CurrencyPlurals)
PL_DAYS  = PLUR({"день", "дня", "дней"})

-- #TODO: ОБРАТНАЯ СОВМЕСТИМОСТЬ. НЕ применяется в core.
-- https://forum.gm-donate.net/t/cryptos-igs/1461/6
PL_IGS = PL_MONEY
