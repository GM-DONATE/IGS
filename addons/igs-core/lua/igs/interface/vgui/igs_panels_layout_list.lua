local PANEL = {}

function PANEL:Init()
	-- categ_name > categpan
	self.list = {}
end

-- Одиночное добавление
function PANEL:Add(panel,sCategory)
	local cat = sCategory or "Разное"

	if not self.list[cat] then
		self.list[cat] = uigs.Create("igs_panels_layout", self)
		self.list[cat]:SetWide(650)
		self.list[cat]:SetName(sCategory)
		self.list[cat]:DisableAlignment(self.disabled_align)

		self:AddItem(self.list[cat])
	end

	self.list[cat]:Add(panel)

	return self.list[cat]
end

-- Отключает центрирование эллементов во всех панелях лэйаута
function PANEL:DisableAlignment(bDisable)
	self.disabled_align = bDisable
end

function PANEL:Clear()
	for _,panel in pairs(self.list) do -- categ
		panel:Remove()
	end

	self:Init()
end

vgui.Register("igs_panels_layout_list", PANEL, "igs_scroll")
-- IGS.UI()
