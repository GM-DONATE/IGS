-- Алгоритм и описание репитера: https://gist.github.com/5e5afdff55cc1f70f1c1a459b8487943

IGS.REPEATER = IGS.REPEATER or IGStack()
local R = IGS.REPEATER

function R:IsEmpty() -- внешка
	return self:isempty()
end
--------------------------------------------------------

function R:Query(REQ)
	IGS.WrapQuery(REQ[1], REQ[2], REQ[3])
end

function R:ProcessNextQuery()
	local NEXT_REQ = self:lpop()
	if NEXT_REQ then
		self:Query(NEXT_REQ) -- один за другим, пока не закончатся
	else -- ставится ok для IGS
		hook.Run("IGS.RepeaterEmpty")
	end
end

function R:SafeQuery(sMethod, tParams, fOnSuccess)
	local REQ = {sMethod, tParams, fOnSuccess}

	if self:IsEmpty() then
		self:Query(REQ)
	else
		self:rpush(REQ)
	end
end

--------------------------------------------------------

-- func > iter
-- Сколько раз функция перевыполнялась
local repeats_counter = setmetatable({}, {__mode = "k"})

local SHOULD_REPEAT_CASES = {
	["too_many_requests"] = true,
	["http_error"] = true,

	-- стоит ли? Что если метод сломался на постоянке?
	["invalid_response_format"] = true,
}

-- Нужно, чтобы запросы без колбэка не выдавали ошибку
-- https://t.me/c/1353676159/12486
local function getBlankCallback(sMethod)
	return function()
		print("[IGS] Редкое сообщение. Выполнился " .. sMethod .. " без колбэка, который сначала 'упал'")
	end
end

-- Переносит запрос в конец очереди или отбрасывает его
hook.Add("IGS.OnApiError", "repeater", function(sMethod, error_uid, tParams, fOnSuccess)
	if SHOULD_REPEAT_CASES[error_uid] then
		fOnSuccess = fOnSuccess or getBlankCallback(sMethod)

		local try = (repeats_counter[fOnSuccess] or 0) + 1
		repeats_counter[fOnSuccess] = try

		if try <= 15 then
			-- Следующие запросы теперь будут добавляться в очередь, а не выполняться
			-- Ниже таймер, который скоро начнет их обработку
			R:rpush({sMethod, tParams, fOnSuccess})
		end

		-- Был burst запросов и хук вызвался дважды
		if not timer.Exists("IGS_REPEATER") then
			IGS.dprint("Ошибка выполнения запроса: " .. error_uid .. ". Запущен репитер")
			timer.Create("IGS_REPEATER", 10, 1, function() R:ProcessNextQuery() end)
		end
	else
		-- Антизависание при
		-- [успешный > неуспешный > успешный]
		-- https://img.qweqwe.ovh/1565285856105.png
		R:ProcessNextQuery()
	end
end)

-- Вырубает таймер, выполняет последовательно оставшиеся запросы
hook.Add("IGS.OnApiSuccess", "repeater", function()
	-- Это каллбэк внутри успешного хука, тоесть GMD заработал
	-- и по логике остальные запросы выполнятся корректно
	-- Если какой-то все же даст сбой, то снова заработает таймер
	R:ProcessNextQuery() -- one by one
end)
