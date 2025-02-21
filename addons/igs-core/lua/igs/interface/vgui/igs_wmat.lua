-- 2025.01.03 сделан невероятный рефакторинг, который упростил код до размера мухи

local PANEL = {}

local default_mater = Material("models/effects/portalrift_sheet")
function PANEL:Paint(w, h)
	surface.SetDrawColor( IGS.col.ICON )
	surface.SetMaterial( self.material or (self.url and matex.now(self.url)) or matex.now(IGS.C.DefaultIcon) or default_mater )
	surface.DrawTexturedRect(0, 0, w, h)
end

-- Для SetIcon mode == "material", например
function PANEL:SetMaterial(sMaterial) -- "models/debug/debugwhite"
	self.material = sMaterial and Material(sMaterial, "noclamp smooth") or nil
end

-- Укажите nil/false для сброса
function PANEL:SetURL(sUrl)
	self.url = sUrl
end

vgui.Register("igs_wmat", PANEL, "Panel")
-- IGS.UI()
