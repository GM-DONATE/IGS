--[[-------------------------------------------------------------------------
	:SetIcon ДОЛЖЕН вызываться ДО :SetName
	а :SetName ДОЛЖЕН вызываться ДО :SetSign
---------------------------------------------------------------------------]]
local PANEL = {}

local function getBottomText(ITEM, bShowDiscounted)
	local iDiscFrom = bShowDiscounted and ITEM.discounted_from

	local iReal = iDiscFrom or ITEM:Price()
	local iCurr = IGS.PriceInCurrency(iReal)

	local real = PL_MONEY(iReal)
	local curr = IGS.SignPrice(iCurr)

	if IGS.IsCurrencyEnabled() then
		return real .. " (" .. curr .. ")"
	else
		return real
	end
end


local font_exists
function PANEL:Init()
	self:SetSize(180,70)

	if !font_exists then
		surface.CreateFont("roboto_15",{
			font     = "roboto",
			extended = true,
			size     = 15,
		})

		surface.CreateFont("roboto_20",{
			font     = "roboto",
			extended = true,
			size     = 20,
		})
	end

	hook.Run("IGS.ItemPanelCreated", self)
end

function PANEL:SetItem(STORE_ITEM)
	self.item = STORE_ITEM

	self:SetIcon(STORE_ITEM:ICON())
	self:SetName(STORE_ITEM:Name())
	-- self:SetPrice(STORE_ITEM:Price())

	self:SetTitleColor(STORE_ITEM:GetHighlightColor()) -- nil

	self:SetSign( "Действ. " .. IGS.TermToStr(STORE_ITEM:Term()) )

	self:SetBottomText( getBottomText(STORE_ITEM, true) )

	hook.Run("IGS.ItemPanelChanged", self)

	return self
end

function PANEL:SetName(sName)
	(self.icon or self):SetTooltip(sName .. (self.item and "\n\n" .. self.item:Description():gsub("\n\n","\n") or ""))

	self.name = self.name or uigs.Create("DLabel", function(lbl)
		lbl:SetTall(20)
		lbl:SetFont("roboto_20")
		lbl:SetTextColor(self.title_color or IGS.col.TEXT_HARD)
	end, self)

	self.name:SetText(sName)

	return self.name
end

function PANEL:SetSign(sSignature)
	self.sign = self.sign or uigs.Create("DLabel", function(lbl)
		lbl:SetTall(15)
		lbl:SetFont("roboto_15")
		lbl:SetTextColor(IGS.col.TEXT_SOFT)
	end, self)

	self.sign:SetText(sSignature)

	return self.sign
end

function PANEL:SetBottomText(sBottomText)
	self.bottom = self.bottom or uigs.Create("DLabel", function(lbl)
		lbl:SetTall(15)
		lbl:SetFont("roboto_15")
		lbl:SetTextColor(IGS.col.TEXT_SOFT)
		lbl:SetContentAlignment(5)
		-- lbl:SetWrap(true)
		-- lbl:SetAutoStretchVertical(true)
	end, self)

	self.bottom:SetText(sBottomText)

	return self.bottom
end

-- TODO снизу в рамочку и DOCK RIGHT вместе с док фильным сроком
-- function PANEL:SetPrice(iPrice)
-- 	self.price = iPrice
-- 	return self
-- end

function PANEL:SetIcon(sIco,bIsModel) -- :SetIcon() для сброса
	if !sIco then return self end

	if bIsModel and !file.Exists(sIco, "GAME") then
		sIco = "models/props_lab/huladoll.mdl"
	end

	if !self.icon then
		local icobg = uigs.Create("Panel", self)
		icobg:SetSize(40,40)
		icobg:SetPos(2,2)
		icobg.Paint = IGS.S.RoundedPanel

		self.icon = bIsModel and uigs.Create("DModelPanel", function(mdl)
			mdl:Dock(FILL)
			mdl:DockMargin(2,2,2,2)
			mdl:SetModel(sIco)

			local mn, mx = mdl.Entity:GetRenderBounds()
			local size = 0
			size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
			size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
			size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

			mdl:SetFOV(30)
			mdl:SetCamPos(Vector(size, size, size))
			mdl:SetLookAt((mn + mx) * 0.5)
			mdl.LayoutEntity = function() return false end
		end, icobg)

		-- НЕ моделька (Ссылка на иконку)
		or

		uigs.Create("igs_wmat", function(ico)
			ico:Dock(FILL)
			ico:DockMargin(2,2,2,2)
		end, icobg)
	end

	if bIsModel then
		self.icon:SetModel(sIco)
	else
		self.icon:SetURL(sIco)
	end

	return self
end

function PANEL:DoClick()
	IGS.WIN.Item(self.item:UID()) -- Обязательно предварительно SetItem
end

function PANEL:PerformLayout()
	if self.icon then
		local x = 2 + 40 + 5
		self.name:SetPos(x, 2)
		self.name:SetWide(self:GetWide() - x - 2)
	else
		self.name:SetPos(5, 2)
		self.name:SetWide(self:GetWide() - 2 - 5)
	end

	local nx,ny = self.name:GetPos() -- n = name
	self.sign:SetPos(nx, ny + self.name:GetTall() + 2)
	self.sign:SetWide(self.name:GetWide())

	if self.bottom then
		self.bottom:SetPos(2, 2 + 40 + 9)
		self.bottom:SetWide(self:GetWide() - 2 - 2)
	end

	if self.title_color then
		self.name:SetTextColor(self.title_color)
	end
end

function PANEL:SetTitleColor(c)
	self.title_color = c
end


function PANEL:Paint(w,h)
	IGS.S.RoundedPanel(self, w,h)

	if self.bottom then
		local bx,by = self.bottom:GetPos()

		surface.SetDrawColor( IGS.col.HARD_LINE )
		surface.DrawLine(bx + 5,by - 2,bx + self.bottom:GetWide() - 10,by - 2)
	end

	return true
end

--[[-------------------------------------------------------------------------
	Жто все нужно было для отрисовки лейбла с размером скидки
	Проблема оказалась на этапе рисования повернутого текста
	Набросы: https://gist.github.com/AMD-NICK/7f2aeb674763fe91c2d0668f84357f2e
	Карточка: https://trello.com/c/Zx6qTzBn/303

	Color(220,30,70) -- Штуки за биркой
	Color(255,30,85) -- Цвет бирки
	Color(255,255,255) -- Текст бирки
	draw.RotatedText
---------------------------------------------------------------------------]]
-- local function draw_TextRotated(text, x, y, color, font, ang)
-- 	surface.SetFont(font)
-- 	surface.SetTextColor(color)
-- 	surface.GetTextSize(text)

-- 	local m = Matrix()
-- 	m:SetAngles(Angle(0, ang, 0))
-- 	m:SetTranslation(Vector(x, y, 0))

-- 	cam.PushModelMatrix(m)
-- 		surface.SetTextPos(0, 0)
-- 		surface.DrawText(text)
-- 	cam.PopModelMatrix()
-- end

-- local function draw_Poly(tVertices,tColor_)
-- 	surface.SetDrawColor(tColor_ or color_white)
-- 	draw.NoTexture()
-- 	surface.DrawPoly(tVertices)
-- end

-- 2250, 3000 = 25
-- local function diffNumsPercent(a, b)
-- 	return math.ceil(100 - a / (b / 100))
-- end

-- Вс. функцию можно назвать пиздецкой костылякой
function PANEL:PaintOver(w,h)
	if self.item and self.item.discounted_from then
		-- local disc_price = self.item.discounted_from
		-- local disc = diffNumsPercent(disc_price, self.item:Price())

		surface.SetDrawColor(IGS.col.TEXT_SOFT)

		-- surface.DrawRect(w - 60,0,25,2)
		-- surface.DrawRect(w - 2,h - 10 - 25,2,25)

		-- draw_Poly({
		-- 	{x = w - 60,y = 2},
		-- 	{x = w - 60 + 25,y = 2},
		-- 	{x = w - 2,y = h - 10 - 25},
		-- 	{x = w - 2,y = h - 10},
		-- }, Color(255,30,85, 255))

		-- draw_TextRotated("-" .. disc .. "%", 100, -50, Color(0,255,0), "roboto_20", 9)
		-- surface.SetTextColor(50,200,50)
		-- surface.SetFont("roboto_20")

		-- local x,y = self:GetPos()
		-- draw.RotatedText("-" .. disc .. "%", x, y, 1, 1, 9)
		-- draw.RotatedText("-" .. disc .. "%", x, y, 3)
		-- draw.TextRotated("-" .. disc .. "%", 0, 0, 3)
		-- draw.RotatedTextOnPanel("-" .. disc .. "%", 0, 0, 5, self)

		local tw = draw.SimpleText(
			getBottomText(self.item, false),"roboto_15",
			w / 2,h - 18 - 2 - 10,IGS.col.HIGHLIGHTING,TEXT_ALIGN_CENTER
		)

		local start_x, start_h = (w - tw) / 2 * 0.8, h - (20 / 2)
		surface.DrawLine(start_x, start_h,w - start_x, start_h)
	end
end


vgui.Register("igs_item",PANEL,"DButton")

-- IGS.CloseUI()
-- IGS.UI()
