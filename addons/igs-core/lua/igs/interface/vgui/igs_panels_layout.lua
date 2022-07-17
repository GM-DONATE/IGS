-- http://joxi.ru/Vm6bbvlipXRZmZ

-- TODO переписать. СНОВА. Чтобы норм вставляло эллементы с разной шириной, не выходя за пределы строки
local PANEL = {}

function PANEL:Init()
	self.name  = "Untitled"
	self.panels = {} -- line, panels

	self.current_line = 1

	--self.elements_tall = 80
end

function PANEL:SetName(sName)
	if not sName then return end

	self.name = sName

	self.title = self.title or uigs.Create("DLabel", function(title)
		title:SetSize(self:GetWide() - 10 - 10,30)
		title:SetPos(10,10)
		title:SetFont("igs.24")

		-- 30 is label height, 10 is margins
		self.last_y = 10 + 30
	end, self)

	self.title:SetText(self.name)

	return self.title
end

function PANEL:GetLineWide(iLine)
	local w = 0
	for _,pan in ipairs(self.panels[iLine]) do
		w = w + pan:GetWide()
	end

	-- 10 - размер отступа
	return w + (#self.panels[iLine] - 1) * 10
end

-- Возвращает панели в строке
-- function PANEL:GetLine(iLine)
-- 	return self.panels[iLine]
-- end

function PANEL:GetCurrentLine()
	return self.panels[self.current_line]
end

-- Y для следующего ряда панелек
function PANEL:GetY()
	local y = (#self.panels - 1) * (self.elements_tall + 10) -- в #self.panels кол-во линий

	return self.title and (y + 10 + 30) or y
end

function PANEL:Add(panel)
	panel:SetParent(self)

	-- Все эллементы в лэйауте должны быть одинаковой высоты, хотя могут быть разной ширины
	self.elements_tall = self.elements_tall or panel:GetTall()

	self.panels[self.current_line] = self.panels[self.current_line] or {}
	table.insert(self.panels[self.current_line],panel)

	local line_wide = self:GetLineWide(self.current_line)

	local borders = not self.disabled_align and (self:GetWide() - line_wide) / 2 -- отступы по сторонам
	local line_panels = self:GetCurrentLine()

	for i,pan in ipairs(line_panels) do

		-- Если первая панель, то делаем отступ, чтобы в конце все было по середине
		if i == 1 then
			pan:SetPos(self.disabled_align and 10 or borders, self:GetY())
		else
			local x,y = line_panels[i - 1]:GetPos()
			pan:SetPos(x + line_panels[i - 1]:GetWide() + 10,y)
		end
	end

	-- Если размер существующих компонентов + еще один <= размер лэйаута, то вставляем эллемент
	-- if panel.tag then
	-- 	print("\n\n")
	-- 	print("self:GetWide()",self:GetWide())
	-- 	print("panel:GetWide()",panel:GetWide())
	-- 	print("line_wide",line_wide)
	-- 	print(panel)
	-- end
	if line_wide + 10 + panel:GetWide() > self:GetWide() then
		-- if panel.tag then
		-- 	PrintTable(self.panels)
		-- 	print("Перешли на след. ряд")
		-- 	--panel:SetPos(self.disabled_align and 10 or borders, self:GetY())
		-- end
		self.current_line = self.current_line + 1
	end

	self:PerformLayout()
end

function PANEL:PerformLayout()
	self:SetHeight(self:GetY() + self.elements_tall) -- + 10 margin
end

-- Отключает центрирование эллементов
function PANEL:DisableAlignment(bDisable)
	self.disabled_align = bDisable
end


vgui.Register("igs_panels_layout", PANEL, "Panel")
--IGS.UI()
