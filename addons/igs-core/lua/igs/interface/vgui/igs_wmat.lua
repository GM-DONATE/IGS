--[[
Если ссылку обновить, то картинка обновится
Если размер панели изменится, то картинка адаптируется
]]

local PANEL = {}

local default_matex
function PANEL:Init()
	if not default_matex then
		-- print("Loading default matex")
		default_matex = matex.url(IGS.C.DefaultIcon)
	end
end

function PANEL:Think() -- ожидание загрузки matex материала. Для SetURL
	if self.matex and self.matex.material then
		self.material = self.matex.material
		self.matex = nil
	end
end

function PANEL:Paint(w, h)
	local mater = self.material or (default_matex and default_matex.material)
	if mater then
		surface.SetDrawColor( IGS.col.ICON )
		surface.SetMaterial( mater )
		surface.DrawTexturedRect(0, 0, w, h)
	end
end

function PANEL:SetMaterial(sMaterial) -- "models/debug/debugwhite"
	self.material = sMaterial and Material(sMaterial, "noclamp smooth") or nil
end

function PANEL:SetURL(sUrl)
	if not sUrl then
		self.matex = nil -- fallback to default
		return
	end

	-- print("igs_wmat:SetURL('" .. sUrl .. "') size: ", self:GetWide())

	local url_resized = string.format(IGS.C.ImgProxyPattern or "https://imgkit.gmod.app/?image=%s&size=%d", sUrl:URLEncode(), self:GetWide())
	self.matex = matex.url( url_resized )
	self.url = sUrl
	self.size = self:GetWide()
end

function PANEL:PerformLayout(new_w) -- size changed
	-- print("igs_wmat:PerformLayout()")

	-- Если есть что обновлять и есть смысл обновлять (иконка расширилась)
	if self.url and new_w > (self.size or 0) then
		self:SetURL(self.url)
	end
end

vgui.Register("igs_wmat", PANEL, "Panel")
-- IGS.UI()
