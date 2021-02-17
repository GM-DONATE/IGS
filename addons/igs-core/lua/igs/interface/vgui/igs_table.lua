local PANEL = {}

function PANEL:Init()
	self.columns = {}
	self.lines   = {}

	self.header_tall = 0

	-- Колонки, для которых указаны iWidePx
	self.nonAdjustableSpace = 0
	self.nonAdjustableItems = 0

	self.scroll = uigs.Create("igs_scroll", self)
end

function PANEL:SetTitle(sText)
	self.title = self.title or uigs.Create("DLabel", function(t)
		t:Dock(TOP)
		t:SetTall(20)
		t:SetFont("igs.20")
		t:SetTextColor(IGS.col.TEXT_HARD)
		t:SetContentAlignment(5)
		-- t:SetWrap(true) -- если раскомментить, то не будет работать SetContentAlignment
		t:SetAutoStretchVertical(true)
	end, self)

	self.title:SetText(sText)
end

function PANEL:AddColumn(sName,iWidePx)
	self.columns_panel = self.columns_panel or uigs.Create("Panel", function(p)
		p:SetTall(15)

		self.header_tall = self.header_tall + p:GetTall()
	end, self)

	table.insert(self.columns, uigs.Create("Panel", function(clmn)
		clmn.staticWide = iWidePx

		-- 10 не обязательно. Просто для заметности при отладке
		-- clmn:SetSize(clmn.staticWide or 10, self.columns_panel:GetTall())
		clmn.Paint = function(s,w,h)
			surface.SetDrawColor(IGS.col.HARD_LINE)
			surface.DrawLine(3,h - 1,w - 2,h - 1)

			surface.DrawLine(0,0,0,h)
			surface.DrawLine(w,0,w,h)

			surface.SetFont("igs.15")
			surface.SetTextColor(IGS.col.TEXT_SOFT)
			surface.SetTextPos((w - surface.GetTextSize(sName)) / 2,0)
			surface.DrawText(sName)
		end
	end, self.columns_panel))

	if iWidePx then
		self.nonAdjustableItems = self.nonAdjustableItems + 1
		self.nonAdjustableSpace = self.nonAdjustableSpace + iWidePx
	end

	self:PerformLayout()
end

function PANEL:AddLine(...)
	local rows = {...}

	local iKek = table.insert(self.lines,
		self.scroll:AddItem(uigs.Create("Panel", function(line)
			line:SetTall(18)
			line:Dock(TOP)
			line.columns = {}

			-- self.columns[i]:GetWide()
			for i,val in ipairs(rows) do
				line.columns[i] = uigs.Create("DButton", function(row) -- Было Panel
					row:SetText(val)
					row.DoClick = function() if line.DoClick then line.DoClick(row) end end
					row:SetCursor("arrow")
					row:SetTall( line:GetTall() )
					-- row:SetPos(self.columns[i]:GetPos())
					row.Paint = function(s,w,h)
						surface.SetDrawColor(IGS.col.HARD_LINE)
						surface.DrawLine(3,h - 1,w - 2,h - 1)

						surface.DrawLine(0,0,0,h)
						surface.DrawLine(w,0,w,h)

						surface.SetFont("igs.18")
						surface.SetTextColor(IGS.col.TEXT_HARD)
						surface.SetTextPos((w - surface.GetTextSize(s:GetText())) / 2,0)
						surface.DrawText(s:GetText())
						return true -- override
					end
				end, line)
			end
		end))
	)

	-- self:PerformLayout()
	return self.lines[iKek] -- вставленная строка
end

function PANEL:Clear()
	-- for i,linePan in ipairs(self.lines) do
	-- 	linePan:Remove()
	-- 	table.remove(self.lines,i)
	-- end

	for i = #self.lines,1,-1 do
		local linePan = self.lines[i]
		linePan:Remove()
		table.remove(self.lines,i)
	end
end

PANEL.Paint     = IGS.S.TablePanel
PANEL.PaintOver = IGS.S.Outline

function PANEL:PerformLayout()
	if self.title then
		self.header_tall = self.title:GetTall()
	end

	if self.columns_panel then
		self.columns_panel:SetPos(0,self.header_tall)
		self.columns_panel:SetWide(self:GetWide())

		--PrintTable(self.columns)

		local x = 0
		local cell_wide = (self:GetWide() - self.nonAdjustableSpace) / (#self.columns - self.nonAdjustableItems)
		-- print("#self.columns",#self.columns)
		-- print("self.nonAdjustableItems",self.nonAdjustableItems)
		-- print("self.nonAdjustableSpace",self.nonAdjustableSpace)
		for _,v in ipairs(self.columns) do
			-- print(v,v:GetPos())
			-- print(v:GetSize())
			v:SetPos(x,0)
			v:SetSize(v.staticWide or cell_wide, self.columns_panel:GetTall())

			x = x + (v.staticWide or v:GetWide())
		end

		self.header_tall = self.header_tall + self.columns_panel:GetTall()
	end

	self.scroll:SetPos(0,self.header_tall)
	self.scroll:SetSize(self:GetWide(),self:GetTall() - self.header_tall)

	for _,linePan in ipairs(self.lines) do
		for i,rowPan in ipairs(linePan.columns) do
			rowPan:SetWide(self.columns[i]:GetWide())
			rowPan:SetPos(self.columns[i]:GetPos())
		end
	end
end

vgui.Register("igs_table", PANEL, "Panel")
-- IGS.UI()
