local PANEL = {}

local PL_VARIANTS = PLUR(IGS.LANG[IGS.C.LANG].PL_VARIANTS)
function PANEL:SetGroup(ITEM_GROUP)
	self.group = ITEM_GROUP

	if ITEM_GROUP:ICON() then
		self:SetIcon(ITEM_GROUP:ICON())
	end

	if ITEM_GROUP.highlight then
		self:SetTitleColor(ITEM_GROUP.highlight)
	end

	local visible_items = {}
	for _,GROUP_ITEM in ipairs(ITEM_GROUP:Items()) do
		if GROUP_ITEM.item:CanSee( LocalPlayer() ) then
			table.insert(visible_items, GROUP_ITEM)
		end
	end

	self:SetName(ITEM_GROUP:Name())
	self:SetSign(PL_VARIANTS(#visible_items))

	local min,max = math.huge,0 -- минимальная и максимальная цены итемов
	for _,v in ipairs(visible_items) do
		local price = v.item:GetPrice( LocalPlayer() )

		if price < min then
			min = price
		end

		if price > max then
			max = price
		end
	end

	if min == max then
		self:SetBottomText(IGS.GetPhrase("allfrom") .. " " .. IGS.SignPrice(min))
	else
		self:SetBottomText(IGS.GetPhrase("from") .. " " .. min .. IGS.GetPhrase("to") .. IGS.SignPrice(max))
	end

	return self
end

function PANEL:DoClick()
	if not IsValid(self.list_bg) then
		self.list_bg = IGS.WIN.Group(self.group:UID())
	end
end


vgui.Register("igs_group",PANEL,"igs_item")
-- IGS.UI()
