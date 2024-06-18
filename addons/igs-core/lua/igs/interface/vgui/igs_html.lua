local PANEL = {}

function PANEL:Init()
	local c = IGS.col.HIGHLIGHT_INACTIVE
	self.text_color = Color(c.r,c.g,c.b,c.a)
end

local LOADING_TEXT = IGS.GetPhrase("loading")
local ICO          = Material("materials/icons/fa32/usd.png", "smooth")

function PANEL:Paint(w,h)
	self.text_color.a = Lerp( (math.sin(CurTime() * 5) + 1) / 2 ,0,255) -- Alpha

	-- ИКОНКА
	surface.SetDrawColor(self.text_color)
	surface.SetMaterial(ICO)
	local y = (h - 50) / 2
	surface.DrawTexturedRect((w - 50) / 2,y - 10,50,50)
	y = y + 50 -- центральная точка между иконкой и текстом

	-- ТЕКСТ
	surface.SetTextColor(self.text_color)
	surface.SetFont("igs.24") -- 40
	local tw = surface.GetTextSize(LOADING_TEXT)
	surface.SetTextPos((w - tw) / 2,y + 10)
	surface.DrawText(LOADING_TEXT)
end

vgui.Register("igs_html",PANEL,"HTML")
