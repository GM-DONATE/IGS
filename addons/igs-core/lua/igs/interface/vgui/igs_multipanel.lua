--[[-------------------------------------------------------------------------
Панель, на которой можно разместить несколько других и переключаться между ними
Используется в igs_tabbar и может использоваться по отдельности

Обращаем внимание на pnl:OnOpen()
---------------------------------------------------------------------------]]

local PANEL = {}

function PANEL:Init()
	self.Panels = {}
end

function PANEL:AddPanel(panel,bActive)
	panel:SetSize(self:GetWide(),self:GetTall())
	panel:SetVisible(false)
	panel:SetParent(self)
	-- panel.Paint = function(s,w,h) end -- АХТУНГ. Уже дважды на грабли встал
	-- Не понимал, почему не добавляется панель. Потом дошло, что этот хук ее просто прячет

	panel.ID = table.insert(self.Panels,panel)

	if (bActive) then
		self:SetActivePanel(panel.ID)
	end

	return panel.ID
end

function PANEL:SetActivePanel(iID)
	for i,pnl in ipairs(self.Panels) do
		pnl.Active = iID == i

		if (pnl:IsVisible()) then
			pnl:Dock(NODOCK)
			pnl:SetVisible(false)
		end

		if (iID == i) then
			pnl:SetVisible(true)
			pnl:DockMargin(0, 0, 0, 0)
			pnl:Dock(FILL)

			if pnl.OnOpen then
				pnl:OnOpen()
			end
		end
	end
end

function PANEL:GetActivePanel()
	for i,pnl in ipairs(self.Panels) do
		if pnl.Active then
			return pnl
		end
	end
end

vgui.Register("igs_multipanel", PANEL, "Panel")
-- IGS.UI()
