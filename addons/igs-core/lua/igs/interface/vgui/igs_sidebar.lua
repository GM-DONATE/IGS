local PANEL = {}

function PANEL:Init()
	-- Херня справа от лэйаута с услугами http://joxi.ru/52aQQ8Efzov120
	-- Вид без нее: http://joxi.ru/eAO44lGcXORlro
	self.sidebar = uigs.Create("Panel", function(sbar)
		sbar:Dock(FILL)
	end, self)

	-- Верхняя часть http://joxi.ru/5mdWW05tzW6Wr1
	self.header = uigs.Create("Panel", function(header)
		header:SetTall(40)
		header:Dock(TOP)
	end, self.sidebar)
end

-- Заголовок сайдбара "Последние покупки" и т.д.
function PANEL:SetTitle(sTitle)
	self.title = self.title or uigs.Create("DLabel", function(title)
		title:Dock(BOTTOM)
		title:SetTall(24)
		title:SetFont("igs.19")
		title:SetTextColor(IGS.col.TEXT_HARD)
		title:SetContentAlignment(8)
	end, self.header)

	self.title:SetText(sTitle)

	return self.title
end

vgui.Register("igs_sidebar",PANEL,"Panel")
--IGS.UI()
