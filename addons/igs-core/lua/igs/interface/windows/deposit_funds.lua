local function niceSum(i, iFallback)
	return math.Truncate(tonumber(i) or iFallback, 2)
end

local m
function IGS.WIN.Deposit(iRealSum)
	if IsValid(m) then return end -- не даем открыть 2 фрейма
	iRealSum = tonumber(iRealSum)

	surface.PlaySound("ambient/weather/rain_drip1.wav")
	hook.Run("IGS.OnDepositWinOpen",iRealSum)

	local realSum = math.max(IGS.GetMinCharge(), niceSum(iRealSum, 0))

	m = uigs.Create("igs_frame", function(self)
		self:SetSize(450,400)
		self:RememberLocation("igs_deposit")

		-- Вы, конечно, можете удалить наш копирайт. Чтобы вы не перенапряглись, я даже подготовил чуть ниже строчку для этого
		-- Но прежде, чем ты это сделаешь, ответь себе на вопрос. Зачем? Так мешает?
		self:SetTitle(IGS.GetPhrase("autodonatecopyright"))
		-- self:SetTitle("Владелец этого сервера не ценит чужой труд")

		self:MakePopup()
		-- self:Focus()
		-- self:SetBackgroundBlur(false)

		--[[-------------------------------------
			Левая колонка. Реальная валюта
		---------------------------------------]]
		uigs.Create("DLabel", function(real)
			real:SetSize(450, 25)
			real:SetPos(0, self:GetTitleHeight())
			real:SetText(IGS.GetPhrase("depositsum"))
			real:SetFont("igs.22")
			real:SetTextColor(IGS.col.HIGHLIGHTING)
			real:SetContentAlignment(2)
		end, self)

		self.real_m = uigs.Create("DTextEntry", self)
		self.real_m:SetPos(10,50)
		self.real_m:SetSize(450 - 10 - 10, 30)
		self.real_m:SetNumeric(true)
		self.real_m.Think = function(s)
			local sum = tonumber(s:GetValue())
			self.purchase:SetText(Format(IGS.GetPhrase("depositbtn"), niceSum(sum, 0)))
			self.purchase:SetActive(sum and sum > 0)
		end
		self.real_m:SetValue( realSum )
		self.real_m:OnChange()

		self.purchase = uigs.Create("igs_button", function(p)
			local _,ry = self.real_m:GetPos()

			p:SetSize(400,40)
			p:SetActive(true) -- выделяет синим
			p:SetPos((self:GetWide() - p:GetWide()) / 2,ry + self.real_m:GetTall() + 10)

			p.DoClick = function()
				local want_money = niceSum(self.real_m:GetValue())
				if not want_money then
					self.log:AddRecord(IGS.GetPhrase("depostisumerr"), false)
					return

				elseif want_money < realSum then
					self.log:AddRecord(IGS.GetPhrase("depostiminimal") .. " " .. PL_MONEY(realSum), false)
					return
				end

				self.log:AddRecord(IGS.GetPhrase("depositsafekey"))

				IGS.GetPaymentURL(want_money,function(url)
					IGS.OpenURL(url, IGS.GetPhrase("deposittitle"))
					if not IsValid(self) then return end
					self.log:AddRecord(IGS.GetPhrase("depositgotkey"))

					timer.Simple(.7,function()
						self.log:AddRecord(IGS.GetPhrase("depositfundsauto"))
					end)
				end)
			end
		end, self)



		--[[-------------------------------------------------------------------------
			Все подряд
		---------------------------------------------------------------------------]]
		self.log = uigs.Create("igs_scroll", function(log)
			log:SetSize(250,200)
			log:SetPos(10,self:GetTall() - log:GetTall() - 10)
			-- https://img.qweqwe.ovh/1487171563683.png
			function log:AddRecord(text,pay)
				local col =
					(pay == true  and IGS.col.LOG_SUCCESS) or
					(pay == false and IGS.col.LOG_ERROR)   or IGS.col.LOG_NORMAL

				-- Платеж или Ошибка
				if pay or pay == false then
					self:GetParent():RequestFocus()
					self:GetParent():MakePopup()
				end

				return log:AddItem( uigs.Create("Panel", function(bg)
					text = "> " .. os.date("%H:%M:%S",os.time()) .. "\n" .. text

					local y = 2
					for i,line in ipairs(string.Wrap("igs.18",text,log:GetWide() - 0 - 0)) do
						uigs.Create("DLabel", function(l)
							l:SetPos(0,y)
							l:SetText(line)
							l:SetFont("igs.18")
							l:SizeToContents()
							l:SetTextColor(i == 1 and IGS.col.HIGHLIGHTING or col)
							--               /\ первой строкой идет дата (\n)

							y = y + l:GetTall()
						end, bg)
					end

					bg:SetTall(y + 2)
					log:ScrollTo(log:GetCanvas():GetTall())
				end, log) )
			end
		end, self)

		local log_t = uigs.Create("DLabel", function(log_title)
			local log_x,log_y = self.log:GetPos()

			log_title:SetSize(self.log:GetWide(),22)
			log_title:SetPos(log_x,log_y - log_title:GetTall())
			log_title:SetText(IGS.GetPhrase("depositlog"))
			log_title:SetTextColor(IGS.col.HIGHLIGHTING)
			log_title:SetFont("igs.22")
			log_title:SetContentAlignment(1)
		end, self)

		-- Линия над логом и кнопкой
		local _,log_t_y = log_t:GetPos()
		uigs.Create("DPanel", function(line)
			line:SetPos(10, log_t_y - 2 - 10)
			line:SetSize(self:GetWide() - line:GetPos() * 2, 2)
			line.Paint = function(s, w, h)
				draw.RoundedBox(0,0,0,w,h,IGS.col.SOFT_LINE)
			end
		end, self)


		uigs.Create("igs_button", function(btn)
			local _,log_y = self.log:GetPos()

			btn:SetSize(170, 30)
			btn:SetPos(self:GetWide() - 10 - btn:GetWide(),log_y - 20)
			btn:SetText(IGS.GetPhrase("activatecoupon"))
			btn.DoClick = function()
				IGS.WIN.ActivateCoupon()
			end
		end, self)


		-- uigs.Create("DLabel", function(btns_title)
		-- 	local coup_x,coup_y = coupon:GetPos()

		-- 	btns_title:SetSize(coupon:GetWide(),30)
		-- 	btns_title:SetPos(coup_x,coup_y + coupon:GetTall() + 0)
		-- 	btns_title:SetText("Все автоматизировано")
		-- 	btns_title:SetTextColor(IGS.col.TEXT_HARD)
		-- 	btns_title:SetFont("igs.18")
		-- 	-- btns_title:SetContentAlignment(3)
		-- end, self)

		local function log(delay,text,status)
			timer.Simple(delay,function()
				if not IsValid(self.log) then return end
				self.log:AddRecord(text, status)
			end)
		end

		log(0, IGS.GetPhrase("depositopened"),nil)
		log(math.random(3),IGS.GetPhrase("depositconnected"),true) -- пустышка, которая добавляет чувство безопасностти сделке
		log(math.random(20,40),IGS.GetPhrase("depositfastestfund"),nil)
	end)

	return m
end


hook.Add("IGS.PaymentStatusUpdated","UpdatePaymentStatus",function(dat)
	local text =
		dat.method == "check" and (IGS.GetPhrase("deposticheckfrom") .. " " .. dat.paymentType) or
		dat.method == "pay"   and (IGS.GetPhrase("depostiadded") .. " " .. PL_MONEY(dat.orderSum)) or
		dat.method == "error" and (IGS.GetPhrase("depositerror") .. " " .. dat.errorMessage) or
		IGS.GetPhrase("depositerror1") .. " " .. tostring(dat.method) .. " " .. IGS.GetPhrase("depositerror2")

	if not IsValid(m) then
		IGS.ShowNotify(text, IGS.GetPhrase("depositupdate"))
		return
	end

	local pay = nil
	if dat.method == "pay" then
		pay = true
	elseif dat.method == "error" then
		pay = false
	end

	m.log:AddRecord(text,pay)
end)



-- if IsValid(IGS_CHARGE) then
-- 	IGS_CHARGE:Remove()
-- end

-- IGS_CHARGE = IGS.WIN.Deposit()
-- local p = IGS_CHARGE
-- -- timer.Simple(1,function()
-- -- 	p.log:AddRecord("Kek lol heh mda", false)
-- -- end)

-- timer.Simple(600,function()
-- 	if IsValid(p) then
-- 		p:Remove()
-- 		p = nil
-- 	end
-- end)
