-- Можно и забирать, указав минусовое число
local PLAYER = FindMetaTable("Player")
function PLAYER:AddIGSFunds(amount, note, callback)
	IGS.Transaction(self:SteamID64(),amount,note,function()
		local newbal = self:IGSFunds() + amount
		self:SetIGSVar("igs_balance", newbal)

		if amount > 0 then
			local tt = IGS.TotalTransaction(self) + amount
			self:SetIGSVar("igs_total_transactions", tt)

			self:SetIGSVar("igs_lvl", IGS.LVL.GetByCost( tt ):LVL())
		end

		if callback then
			callback(newbal)
		end
	end)
end


--[[-------------------------------------------------------------------------
	Покупки
---------------------------------------------------------------------------]]
function IGS.LoadPlayerPurchases(pl,cb)
	-- Список покупок
	IGS.GetPlayerPurchases(pl:SteamID64(), function(dat)
		if #dat == 0 and IsValid(pl) then
			hook.Run("IGS.PlayerPurchasesLoaded",pl)
			pl:SetIGSVar("igs_purchases", {}) -- для хука. Ниже описано
			return
		end

		local purchases = {} -- uid = amount
		local networked = {} -- uid = amount (было i>id до 16.02.2022, но веб загрузка потребовала перемен)

		for i = 1,#dat do
			local uid = dat[i]["Item"]
			purchases[uid] = (purchases[uid] or 0) + 1

			if IGS.GetItemByUID(uid).networked then
				networked[uid] = (networked[uid] or 0) + 1
			end
		end

		if IsValid(pl) then
			-- UID = Amount Of Purchases
			pl:SetVar("igs_purchases",purchases)

			-- print("IGS.GetPlayerPurchases processed",pl)
			IGS.nw.WaitForPlayer(pl, function()
				-- print("IGS.nw.WaitForPlayer INSIDE",pl)
				pl:SetIGSVar("igs_purchases", networked)
			end)

			hook.Run("IGS.PlayerPurchasesLoaded",pl,purchases)
		end

		if cb then cb(purchases) end
	end)
end

-- Выдает покупку. Без сохранения
function IGS.GivePurchase(pl, sItemUID)
	local ITEM = IGS.GetItemByUID(sItemUID)

	local purchases = pl:GetVar("igs_purchases",{})
	purchases[sItemUID] = (purchases[sItemUID] or 0) + 1

	pl:SetVar("igs_purchases",purchases)

	if ITEM.networked then
		local tab = pl:GetIGSVar("igs_purchases") or {}
		tab[sItemUID] = (tab[sItemUID] or 0) + 1
		pl:SetIGSVar("igs_purchases", tab)
	end

	ITEM:OnActivate(pl)
	return ITEM
end

-- При первой активации предмета
-- Выдает и сохраняет покупку.
-- В каллбэке ID предмета с БД
function IGS.PlayerActivateItem(pl, sItemUID, fCallback)
	local ITEM = IGS.GetItemByUID(sItemUID)

	IGS.StoreLocalPurchase(pl:SteamID64(), sItemUID, ITEM:Term(), function(iPurchID)
		IGS.GivePurchase(pl, sItemUID)
		hook.Run("IGS.PlayerActivatedItem", pl, ITEM, iPurchID)
		if fCallback then fCallback(iPurchID) end
	end)
end
IGS.PlayerActivatedItem = IGS.PlayerActivateItem -- #todo обратка 2020.07.16

-- После :CanBuy() проверок и списания средств
function IGS.PlayerPurchasedItem(pl, ITEM, cb)
	local afterBuy = function(invDbID_or_iPurchID)
		local id = invDbID_or_iPurchID
		ITEM:Buy(pl) -- внутри хук
		hook.Run("IGS.PlayerPurchasedItem", pl, ITEM, id)
		if cb then cb(id) end
	end

	if IGS.C.Inv_Enabled then
		IGS.AddToInventory(pl, ITEM:UID(), afterBuy)
	else
		IGS.PlayerActivateItem(pl, ITEM:UID(), afterBuy)
	end
end


--[[-------------------------------------------------------------------------
	КУПОНЫ
---------------------------------------------------------------------------]]
local trans = {
	["COUP_DOESNT_EXIST"] = "Купон не существует!",
	["COUP_EXPIRED"]      = "Срок действия купона истек!",
	["COUP_ACTIVATED"]    = "Купон уже активирован!",
}

-- https://trello.com/c/6Oc1DykD/312
-- На больших серверах при раздаче купонов будет слишком много запросов к GMD,
-- что приведет к блоку API
local coupons_errors = setmetatable({proxy = {}},{
	__newindex = function(self, sCoupon, sErrorCode)
		self.proxy[sCoupon] = sErrorCode

		timer.Create("IGS.CouponsCacheCleanup",60,1,function()
			table.Empty(self.proxy)
		end)
	end,
	__index = function(self, sCoupon)
		local err_code = self.proxy[sCoupon]
		if err_code then
			return trans[err_code]
		end
	end
})

function IGS.PlayerActivateCoupon(pl, sCoupon, cb)
	cb = cb or function() end

	if coupons_errors[sCoupon] then
		cb(false, coupons_errors[sCoupon])
		return
	end

	IGS.GetCoupon(sCoupon,function(c,expired,used)
		local err_code =
			not c   and "COUP_DOESNT_EXIST" or
			expired and "COUP_EXPIRED" or
			used    and "COUP_ACTIVATED"

		if err_code then
			coupons_errors[sCoupon] = err_code
			cb(false, coupons_errors[sCoupon])
			return
		end

		IGS.DeactivateCoupon(pl:SteamID64(),sCoupon,function(affected)
			coupons_errors[sCoupon] = "COUP_ACTIVATED"

			if not affected then
				cb(false, "Купон уже активирован. Кстати, это очень(!) редкая ошибка. Сообщите администрации, тут должна была вылезти другая")
				return -- /\ однажды эта ошибка вылезла, когда я в цикле с клиента пытался активировать купон (https://img.qweqwe.ovh/1487848973964.png)
			end -- в бд не изменен ни один купон

			IGS.UpdatePlayerName(pl:SteamID64(),pl:Nick())
			pl:AddIGSFunds(c.Value,"C: " .. sCoupon,function()
				cb(true)
			end)
		end)
	end)
end


--[[-------------------------------------------------------------------------
	ИНВЕНТАРЬ
---------------------------------------------------------------------------]]
local function CreateInvStructure(pl)
	pl.igs_inv = {
		MAP  = {}, -- db_id, data
		LIST = {}  -- iter,  data
	}
end

local function insertInvData(pl,iId,sItem)
	local d = {
		ID     = iId,
		Item   = sItem,
	}

	pl.igs_inv.MAP[iId] = d
	d.listid = table.insert(pl.igs_inv.LIST,d)
end

function IGS.Inventory(pl,bMap)
	return pl.igs_inv and pl.igs_inv[bMap and "MAP" or "LIST"]
end

local f = function() end

function IGS.AddToInventory(pl,sUid,fOnFinish_)
	IGS.StoreInventoryItem(function(inserted_id)
		if not IGS.Inventory(pl) then
			CreateInvStructure(pl)
		end

		insertInvData(pl,inserted_id,sUid)

		if fOnFinish_ then
			fOnFinish_(inserted_id)
		end
	end, pl:SteamID64(),sUid)
end
-- IGS.AddToInventory(AMD(),"money_5mi",PRINT)

-- https://img.qweqwe.ovh/1527524052957.png
function IGS.LoadInventory(pl,cb)
	IGS.FetchInventory(function(d)
		cb = cb or f
		if #d == 0 then cb() return end

		CreateInvStructure(pl)

		for _,v in ipairs(d) do
			insertInvData(pl,v.ID,v.Item)
		end

		cb(pl.igs_inv)
	end, pl:SteamID64())
end
-- IGS.LoadInventory(AMD(),prt)

local function GetPlayerInventoryItemLocally(pl, invDbID)
	local inv_map  = IGS.Inventory(pl,"map")
	local inv_list = IGS.Inventory(pl)

	if (not inv_map) then return false end -- у чела нет донат услуг. Наверн байпас, если запрос с клиента

	local t = inv_map[invDbID]
	if (not t) then return false end -- подсунут левый ИД, который уже удален или не существовал

	function t:Delete()
		assert(inv_map[invDbID],"Итем #" .. invDbID .. " не существует (уже удален?)")

		inv_map[invDbID] = nil
		table.remove(inv_list, t.listid)

		for i = t.listid,#inv_list do
			inv_list[i].listid = i
		end
	end

	return t
end

function IGS.DeletePlayerInventoryItemLocally(pl, invDbID)
	local t = GetPlayerInventoryItemLocally(pl, invDbID)
	if (not t) then return false end

	t:Delete()

	return t
end

function IGS.PlayerEjectItem(cb, pl, invDbID)
	cb = cb or f

	local tRemoved = IGS.DeletePlayerInventoryItemLocally(pl, invDbID)
	if (not tRemoved) then -- байпасы
		cb(false)
		return
	end

	IGS.DeleteInventoryItem(function(ok)
		if (not ok) then -- мб в панели удалили
			return cb(false)
		end

		local pos = LocalToWorld( Vector(50,0,35),Angle(0,0,0), pl:GetPos(),pl:GetAngles() )
		local ent = IGS.CreateGift(tRemoved.Item, pl, pos)

		cb(ent)
	end, invDbID)
end

function IGS.IsInventoryOverloaded(pl)
	return #(IGS.Inventory(pl) or {}) >= 100
end
--[[-------------------------------------------------------------------------
	//ИНВЕНТАРЬ
---------------------------------------------------------------------------]]
