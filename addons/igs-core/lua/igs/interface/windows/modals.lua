function IGS.BoolRequest(title, text, cback)
	local m = uigs.Create("igs_frame", function(self)
		self:SetTitle(title)
		self:ShowCloseButton(false)
		self:SetWide(ScrW() * .2)
		self:MakePopup()
	end)

	local txt = string.Wrap("igs.18", text, m:GetWide() - 10)
	local y = m:GetTitleHeight() + 5

	for _,line in ipairs(txt) do
		uigs.Create("DLabel", function(self, p)
			self:SetText(line)
			self:SetFont("igs.18")
			self:SetTextColor(IGS.col.TEXT_HARD)
			self:SizeToContents()
			self:SetPos((p:GetWide() - self:GetWide()) / 2, y)
			y = y + self:GetTall() + 2
		end, m)
	end

	y = y + 5
	m.btnOK = uigs.Create("igs_button", function(self, p)
		self:SetText("Да")
		self:SetPos(5, y)
		self:SetSize(p:GetWide() / 2 - 7.5, 25)
		self.DoClick = function()
			p:Close()
			cback(true)
		end
	end, m)

	m.btnCan = uigs.Create("igs_button", function(self, p)
		self:SetText("Нет")
		self:SetPos(p.btnOK:GetWide() + 10, y)
		self:SetSize(p.btnOK:GetWide(), 25)
		self:RequestFocus()
		self.DoClick = function()
			p:Close()
			cback(false)
		end
		y = y + self:GetTall() + 5
	end, m)

	m:SetTall(y)
	m:Center()

	m:Focus()
	return m
end

function IGS.StringRequest(title, text, default, cback)
	local m = uigs.Create("igs_frame", function(self)
		self:SetTitle(title)
		self:ShowCloseButton(false)
		self:SetWide(ScrW() * .3)
		self:MakePopup()
	end)

	local txt = string.Wrap("igs.18", text, m:GetWide() - 10)
	local y = m:GetTitleHeight() + 5

	for _, v in ipairs(txt) do
		uigs.Create("DLabel", function(self, p)
			self:SetText(v)
			self:SetFont("igs.18")
			self:SetTextColor(IGS.col.TEXT_HARD)
			self:SizeToContents()
			self:SetPos((p:GetWide() - self:GetWide()) / 2, y)
			y = y + self:GetTall()
		end, m)
	end

	y = y + 5
	local tb = uigs.Create("DTextEntry", function(self, p)
		self:SetPos(5, y + 5)
		self:SetSize(p:GetWide() - 10, 25)
		self:SetValue(default or '')
		y = y + self:GetTall() + 10
		self.OnEnter = function()
			p:Close()
			cback(self:GetValue())
		end
	end, m)

	local btnOK = uigs.Create("igs_button", function(self, p)
		self:SetText("ОК")
		self:SetPos(5, y)
		self:SetSize(p:GetWide() / 2 - 7.5, 25)
		self:SetActive(true)
		self.DoClick = function()
			p:Close()
			cback(tb:GetValue())
		end
	end, m)

	uigs.Create("igs_button", function(self)
		self:SetText("Отмена")
		self:SetPos(btnOK:GetWide() + 10, y)
		self:SetSize(btnOK:GetWide(), 25)
		self:RequestFocus()
		self.DoClick = function()
			m:Close()
		end
		y = y + self:GetTall() + 5
	end, m)

	m:SetTall(y)
	m:Center()

	m:Focus()
	return m
end


local null = function() end
function IGS.ShowNotify(sText, sTitle, fOnClose)
	local m = IGS.BoolRequest(sTitle or "[IGS] " .. IGS.GetPhrase("notification"), sText, fOnClose or null)
	m.btnCan:Remove() -- оставляем только 1 кнопку

	local _,y = m.btnOK:GetPos()
	m.btnOK:SetText("OK")
	m.btnOK:SetPos((m:GetWide() - m.btnOK:GetWide()) / 2, y)

	return m
end

function IGS.WIN.ActivateCoupon()
	IGS.StringRequest(IGS.GetPhrase("couponactivation"),
		IGS.GetPhrase("couponactivationexp"),
	nil,function(val)
		IGS.UseCoupon(val,function(errMsg)
			if errMsg then
				IGS.ShowNotify(errMsg, "Ошибка активации купона")
			else
				IGS.ShowNotify(IGS.GetPhrase("couponactivationsuccess"), IGS.GetPhrase("couponactivationsuccesstitle"))
			end
		end)
	end)
end


-- IGS.ShowNotify(("test "):rep(10), nil, function()
-- 	print("Нотификашка закрылась")
-- end)

IGS.OpenURL = gui.OpenURL

-- IGS.UI()
