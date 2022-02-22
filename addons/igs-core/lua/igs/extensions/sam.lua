local STORE_ITEM = FindMetaTable("IGSItem")

function STORE_ITEM:SetSAMGroup(sUserGroup)
	IGS.SAM_GROUPS = IGS.SAM_GROUPS or {}

	self:SetInstaller(function(pl)
		pl:sam_set_rank(sUserGroup)
	end):SetMeta("samgroup", sUserGroup)

	self:Insert(IGS.SAM_GROUPS, sUserGroup) -- #todo insert возвращает значение..
	return self
end

-- #todo IGS.Filter ?
local function fl_filter(t, func)
	local res = {}
	for i,v in ipairs(t) do
		if func(v) then
			res[#res + 1] = v
		end
	end
	return res
end

hook.Add("IGS.PlayerPurchasesLoaded", "IGS_SAM", function(pl, purchases_)
	if CLIENT or not purchases_ or not IGS.SAM_GROUPS then return end

	local purchases_list = table.GetKeys(purchases_)
	local purchased_groups = fl_filter(purchases_list, function(uid)
		return IGS.GetItemByUID(uid):GetMeta("samgroup")
	end)

	if not purchased_groups[1] then
		local rank = pl:sam_getrank()
		if rank ~= "user" and IGS.SAM_GROUPS[rank] then
			pl:sam_set_rank("user")
		end

		return
	end

	local priority_item = IGS.GetItemByUID( purchased_groups[1] )
	for _,uid in ipairs(purchased_groups) do
		local ITEM = IGS.GetItemByUID(uid)
		if ITEM.id > priority_item.id then
			priority_item = ITEM
		end
	end

	priority_item:Setup(pl)
end)
