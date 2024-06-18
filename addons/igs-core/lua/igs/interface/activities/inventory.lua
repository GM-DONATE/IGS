local function loadTab(activity,sidebar,dat)
	local bg = sidebar:AddPage(IGS.GetPhrase("invitemact"))
	IGS.AddTextBlock(bg.side, nil, #dat > 0 and
		IGS.GetPhrase("invchoose") or IGS.GetPhrase("invchooselong"))

	bg.OnRemove = function()
		hook.Remove("IGS.PlayerPurchasedItem","UpdateInventoryView")
	end

	-- local act_tall = activity:GetTall() - activity.tabBar:GetTall()

	local infpan = uigs.Create("igs_iteminfo", function(p)
		-- p:SetSize(300,act_tall) -- \/
		-- p:SetPos(0,0)
		p:Dock(LEFT) p:SetWide(300)
		p:SetIcon(IGS.C.DefaultIcon)
		p:SetName("")
		p:SetDescription(IGS.GetPhrase("invinfofpurc"))
	end, bg)

	local scr = uigs.Create("igs_scroll", bg)
	scr:Dock(FILL) scr:SetWide(activity:GetWide() - infpan:GetWide())
	-- scr:SetSize(activity:GetWide() - infpan:GetWide(),act_tall)
	-- scr:SetPos(infpan:GetWide(),0)

	IGS.AddTextBlock(scr, IGS.GetPhrase("yourinv"), IGS.GetPhrase("yourinvisempty"))

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
			item:SetSign(IGS.GetPhrase("validto") .. " " .. IGS.TermToStr(ITEM:Term()))
			item.DoClick = function()
				infpan:Reset()
				infpan:SetIcon(ITEM:ICON())
				infpan:SetName(ITEM:Name())
				infpan:SetImage(ITEM:IMG())
				infpan:SetSubNameButton(ITEM:Group() and ITEM:Group():Name(), function()
					IGS.WIN.Group(ITEM:Group():UID())
				end)
				infpan:SetDescription(ITEM:Description())
				infpan:SetInfo(IGS.FormItemInfo(ITEM, LocalPlayer())) -- lp для GetPrice


				bg.side:Reset()

				local act_btn = IGS.AddButton(bg.side, "",function()
					IGS.ProcessActivate(dbID, function(ok) -- iPurchID, sMsg_
						if not ok then return end

						removeFromCanvas(item)
					end)
				end).button
				act_btn:SetActive(true)
				act_btn:SetText(IGS.GetPhrase("activate"))

				if IGS.C.Inv_AllowDrop then
					IGS.AddButton(bg.side,IGS.GetPhrase("droponfloor"),function()
						IGS.DropItem(dbID,function()
							removeFromCanvas(item)
						end)
					end)
				end
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

	activity:AddTab(IGS.GetPhrase("inventory"),bg,"materials/icons/fa32/cart-arrow-down.png")
end

hook.Add("IGS.CatchActivities","inventory",function(activity,sidebar)
	if not IGS.C.Inv_Enabled then return end

	IGS.GetInventory(function(items)
		if not IsValid(sidebar) then return end
		loadTab(activity,sidebar,items)
	end)
end)

-- IGS.UI()
