local function getSpacePanel()
	return uigs.Create("Panel", function(self)
		self:Dock(TOP)
		self:SetTall(3)
	end)
end

function IGS.WIN.Group(sGroupUID)
	local GROUP = IGS.GetGroup(sGroupUID)
	assert(GROUP, "Incorrect group: " .. tostring(sGroupUID))

	surface.PlaySound("ambient/weather/rain_drip1.wav")

	return uigs.Create("igs_frame", function(bg)
		bg:SetTitle(GROUP:Name())
		bg:MakePopup()

		local cellW,cellH -- не изменяется в зависимости от контента
		function bg:AddIGSItem(ITEM, nameInGroup)
			local it = uigs.Create("igs_item"):SetItem(ITEM)
			it:SetName(nameInGroup or ITEM:Name())

			if not cellW then
				cellW,cellH = it:GetSize()
			end

			it:SetSize(cellW * 1.3, cellH)
			it.DoClick = function()
				-- bg:Close()
				IGS.WIN.Item(ITEM:UID())
			end

			bg.scroll:AddItem(it)
		end

		bg.scroll = uigs.Create("igs_scroll", bg)
		bg.scroll:Dock(FILL)
		bg.scroll:SetPadding(6)


		bg.scroll:AddItem( getSpacePanel() ) -- из-за паддинга #1
		for _,v in pairs(GROUP:Items()) do
			local ITEM = v.item
			if v.item:CanSee( LocalPlayer() ) then -- еще в main_cl
				bg:AddIGSItem(ITEM, v.name)
			end
		end
		bg.scroll:AddItem( getSpacePanel() ) -- из-за паддинга #2

		-- or: https://t.me/c/1353676159/21116
		bg:SetSize((cellW or 220) * 1.3, 300)
		bg:RememberLocation("igs_group")
	end)
end
-- IGS.UI()
