--[[-------------------------------------------------------------------------
	Через этот файл невозможно повсеместно изменить скин.
	Да и вообще, все в говно на самом деле, но мне лень уже делать все правильно.
	Это куча геммора, который, скорее всего, никому не нужен
---------------------------------------------------------------------------]]

IGS.S = IGS.S or {}

IGS.S.COLORS = {
	FRAME_HEADER        = Color(255,255,255), -- Фон верхушки фреймов в т.ч. пополнения счета и т.д. https://img.qweqwe.ovh/1491950958825.png
	ACTIVITY_BG         = Color(255,255,255), -- Фон в каждой вкладке (основной) https://img.qweqwe.ovh/1509370647204.png
	TAB_BAR             = Color(250,250,250), -- Фон таб бара https://img.qweqwe.ovh/1509370669492.png

	PASSIVE_SELECTIONS  = Color(240,240,240), -- Фон панели тегов, цвет кнопки с балансом, верхушки таблиц, не выделенные кнопки https://img.qweqwe.ovh/1509370720597.png
	INNER_SELECTIONS    = Color(255,255,255), -- Фон иконок на плашках, фон панелек последних покупок... https://img.qweqwe.ovh/1509370766148.png

	SOFT_LINE           = Color(240,240,240), -- Линия между секциями, типа "Информация" и "Описание" в инфе об итеме
	HARD_LINE           = Color(200,200,200), -- Обводки панелей

	HIGHLIGHTING        = Color(0,122,255),   -- Обводка кнопок, цвет текста не активной кнопки
	HIGHLIGHT_INACTIVE  = Color(160,160,160), -- Цвет иконки неактивной кнопки таббара, мигающая иконка на фрейме помощи https://img.qweqwe.ovh/1509371884592.png

	TEXT_HARD           = Color(0,0,0),       -- Заголовки, выделяющиеся тексты https://img.qweqwe.ovh/1509372019687.png
	TEXT_SOFT           = Color(140,140,150), -- Описания, значения чего-то
	TEXT_ON_HIGHLIGHT   = Color(255,255,255), -- Цвет текста на выделенных кнопках

	LOG_SUCCESS         = Color(76,217,100),  -- В логах пополнения цвет успешных операций
	LOG_ERROR           = Color(220,30,70),   -- В логах пополнения цвет ошибок
	LOG_NORMAL          = Color(0,0,0),       -- В логах пополнения обычные записи

	ICON                = Color(255,255,255), -- цвет иконок на плашечках
}

-- Попытки сделать темный скин интерфейса
-- IGS.S.COLORS = {
-- 	FRAME_HEADER        = Color(23,23,23),
-- 	ACTIVITY_BG         = Color(13,13,13),
-- 	TAB_BAR             = Color(23,23,23),

-- 	PASSIVE_SELECTIONS  = Color(23,23,23),
-- 	INNER_SELECTIONS    = Color(23,23,23),

-- 	SOFT_LINE           = Color(50,50,50),
-- 	HARD_LINE           = Color(66,66,66),

-- 	HIGHLIGHTING        = Color(230,130,35),
-- 	HIGHLIGHT_INACTIVE  = Color(130,130,130),

-- 	TEXT_HARD           = Color(255,255,255),
-- 	TEXT_SOFT           = Color(140,140,150),
-- 	TEXT_ON_HIGHLIGHT   = Color(255,255,255),

-- 	LOG_SUCCESS         = Color(76,217,100),
-- 	LOG_ERROR           = Color(255,45,85),
-- 	LOG_NORMAL          = Color(140,140,150),

-- 	ICON                = Color(255,255,255),
-- }

IGS.col = IGS.S.COLORS

-- https://img.qweqwe.ovh/1486557631077.png
IGS.S.Panel = function(s,w,h,lL,tL,rL,bL)
	draw.RoundedBox(0,0,0,w,h,IGS.col.PASSIVE_SELECTIONS) -- bg

	surface.SetDrawColor(IGS.col.HARD_LINE) -- outline

	if lL then surface.DrawLine(0,0,0,h) end -- left line
	if tL then surface.DrawLine(0,0,w,0) end -- top line
	if rL then surface.DrawLine(w,0,w,h) end -- right line
	if bL then surface.DrawLine(0,h - 1,w,h - 1) end -- bottom line
end

-- https://img.qweqwe.ovh/1486557676799.png
IGS.S.RoundedPanel = function(s,w,h)
	draw.RoundedBox(3,0,0,w,h,        IGS.col.HARD_LINE) -- outline
	draw.RoundedBox(3,1,1,w - 2,h - 2,IGS.col.INNER_SELECTIONS) -- bg

	return true
end

-- igs\vgui\igs_frame.lua
IGS.S.Frame = function(s,w,h)
	draw.RoundedBox(0,0,0,w,h,IGS.col.ACTIVITY_BG) -- bg

	-- /header
	local th = s:GetTitleHeight()
	draw.RoundedBox(0,0,0,w,th,IGS.col.FRAME_HEADER)
	surface.SetDrawColor(IGS.col.HARD_LINE)
	surface.DrawLine(0,th - 1,w,th - 1)
	-- \header
end

-- igs\vgui\igs_table.lua
IGS.S.TablePanel = function(s,w,h)
	if s.header_tall then
		IGS.S.Panel(s,w,s.header_tall) -- header
	end
end

-- igs_table, igs_frame
IGS.S.Outline = function(s,w,h)
	surface.SetDrawColor(IGS.col.HARD_LINE)

	-- https://img.qweqwe.ovh/1486830692390.png
	surface.DrawLine(0,h,0,0)
	surface.DrawLine(0,0,w,0)
	surface.DrawLine(w - 1,0,w - 1,h)
	surface.DrawLine(w,h - 1,0,h - 1)
end
