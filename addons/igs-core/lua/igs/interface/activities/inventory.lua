local function loadTab(activity,sidebar,dat)
	local bg = sidebar:AddPage("Действия над итемом")
	IGS.AddTextBlock(bg.side, nil, #dat > 0 and
		"Выберите предмет, чтобы получить по нему список действий" or

		"Купленные предметы будут находится здесь." ..
		"\n\nБлагодаря инвентарю вы можете поделиться покупкой со своим другом, у которого не хватает денег на покупку услуги. " ..
			"Просто купите ее вместо него и бросьте на пол. После активации предмета он появится у него в инвентаре." ..
		"\n\nДобрые саморитяне используют инвентарь для устраивания классных конкурсов. " ..
			"Они набивают свой инвентарь предметами, а затем при каких-то условиях их раздают"
	)

	bg.OnRemove = function()
		hook.Remove("IGS.PlayerPurchasedItem","UpdateInventoryView")
	end

	local act_tall = activity:GetTall() - activity.tabBar:GetTall()

	local infpan = uigs.Create("igs_iteminfo", function(p)
		p:SetSize(300,act_tall) -- Dock(LEFT) SetWide(300)
		p:SetPos(0,0)
		p:SetIcon()
		p:SetName("")
		p:SetDescription("Здесь будет отображена информация о вашей покупке, когда вы ее сделаете")
	end, bg)

	local scr = uigs.Create("igs_scroll", bg)
	scr:SetSize(activity:GetWide() - infpan:GetWide(),act_tall)
	scr:SetPos(infpan:GetWide(),0) -- Dock(FILL)

	IGS.AddTextBlock(scr,"Ваш инвентарь","Что-то тут пустовато. Надо бы купить че-нить, правда?")

	scr:AddItem( uigs.Create("DIconLayout", function(icons)
		icons:SetWide(scr:GetWide())
		icons:SetSpaceX(2)
		icons:SetSpaceY(2)
		icons.Paint = function() end

		local function removeFromCanvas(itemPan)
			if IsValid(itemPan) then -- не закрыли окно
				bg.side:Reset()
				infpan:Reset()
				itemPan:Remove()
			end
		end

		function icons:AddItem(ITEM, dbID)
			local item = icons:Add("igs_item")
			item:SetSize(icons:GetWide(),60)
			item:SetIcon(ITEM:ICON())
			item:SetName(ITEM:Name())
			item:SetSign("Действует " .. IGS.TermToStr(ITEM:Term()))
			item.DoClick = function()
				infpan:Reset()
				infpan:SetIcon(ITEM:ICON())
				infpan:SetName(ITEM:Name())
				infpan:SetImage(ITEM:IMG())
				infpan:SetSubNameButton(ITEM:Group() and ITEM:Group():Name(), function()
					IGS.WIN.Group(ITEM:Group():UID())
				end)
				infpan:SetDescription(ITEM:Description())
				infpan:SetInfo(IGS.FormItemInfo(ITEM))


				bg.side:Reset()

				local act_btn = IGS.AddButton(bg.side, "",function()
					IGS.ProcessActivate(dbID, function(ok) -- iPurchID, sMsg_
						if !ok then return end

						removeFromCanvas(item)
					end)
				end).button
				act_btn:SetActive(true)
				act_btn:SetText("Активировать")

				-- if !IGS.C.Inv_AllowDrop then return end
				IGS.AddButton(bg.side,"Бросить на пол",function()
					IGS.DropItem(dbID,function()
						removeFromCanvas(item)
					end)
				end)
			end
		end

		for _,v in ipairs(dat) do
			icons:AddItem(v.item, v.id)
		end

		hook.Add("IGS.PlayerPurchasedItem","UpdateInventoryView",function(_, ITEM, invDbID)
			icons:AddItem(ITEM, invDbID)
		end)


	end) )

	scr:AddItem(uigs.Create("Panel", function(end_margin)
		end_margin:SetTall(5)
	end))

	activity:AddTab("Инвентарь",bg,"materials/icons/fa32/cart-arrow-down.png")
end

hook.Add("IGS.CatchActivities","inventory",function(activity,sidebar)
	if !IGS.C.Inv_Enabled then return end

	IGS.GetInventory(function(items)
		if !IsValid(sidebar) then return end
		loadTab(activity,sidebar,items)
	end)
end)

-- IGS.UI()
