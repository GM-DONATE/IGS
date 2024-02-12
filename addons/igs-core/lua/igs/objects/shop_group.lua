--[[-------------------------------------------------------------------------
В магазине есть категории, а есть группы товаров.

Категория - это группа подобных товаров.
Например, випы и премиумы

Группа это может быть разновидность одного товара.
Например группа вип прав содержит в себе вип на неделю, месяц, навсегда и т.д.

Этот файл представляет собой регистратор ГРУПП
---------------------------------------------------------------------------]]

local ITEM_GROUP = {}
ITEM_GROUP.__index = ITEM_GROUP
ITEM_GROUP.__tostring = function(self)
	-- "ITEM GROUP (Name Of Group) [i]"
	return "IGS GROUP (" .. self:Name() .. ")[" .. #self:Items() .. "]"
end
-- MT_IGSGroup = getmetatable( IGS.NewGroup("") )



-- Fade, Tiger, Damascus
function ITEM_GROUP:AddItem(STORE_ITEM,sNameOverride)
	if self.items.STORED[STORE_ITEM:UID()] then
		return self.items.STORED[STORE_ITEM:UID()]
	end

	local dat = {
		item = STORE_ITEM,
		name = sNameOverride or STORE_ITEM:Name()
	}

	local ID = #self.items.MAP + 1
	self.items.MAP[ID] = dat
	self.items.STORED[STORE_ITEM:UID()] = dat

	STORE_ITEM.group = self

	return self.items.MAP[ID]
end

function ITEM_GROUP:SetIcon(sIconUrl)
	self.icon_url = sIconUrl
	return self
end

function ITEM_GROUP:SetHighlightColor(color)
	if CLIENT then
		self.highlight = color
	end
	return self
end




function ITEM_GROUP:Name()
	return self.name
end

function ITEM_GROUP:UID() -- TODO
	return self:Name()
end

function ITEM_GROUP:Items()
	return self.items.MAP
end

function ITEM_GROUP:ICON()
	return self.icon_url
end




IGS.GROUPS = IGS.GROUPS or {}

-- Flip Knifes
function IGS.NewGroup(sName)
	if IGS.GROUPS[sName] then
		return IGS.GROUPS[sName]
	end

	local group = setmetatable({
		name = sName,
		items = {
			MAP    = {}, -- iter, STORED
			STORED = {}  -- STORE_ITEM:UID(),
		},
	},ITEM_GROUP)

	IGS.GROUPS[sName] = group

	return group
end

function IGS.GetGroups()
	return IGS.GROUPS
end

function IGS.GetGroup(name)
	return IGS.GROUPS[name]
end
