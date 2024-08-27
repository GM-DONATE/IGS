IGS.ITEMS.ULX = IGS.ITEMS.ULX or {
	GROUPS = {},
	PEX    = {}
}


local STORE_ITEM = MT_IGSItem

function STORE_ITEM:SetULXGroup(sUserGroup, iGroupWeight)
	self:SetCanActivate(function(pl) -- invDbID
		if pl:IsUserGroup(sUserGroup) then
			return IGS.GetPhrase("youalrhavethat")
		end
	end)
	self:SetInstaller(function(pl)
		RunConsoleCommand("ulx", "adduserid", pl:SteamID(), sUserGroup)
		pl.IGSULXWeight = iGroupWeight
	end)
	self:SetValidator(function(pl)
		local valid = false
		if pl.IGSULXWeight then
			valid = iGroupWeight <= pl.IGSULXWeight
		else
			valid = pl:IsUserGroup(sUserGroup)
		end

		if not valid then
			IGS.NotifyAll(Format(IGS.GetPhrase("autorecovery"), self:Name(), pl:Name()))
			return false
		end
	end)


	self.ulx_group = self:Insert(IGS.ITEMS.ULX.GROUPS, sUserGroup)
	self.ulx_group_weight = iGroupWeight
	return self
end

-- Есть много ньюансов. Коммит 1 октября 2019
function STORE_ITEM:SetULXCommandAccess(cmd,tag) -- "ulx model","^", например
	self:SetInstaller(function(pl)
		if not tag then
			table.insert(ULib.ucl.authed[ pl:UniqueID() ].allow, cmd)
		else
			ULib.ucl.authed[ pl:UniqueID() ].allow[cmd] = tag
		end
	end)
	self:SetValidator(function()
		return false
	end)


	self.ulx_command = self:Insert(IGS.ITEMS.ULX.PEX, cmd)
	return self
end


if CLIENT then return end

local function checkGroups(pl)
	local hasAccess = IGS.PlayerHasOneOf(pl, IGS.ITEMS.ULX.GROUPS[ pl:GetUserGroup() ])
	if hasAccess == nil then return end

	if hasAccess then
		pl.IGSULXWeight = hasAccess.ulx_group_weight
		return -- если имеется хоть одна покупка, то не снимаем права
	end

	RunConsoleCommand("ulx","removeuserid",pl:SteamID())
end

local function hasPexAccess(pl, cmd)
	local hasAccess = IGS.PlayerHasOneOf(pl, IGS.ITEMS.ULX.PEX[cmd])
	return hasAccess ~= false -- nil, если не продается
end

local function checkPermissions(pl)
	local user = ULib.ucl.authed[ pl:UniqueID() ]
	if not user then return end

	local changed
	-- Вид ucl таблицы https://img.qweqwe.ovh/1523035793058.png
	for k,v in pairs(user.allow or {}) do -- не уверен, что allow обязательно есть
		local cmd = isnumber(k) and v or k

		if not hasPexAccess(pl, cmd) then
			user.allow[k] = nil
			changed = true
		end
	end

	if changed then
		ULib.ucl.saveUsers()
	end
end

timer.Simple(.1, function() -- чтобы этот хук обязательно был после RestorePex. История ВК 20 мая с Антон Панченко
hook.Add("IGS.PlayerPurchasesLoaded", "ULXGroupsAndPEX", function(pl)
	if next(IGS.ITEMS.ULX.GROUPS) then
		checkGroups(pl)
	end

	if next(IGS.ITEMS.ULX.PEX) then
		checkPermissions(pl)
	end
end, HOOK_HIGH)
end)
