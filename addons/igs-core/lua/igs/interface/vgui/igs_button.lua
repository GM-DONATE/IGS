local PANEL = {}

function PANEL:Init()
	self:SetTextColor(IGS.col.HIGHLIGHTING)
	self:SetFont("igs.18")
end

-- Как блять по человечески оверрайднуть эту хуетоту?
-- function PANEL:SetText(text)
-- 	self.BaseClass:SetText(" " .. text .. " ") -- чтобы при SizeToContent было не вплотную к стенкам
-- end

function PANEL:SetActive(bActive)
	self.active = bActive

	self:SetTextColor(self.active and IGS.col.TEXT_ON_HIGHLIGHT or IGS.col.HIGHLIGHTING)
end

function PANEL:IsActive()
	return self.active
end

function PANEL:Paint(w,h)
	draw.RoundedBox(4,0,0,w,h,IGS.col.HIGHLIGHTING) -- outline

	if not self.active then
		draw.RoundedBox(4,1,1,w - 2,h - 2,IGS.col.PASSIVE_SELECTIONS) -- bg TODO изменить, сделав как-то прозрачным
	end
end

vgui.Register("igs_button",PANEL,"DButton")

-- IGS.UI()
