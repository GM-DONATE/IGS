local PANEL = {}

function PANEL:Init()
	self:DockPadding(0,24,0,0)

	self.lblTitle:SetPos(5,3)
	self.lblTitle:SetColor(IGS.col.TEXT_HARD)

	self.btnClose:SetTextColor(IGS.col.HIGHLIGHTING)
	self.btnClose:SetText("✕")
	self.btnClose:SetSize(30, 24)
	self.btnClose.Paint = function() end
	-- self.btnClose.DoClick = function() self:Close() end

	-- self:SetBackgroundBlur(false)
	self:SetTitle("")

	-- self.btnClose:SetVisible(false)
	self.btnMaxim:SetVisible(false)
	self.btnMinim:SetVisible(false)

	self.lblTitle:SetFont("igs.20")
end

local locations = {}
function PANEL:SaveLocation(panel_uid)
	locations[panel_uid] = {self:GetPos()}
end

function PANEL:RestoreLocation(panel_uid)
	if locations[panel_uid] then
		local x,y = unpack(locations[panel_uid])
		self:SetPos(
			math.Clamp(x,0,ScrW() - 10),
			math.Clamp(y,0,ScrH() - 10)
		) -- на случай, если уменьшат разрешение, чтобы не исчезло у краев
		locations[panel_uid] = nil
	else
		self:Center()
	end
end

function PANEL:RememberLocation(panel_uid)
	self.remember_uid = panel_uid
end


function PANEL:Close(...)
	surface.PlaySound("ambient/water/rain_drip3.wav")
	self.BaseClass.Close(self, ...)
	if self.remember_uid then
		self:SaveLocation(self.remember_uid)
	end
end

function PANEL:GetTitleHeight()
	return 24 -- close button H
end

function PANEL:Paint(w,h)
	if self.m_bBackgroundBlur then
		Derma_DrawBackgroundBlur(self, self.m_fCreateTime)
	end

	IGS.S.Frame(self,w,h)
	return true
end

function PANEL:PaintOver(w,h)
	IGS.S.Outline(self,w,h) -- через = не работало
end

function PANEL:Focus()
	local panels = {}
	self:SetBackgroundBlur(true)
	for _, v in ipairs(vgui.GetWorldPanel():GetChildren()) do
		if v:IsVisible() and (v ~= self) then
			panels[#panels + 1] = v
			v:SetVisible(false)
		end
	end
	self._OnClose = self.OnClose
	self.OnClose = function()
		for _, v in ipairs(panels) do
			if IsValid(v) then
				v:SetVisible(true)
			end
		end

		self:_OnClose()
	end
end

function PANEL:PerformLayout()
	self.lblTitle:SizeToContents()
	self.btnClose:SetPos(self:GetWide() - 30, 0)

	if self.remember_uid and not self.restored then
		self.restored = true
		self:RestoreLocation(self.remember_uid)
	end
end

vgui.Register("igs_frame",PANEL,"DFrame")
-- IGS.UI()
