IGS.ITEMS.SB = IGS.ITEMS.SB or {
	TOOLS = {},
	SENTS = {},
	SWEPS = {},
	VEHS  = {}
}


local STORE_ITEM = MT_IGSItem

-- Тулы
function STORE_ITEM:SetTool(sToolName)
	self.tool = self:Insert(IGS.ITEMS.SB.TOOLS, sToolName)
	return self
end

-- Энтити
function STORE_ITEM:SetEntity(sEntClass)
	self.entity = self:Insert(IGS.ITEMS.SB.SENTS, sEntClass)
	return self
end

-- Пушки
function STORE_ITEM:SetWeapon(sWepClass, tAmmo)
	self:SetNetworked() -- для HasPurchase и отображения галочки

	self.ammo = tAmmo
	self.swep = self:Insert(IGS.ITEMS.SB.SWEPS, sWepClass)
	return self
end


function STORE_ITEM:SetPlayerModel(mdl)
	return self:SetMeta("player_model", mdl):AddServerHook("PlayerSetModel", function(pl)
		local override = hook.Run("IGS.PlayerSetModel", pl, self)
		if override ~= false then
			pl:SetModel(mdl)
			pl:SetupHands()
			return true
		end
	end)
end

--[[
IGS("Alyx", "custom_model", 300)
	:SetDescription("Вы будете спавниться всегда с моделькой Аликс")
	:SetTerm(30) -- 30 дней
	:SetPlayerModel("models/player/alyx.mdl")


-- Если у игрока куплена моделька alyx.mdl, то выдавать ее только за профессию бомжа
hook.Add("IGS.PlayerSetModel", "SetPlayerModel_filter", function(pl, ITEM)
	local mdl = ITEM:GetMeta("player_model")
	if mdl == "models/player/alyx.mdl" and pl:Team() ~= TEAM_HOBO then
		return false
	end
end)
--]]


local prop_limiters_exists = nil -- optimization

function STORE_ITEM:IncreasePlayerPropLimit(iAmount)
	prop_limiters_exists = true
	return self:SetInstaller(function(pl)
		local current_extra = pl:GetVar("igs_extra_props_limit", 0)
		pl:SetVar("igs_extra_props_limit", current_extra + iAmount)
	end):SetMeta("prop_limit", iAmount)
end

if SERVER then
	hook.Add("PlayerCheckLimit", "IGS", function(pl, type, current_spawned, general_limit)
		if not prop_limiters_exists or type ~= "props" then return end

		local extra_props_purchased = pl:GetVar("igs_extra_props_limit", 0)
		local general_limit_reached = current_spawned >= general_limit
		local extra_limit_reached   = current_spawned <= extra_props_purchased + general_limit

		-- первое, чтобы не выбрасывать true лишний раз
		if general_limit_reached and (not extra_limit_reached) then
			return true
		end
	end)

	hook.Add("IGS.PlayerPurchasesLoaded", "IGS.LoadExtraPropsLimit", function(pl, purchases_)
		if not purchases_ or not prop_limiters_exists then return end

		local extra = 0
		for uid in pairs(purchases_) do
			local ITEM = IGS.GetItemByUID(uid)
			if ITEM:GetMeta("prop_limit") then
				extra = extra + ITEM:GetMeta("prop_limit")
			end
		end

		if extra ~= 0 then
			pl:SetVar("igs_extra_props_limit", extra)
		end
	end)

	-- hook.Add("PlayerCheckLimit", "asd", PRINT)
end

if CLIENT then -- :SetWeapon only
hook.Add("IGS.OnItemInfoOpen", "CheckGiveWeaponOnSpawn", function(ITEM, fr)
	if not (ITEM.swep and LocalPlayer():HasPurchase(ITEM:UID())) then return end

	uigs.Create("DCheckBoxLabel", function(self)
		self:Dock(TOP)
		self:DockMargin(0, 5, 0, 0)
		self:SetTall(20)

		local should_give = LocalPlayer():GetNWBool("igs.gos." .. ITEM:ID()) -- #todo UID и избавиться от :ID()
		self:SetValue(should_give)

		self:SetText("Выдавать при спавне")
		self.Label:SetTextColor(IGS.col.TEXT_SOFT)
		self.Label:SetFont("igs.15")

		function self:OnChange(give)
			net.Start("IGS.GiveOnSpawnWep")
				net.WriteIGSItem(ITEM)
				net.WriteBool(give)
			net.SendToServer()
		end
	end, fr.act)
end)

-- IGS.CloseUI()
-- IGS.UI()
-- IGS.WIN.Item("wep_weapon_ar2")

else -- SV
	util.AddNetworkString("IGS.GiveOnSpawnWep")

	local function bibuid(pl, ITEM)
		return "igs:gos:" .. pl:UniqueID() .. ":" .. ITEM:UID()
	end

	local function SetShouldPlayerReceiveWep(pl, ITEM, bGive)
		pl:SetNWBool("igs.gos." .. ITEM:ID(), bGive) -- gos GiveOnSpawn
		bib.setBool(bibuid(pl, ITEM), bGive)
	end

	local function PlayerSetWantReceiveOnSpawn(pl, ITEM, bWant)
		SetShouldPlayerReceiveWep(pl, ITEM, bWant)
		IGS.Notify(pl, ITEM:Name() .. (bWant and " " or " не ") .. "будет выдаваться при спавне")
	end

	local function GetShouldPlayerReceiveWep(pl, ITEM)
		return bib.getBool(bibuid(pl, ITEM))
	end

	local function setActiveWeapon(pl, class)
		pl:SetActiveWeapon(pl:GetWeapon(class))
	end

	local function giveAmmo(pl, ammo)
		if not ammo then return end
		for ammo_type, count in pairs(ammo) do
			pl:SetAmmo(count, ammo_type)
		end
	end

	-- Выдает купленное оружие, если установлена галочка
	-- https://trello.com/c/2KJQisfJ/488-оружие-выдается-и-в-тюрьме
	function IGS:IGS_PlayerLoadout(pl)
		for uid in pairs(IGS.PlayerPurchases(pl) or {}) do
			local ITEM = IGS.GetItemByUID(uid)
			if ITEM.swep and GetShouldPlayerReceiveWep(pl, ITEM) then
				pl:Give(ITEM.swep)
				giveAmmo(pl, ITEM.ammo)
			end
		end
	end

	net.Receive("IGS.GiveOnSpawnWep", function(_, pl)
		local ITEM, bWant = net.ReadIGSItem(), net.ReadBool()
		if not pl:HasPurchase(ITEM:UID()) or not ITEM.swep then return end -- байпас

		PlayerSetWantReceiveOnSpawn(pl, ITEM, bWant)
	end)

	hook.Add("PlayerLoadout", "IGS.PlayerLoadout", function(pl)
		hook.Call("IGS_PlayerLoadout", IGS, pl)
	end)

	hook.Add("IGS.PlayerPurchasesLoaded", "IGS.PlayerLoadout", function(pl)
		hook.Call("IGS_PlayerLoadout", IGS, pl)
	end)

	hook.Add("IGS.PlayerActivatedItem", "IGS.PlayerLoadout", function(pl, ITEM)
		if ITEM.swep then
			PlayerSetWantReceiveOnSpawn(pl, ITEM, true) -- default give on spawn
			hook.Call("IGS_PlayerLoadout", IGS, pl)

			local text = "%s теперь будет выдаваться при каждом респавне. " ..
			"Если вы хотите временно отключить выдачу, " ..
			"то снимите галочку в карточке предмета в /donate меню"

			pl:ChatPrint("▼")
			IGS.Notify(pl, text:format(ITEM:Name()))
			pl:ChatPrint("▲")

			setActiveWeapon(pl, ITEM.swep)
			giveAmmo(pl, ITEM.ammo)
		end
	end)

	hook.Add("PlayerGiveSWEP", "IGS", function(pl, class)
		local ITEM = IGS.PlayerHasOneOf(pl, IGS.ITEMS.SB.SWEPS[class]) -- hasAccess if ITEM returned
		if ITEM then
			timer.Simple(.1, function() giveAmmo(pl, ITEM.ammo) end)
			return true
		end
	end)

	-- DARKRP ONLY
	hook.Add("canDropWeapon", "IGS", function(pl, wep)
		-- Пушка продается и чел купил ее
		local ITEM = IsValid(wep) and IGS.PlayerHasOneOf(pl, IGS.ITEMS.SB.SWEPS[wep:GetClass()])
		if ITEM then
			return false
		end

		-- Пушка не продается или чел ее не покупал
		-- Т.е. по сути возможность дропа контроллируется другими хуками
	end)
end


-- Машины
function STORE_ITEM:SetVehicle(sVehClass)
	self.vehicle = self:Insert(IGS.ITEMS.SB.VEHS, sVehClass)
	return self
end

-- /\ SHARED
if CLIENT then return end
-- \/ SERVER

-- print( hook.Run("CanTool", player.Find("hell"), AMD():GetEyeTrace(), "rope") )
hook.Add("CanTool","IGS",function(pl, _, tool)
	local ITEM = IGS.PlayerHasOneOf(pl, IGS.ITEMS.SB.TOOLS[tool])
	if ITEM ~= nil then -- donate
		local allow = hook.Run("IGS.CanTool", pl, tool)
		if allow ~= nil then return allow end
		return tobool(ITEM)
	end
end)

-- Ниже решение для машин, как сделать, чтобы не спавнили тучу. Сейчас реализовывать лень
hook.Add("PlayerSpawnSENT","IGS",function(pl, class)
	local ITEM = IGS.PlayerHasOneOf(pl, IGS.ITEMS.SB.SENTS[class])
	if ITEM ~= nil then -- donate
		local allow = hook.Run("IGS.PlayerSpawnSENT", pl, class)
		if allow ~= nil then return allow end
		return tobool(ITEM)
	end
end)


-- для HOOK_HIGH
-- выше 2018.11.15 вынес и немного переписал две функции
-- Если будет работать норм, то и с остальных снять
-- 2024.08.31 вынес с таймера и убрал HOOK_HIGH еще с PlayerGiveSWEP и canDropWeapon
timer.Simple(0, function()

--[[-------------------------------------------------------------------------
	Машины
---------------------------------------------------------------------------]]
local function getcount(pl, class)
	return pl:GetVar("vehicles_" .. class,0)
end

local function counter(pl, class, incr)
	pl:SetVar("vehicles_" .. class, getcount(pl, class) + incr)
end

-- разрешаем спавнить одну, но конструкция позволяет в будущем сделать поддержку спавна нескольких машин
local function canSpawn(pl, class)
	return getcount(pl, class) < 1
end

local function getVehClass(veh)
	-- https://trello.com/c/l1tw7YpR/623
	-- ClassOverride for scars (https://t.me/c/1353676159/48545)
	return (veh.IsSimfphyscar and veh:GetSpawn_List()) or veh.ClassOverride or veh:GetVehicleClass()
end

-- Считаем заспавненные и удаленные машины
hook.Add("PlayerSpawnedVehicle", "IGS", function(pl, veh)
	if IGS.PlayerHasOneOf(pl, IGS.ITEMS.SB.VEHS[getVehClass(veh)]) then -- чел покупал эту тачку, а теперь спавнит
		counter(pl, getVehClass(veh), 1)

		veh:CallOnRemove("ChangeCounter", function(ent)
			if not IsValid(pl) then return end
			counter(pl, getVehClass(ent), -1)
		end)
	end
end)

hook.Add("PlayerSpawnVehicle", "IGS", function(pl, _, class) -- model, class, table
	if IGS.PlayerHasOneOf(pl, IGS.ITEMS.SB.VEHS[class]) then -- покупал машину
		local can = canSpawn(pl, class)
		if not can then
			IGS.Notify(pl, "У вас есть заспавнена эта машина")
		end

		return can
	end
end, HOOK_HIGH)
--[[-------------------------------------------------------------------------
	/Машины
---------------------------------------------------------------------------]]

end) -- timer.Simple(0
