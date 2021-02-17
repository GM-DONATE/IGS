local m

local function purchase(ITEM, buy_button)
	IGS.Purchase(ITEM:UID(), function(errMsg,dbID)
		if !IsValid(buy_button) then return end

		if errMsg then
			IGS.ShowNotify(errMsg, "Ошибка покупки")
			surface.PlaySound("ambient/voices/citizen_beaten1.wav") -- еще есть
			return
		end

		buy_button.purchased = buy_button.purchased or 0
		buy_button.purchased = buy_button.purchased + 1


		if ITEM:IsStackable() then
			buy_button:SetText("Куплено " .. buy_button.purchased .. " шт")
		else
			if IsValid(m) then
				m:Close()
			end

			if !IGS.C.Inv_Enabled then
				IGS.ShowNotify("Спасибо за покупку. Это было просто, правда? :)", "Успешная покупка")
				return
			end

			IGS.BoolRequest("Успешная покупка",
				"Спасибо за покупку. Она находится в вашем /donate инвентаре.\n\nАктивировать ее сейчас?",
			function(yes)
				if !yes then return end

				IGS.ProcessActivate(dbID)
			end)
		end

		surface.PlaySound("ambient/office/coinslot1.wav")
	end)
end






local function move(f, x, sp, cb)
	local _,y = f:GetPos()
	f:MoveTo(x,y, sp,nil,nil,cb)
end

local function shakeFrame(f, amplitude, speed, cb)
	if !IsValid(f) then return end

	local x = f:GetPos()
	move(f, x + amplitude, speed, function()
		move(f, x - amplitude, speed, function()
			move(f, x, speed, cb)
		end)
	end)
end

function IGS.WIN.Item(uid)
	local ITEM = IGS.GetItemByUID(uid)
	if IsValid(m) then
		if m.item_uid == uid then -- попытка повторного открытия того же фрейма

			m:MoveToFront()
			shakeFrame(m, 20, .1)

			return
		end

		-- Открытия другого
		m:Close()
		m = nil
	end

	surface.PlaySound("ambient/weather/rain_drip1.wav")

	m = uigs.Create("igs_frame", function(self)
		self:SetSize(330,550)
		self:RememberLocation("igs_item")
		self:MakePopup()
		self:SetTitle(ITEM:Name())

		self.item_uid  = uid -- для предотвращения повторного открытия двух одинаковых фреймов
	end)


	uigs.Create("igs_iteminfo", function(p)

		--[[-------------------------------------------------------------------------
			Очень не красивый, но очень полезный код
			Заставляет ползунок помигать для заметности
		---------------------------------------------------------------------------]]
		local viewed = tonumber( bib.get("igs:items_viewed",0) )
		bib.set("igs:items_viewed",viewed + 1)

		-- Если мигали 3+ раза, то больше не надо
		if viewed < 3 then
			local oldThink = p.scroll.scrollBar.Think
			timer.Simple(.5,function() -- 0.5 = время, которое скролл будет мигать
				if !IsValid(p) then return end

				p.scroll.scrollBar.Think = oldThink
			end)

			p.scroll.scrollBar.Think = function() --              \/ скорость мигания
				p.scroll.scrollBar.addWidth = (math.sin( CurTime() * 20 ) + 1) / 2 * 8 -- 8 лимит ширины скролла
				p.scroll.scrollBar:InvalidateLayout()
			end
		end
		-----------------------------------------------------------------------------



		p:Dock(FILL)
		p:SetIcon(ITEM:ICON())
		p:SetName("Действует " .. IGS.TermToStr(ITEM:Term()))
		p:SetImage(ITEM:IMG())
		p:SetSubNameButton(ITEM:Group() and ITEM:Group():Name(), function()
			IGS.WIN.Group(ITEM:Group():UID())
		end)
		p:SetDescription( ITEM:Description() )
		p:SetInfo(IGS.FormItemInfo(ITEM))

		m.act = p:CreateActivity() -- панелька для кастом эллементов
		m.buy = uigs.Create("igs_button", function(buy)
			local cur_price = ITEM:PriceInCurrency()

			buy:Dock(TOP)
			buy:SetTall(20)
			buy:SetText( "Купить за " .. PL_IGS(cur_price) )
			buy:SetActive( IGS.CanAfford(LocalPlayer(), cur_price) )
			buy.DoClick = function(s)
				if !s:IsActive() then
					local need = cur_price - LocalPlayer():IGSFunds()

					surface.PlaySound("ambient/voices/citizen_beaten1.wav") -- еще есть
					IGS.BoolRequest(
						"Недостаточно денег",
						("Вам не хватает %s для покупки %s.\nЖелаете мгновенно пополнить счет?"):format( PL_IGS(need), ITEM:Name()),
						function(yes)
							if yes then
								IGS.WIN.Deposit(IGS.RealPrice(need), true)
								surface.PlaySound("vo/npc/male01/yeah02.wav")
							end
						end
					):ShowCloseButton(true)

					return
				end

				purchase(ITEM, s)
			end
		end, m.act)
	end, m)

	hook.Run("IGS.OnItemInfoOpen", ITEM, m)
end
-- IGS.WIN.Item("permission_model_30d")
