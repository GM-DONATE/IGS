local null = function() end
local etoGlavnayaVkladkaBlya = true

hook.Add("IGS.CatchActivities","main",function(activity,sidebar)
	-- Зона прокрутки последних покупок http://joxi.ru/12MQQBlfzPnw2J
	local bg = sidebar:AddPage("Последние покупки")

	-- Панель тегов и готовая кнопка сброса фильтров
	local tagspan = uigs.Create("Panel", bg)
	tagspan:SetWide(activity:GetWide())
	tagspan.Paint = function(s,w,h)
		IGS.S.Panel(s,w,h,nil,nil,nil,true)
	end

	-- сетка https://img.qweqwe.ovh/1487714173294.png
	bg.tags = uigs.Create("DIconLayout", function(tags)
		tags:SetWide(activity:GetWide() - 5 - 5)
		tags:SetPos(5,5)
		tags:SetSpaceX(10)
		tags:SetSpaceY(10)
		tags.Paint = null

		function tags:AddTag(sName,doClick)
			local tag = uigs.Create("igs_button")
			tag:SetTall(18)
			tag:SetText(" " .. sName .. " ") -- костыль для расширения кнопки
			tag:SizeToContents()
			tag.DoClick = doClick

			self:Add(tag)

			tags:InvalidateLayout(true) -- tags:GetTall()
			tagspan:SetTall(tags:GetTall() + 5 + 5)

			local y = tagspan:GetTall()

			-- Расхождение вот тут:
			-- https://img.qweqwe.ovh/1493840355855.png
			-- y = y - 10 -- UPD 2020 t.me/c/1353676159/7888

			bg.categs:SetTall(activity:GetTall() - y - activity.tabBar:GetTall())
			bg.categs:SetPos(0,y)
			return tag
		end
	end, tagspan)

	bg.categs = uigs.Create("igs_panels_layout_list", bg) -- center panel
	bg.categs:DisableAlignment(true)
	bg.categs:SetWide(activity:GetWide())

	-- Раскомментить, если захочу убрать теги
	-- bg.categs:SetTall(activity:GetTall() - activity.tabBar:GetTall())
	-- bg.categs:SetPos(0,y)


	-- category = true
	local cats = {}

	local function addItems(fItemsFilter,fGroupFilter)
		local rows = {}

		for _,GROUP in pairs( IGS.GetGroups() ) do -- name
			if not fGroupFilter or fGroupFilter(GROUP) ~= false then
				local pnl = uigs.Create("igs_group"):SetGroup(GROUP)
				pnl.category = GROUP:Items()[1].item:Category() -- предполагаем, что в одной группе будут итемы одной категории

				table.insert(rows,pnl)
			end
		end

		local check_skip = function(ITEM)
			return ITEM.isnull  -- пустышка
				or ITEM.hidden  -- еще в IGS.WIN.Group
				or ITEM:Group() -- группированные итемы засунуты в группу выше
				or (fItemsFilter and fItemsFilter(ITEM) == false)
		end

		-- не (i)pairs, потому что какой-то ID в каком-то очень редком случае может отсутствовать
		-- если его кто-то принудительно занилит, чтобы убрать итем например.
		-- Хотя маловероятно, но все же
		for _,ITEM in pairs(IGS.GetItems()) do
			if not check_skip(ITEM) then
				local pnl = uigs.Create("igs_item"):SetItem(ITEM)
				pnl.category = ITEM:Category()

				table.insert(rows,pnl)
			end
		end

		for _,pnl in ipairs(rows) do
			bg.categs:Add(pnl,pnl.category or "Разное").title:SetTextColor(IGS.col.TEXT_HARD) -- http://joxi.ru/Y2LqqyBh5BODA6
			cats[pnl.category or "Разное"] = true
		end
	end
	addItems()



	--[[-------------------------------------------------------------------------
		Теги (Быстрый выбор категории)
	---------------------------------------------------------------------------]]
	bg.tags:AddTag("Сброс фильтров",function() bg.categs:Clear() addItems() end)
		:SetActive(true)

	for categ in pairs(cats) do
		bg.tags:AddTag(categ,function(self)
			bg.categs:Clear()

			-- #todo переписать это говнище
			addItems(function(ITEM)
				return self.categ == "Разное" and not ITEM:Category() or (ITEM:Category() == self.categ)
			end,function(GROUP)
				return self.categ == "Разное" and not GROUP:Items()[1].item:Category() or (GROUP:Items()[1].item:Category() == self.categ)
			end)
		end).categ = categ
	end



	--[[-------------------------------------------------------------------------
		Список последних покупок в сайдбаре
	---------------------------------------------------------------------------]]
	IGS.GetLatestPurchases(function(latest_purchases)
		if not IsValid(activity) then return end

		local function addPurchasePanel(v)
			local b = uigs.Create("Panel")
			b:SetTall(IGS.SERVERS.TOTAL > 1 and 100 or 100 - 20)
			b:DockPadding(5,5,5,5)

			local pnl = uigs.Create("Panel", b)
			pnl:Dock(FILL)
			pnl:DockPadding(5,5,5,5)
			pnl.Paint = IGS.S.RoundedPanel
			function pnl:AddRow(sName,value)
				local row = uigs.Create("Panel", pnl)
				row:Dock(TOP)
				row:SetTall(20)
				--:DockMargin(5,5,0,5)
				--row.Paint = IGS.S.RoundedPanel

				-- key
				uigs.Create("DLabel", function(name)
					name:Dock(LEFT)
					name:SetWide(55)
					name:SetText(sName)
					name:SetFont("igs.18")
					name:SetTextColor(IGS.col.TEXT_HARD)
					name:SetContentAlignment(6)
				end, row)

				uigs.Create("DLabel", function(name)
					name:Dock(FILL)
					name:SetText(value)
					name:SetFont("igs.18")
					name:SetTextColor(IGS.col.TEXT_SOFT)
					name:SetContentAlignment(4)
				end, row)
			end

			-- Заголовок услуги. Легко превращается в лейбу
			uigs.Create("DButton", function(name)
				name:Dock(TOP)
				name:SetTall(20)
				name:SetText(IGS.GetItemByUID(v.item):Name())
				name:SetFont("igs.18")
				name:SetTextColor(IGS.col.HIGHLIGHTING)
				name:SetContentAlignment(4)
				name.Paint = null
				name.DoClick = function()
					IGS.WIN.Item(v.item)
				end
			end, b)

			pnl:AddRow("Купил: ",v.nick or "NoName")
			if IGS.SERVERS.TOTAL > 1 then
				pnl:AddRow("На: ",IGS.ServerName(v.server))
			-- else
			-- 	pnl:AddRow("UID: ",v.item)
			end
			pnl:AddRow("До: ",IGS.TimestampToDate(v.expire) or "навсегда")

			bg.side:AddItem(b)
		end

		for _,purchase in ipairs(latest_purchases) do
			local ITEM = IGS.GetItemByUID(purchase.item)
			if not ITEM.isnull then
				addPurchasePanel(purchase)
			end
		end
	end)

	activity:AddTab("Услуги",bg,"materials/icons/fa32/rub.png",etoGlavnayaVkladkaBlya)
end)

-- local p = IGS.UI()
-- timer.Simple(3,function() if IsValid(p) then p:Remove() end end)
