IGS.WIN = IGS.WIN or {}

surface.CreateFont("igs.40", {font = "roboto", extended = true, size = 40, weight = 500})
surface.CreateFont("igs.24", {font = "roboto", extended = true, size = 24, weight = 400})
surface.CreateFont("igs.22", {font = "roboto", extended = true, size = 22, weight = 400})
surface.CreateFont("igs.20", {font = "roboto", extended = true, size = 20, weight = 400})
surface.CreateFont("igs.19", {font = "roboto", extended = true, size = 19, weight = 400})
surface.CreateFont("igs.18", {font = "roboto", extended = true, size = 18, weight = 400})
surface.CreateFont("igs.17", {font = "roboto", extended = true, size = 15, weight = 550})
surface.CreateFont("igs.15", {font = "roboto", extended = true, size = 15, weight = 550})


uigs = uigs or {}
function uigs.Create(t, f, p)
	local cb, parent = f, p

	if not isfunction(f) then -- nil or panel
		parent, cb = f, nil
	end

	local v = vgui.Create(t, parent)
	if cb then cb(v, parent) end
	return v
end
-- uigs.Create("name")
-- uigs.Create("name", parent)
-- uigs.Create("name", func, parent)
-- uigs.Create("name", func)


-- Чтобы не открывало F1 менюшку даркрпшевскую ебучую
hook.Add("DarkRPFinishedLoading","SupressDarkRPF1",function()
	if IGS.C.MENUBUTTON ~= KEY_F1 then return end

	function GM:ShowHelp() end
end)






-- чтобы аргументом не передалась панель
local function dep() IGS.WIN.Deposit() end


local mf -- антидубликат
function IGS.UI()
	if not IGS.IsLoaded() then
		LocalPlayer():ChatPrint("[IGS] Автодонат не загружен")
		return
	end

	if IsValid(mf) then
		if not mf:IsVisible() then
			IGS.ShowUI()
		end
		return
	end

	mf = uigs.Create("igs_frame", function(self)
		-- 580 = (items_in_line * item_pan_wide) + (10(margin) * (items_in_line + 1))
		self:SetSize(math.min(ScrW(), 800), math.min(ScrH(), 500)) -- позволяет закрыть окно на ущербных разрешениях
		self:RememberLocation("igs")
		self:MakePopup()

		-- если повесить на фрейм, то драг сломается
		local init = CurTime() -- https://t.me/c/1353676159/7185
		function self.btnClose:Think()
			if CurTime() - init > 1 and input.IsKeyDown(IGS.C.MENUBUTTON) then
				IGS.HideUI()
			end
		end
	end)

	-- Баланс
	uigs.Create("igs_button", function(self)
		function self:UPDBalance()
			self.bal = LocalPlayer():IGSFunds()
			self:SetText("Баланс: " .. IGS.SignPrice(self.bal))
		end

		self:SetPos(20,0)
		self:SetSize(150,27)
		self:UPDBalance()
		self:SetTooltip("Открыть список покупок")
		self.Think = function(s)
			if s.bal ~= LocalPlayer():IGSFunds() then
				s:UPDBalance()
			end
		end

		local add = uigs.Create("igs_button", mf)
		add:SetPos(20 + 150 + 2,0)
		add:SetSize(27,27)
		add:SetText("+")
		add:SetTooltip("Пополнение счета")
		add:SetActive(true)

		 add.DoClick = dep
		self.DoClick = dep
	end,mf)

	mf.activity = uigs.Create("igs_tabbar", function(self)
		self:SetPos(0,mf:GetTitleHeight())
		self:SetSize(580,mf:GetTall() - mf:GetTitleHeight())
	end, mf)

	-- Херня справа от лэйаута с услугами http://joxi.ru/52aQQ8Efzov120
	-- Вид без нее: http://joxi.ru/eAO44lGcXORlro
	local x,y = mf.activity:GetPos()
	mf.sidebar = uigs.Create("igs_sidebar", mf)
	mf.sidebar:SetSize(mf:GetWide() - mf.activity:GetWide(), mf.activity:GetTall() + 1 + 1)
	mf.sidebar:SetPos(x + mf.activity:GetWide(),y - 1) -- -1 чтобы перекрыть подчеркивание хэдера
	mf.sidebar.PaintOver = function(_,_,h)
		surface.SetDrawColor(IGS.col.HARD_LINE)
		surface.DrawLine(0,0,0,h) -- линия слева
	end
	mf.sidebar.header.Paint = function(_,w,h)
		draw.RoundedBox(0,0,0,w,h,IGS.col.FRAME_HEADER)

		surface.SetDrawColor(IGS.col.HARD_LINE)
		surface.DrawLine(0,h - 1,w,h - 1)
	end

	mf.sidebar.activity = uigs.Create("igs_multipanel", mf.sidebar.sidebar)
	mf.sidebar.activity:Dock(FILL)

	function mf.sidebar:AddPanel(panel,active)
		return self.activity:AddPanel(panel,active)
	end

	function mf.sidebar:Show(iPanelID)
		return self.activity:SetActivePanel(iPanelID)
	end

	function mf.sidebar:AddPage(sTitle)
		return uigs.Create("Panel", function(bg)
			bg.side = uigs.Create("igs_scroll")

			bg.SidePanelID = self:AddPanel(bg.side)
			bg.side:SetSize(self:GetSize()) -- если указать раньше, то сбросится
			bg.OnOpen = function(s)
				self:SetTitle(sTitle)
				self:Show(s.SidePanelID)

				-- Не знаю как сделать лучше.
				-- ЧТобы не оверрайдить полностью - сделал дополнительный метод
				if bg.OnOpenOver then
					bg.OnOpenOver()
				end
			end
		end, self)
	end

	-- Немного не правильно, но эта штука отключает
	for hook_name in pairs(IGS.C.DisabledFrames) do
		hook.Remove("IGS.CatchActivities",hook_name)
	end

	-- Собираем кнопочки в футере
	hook.Run("IGS.CatchActivities",mf.activity,mf.sidebar)

	return mf
end

function IGS.GetUI()
	return IsValid(mf) and mf or nil
end

function IGS.CloseUI()
	if IsValid(mf) then
		mf:Close()
	end
end

local lastX,lastY -- remember
function IGS.HideUI()
	if not mf.moving then
		mf.moving = true
		lastX,lastY = mf:GetPos()
		mf:MoveTo(-mf:GetWide(), lastY, .2)
		timer.Simple(.2, function()
			mf:SetVisible(false)
			mf.moving = false
		end)
	end
end

function IGS.ShowUI()
	if not mf.moving then
		mf.moving = true
		mf:SetVisible(true)
		mf:MoveTo(lastX, lastY, .2)
		timer.Simple(.2, function() mf.moving = false end)
	end
end

function IGS.OpenUITab(sName)
	local iui = IGS.GetUI() or IGS.UI()

	for _,btn in ipairs(iui.activity.Buttons) do
		if btn:Name() == sName then
			btn:DoClick()
		end
	end
end

-- Добавляет блок текста к скролл панели. К обычной не вижу смысла
-- scroll Должен иметь статический размер. Никаких доков!
-- Сетка: https://img.qweqwe.ovh/1487023074990.png
function IGS.AddTextBlock(scroll,sTitle,sText) -- используется в фрейме хелпа и чартов
	-- \/ вставленная панель
	return scroll:AddItem(uigs.Create("Panel", function(pnl)
		local y = 3

		-- Title
		if sTitle then
			for _,line in ipairs( string.Wrap("igs.20",sTitle,scroll:GetWide() - 5 - 5) ) do
				local t = uigs.Create("DLabel", pnl)
				t:SetPos(5,y)
				t:SetFont("igs.20")
				t:SetText(line)
				t:SetTextColor(IGS.col.TEXT_HARD)
				t:SizeToContents()

				y = y + t:GetTall()
			end

			y = y + 2
		end

		for _,line in ipairs( string.Wrap("igs.18",sText,scroll:GetWide() - 5 - 5) ) do
			local lbl = uigs.Create("DLabel", pnl)
			lbl:SetPos(5,y)
			lbl:SetFont("igs.18")
			lbl:SetText(line)
			lbl:SetTextColor(IGS.col.TEXT_SOFT)
			lbl:SizeToContents()

			y = y + lbl:GetTall()
		end

		pnl:SetTall(y + 10)
	end))
end

function IGS.AddButton(pScroll,sName,fDoClick) -- используется в инвентаре и профиле для юза купонов
	-- \/ вставленная панель
	return pScroll:AddItem(uigs.Create("Panel", function(pan)
		pan.button = uigs.Create("igs_button", function(s)
			s:SetSize(pScroll:GetWide() - 5 - 5,50)
			s:SetPos(5,5)
			s:SetText(sName)
			s.DoClick = fDoClick
		end, pan)

		pan:SetTall(pan.button:GetTall() + 5)
	end))
end

-- IGS.UI()

-- timer.Create("IGSUI",30,1,function()
-- 	if IsValid(mf) then
-- 		mf:Close()
-- 	end
-- end)
