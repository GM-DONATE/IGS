IGS.nw.Register("igs_lvl")
	:Write(net.WriteUInt,7) -- 127
	:Read(function()
		return IGS.LVL.Get(net.ReadUInt(7))
	end)
:SetLocalPlayer()


IGS.nw.Register("igs_balance") -- Должно быть ТОЛЬКО у клиентов!
	:Write(net.WriteDouble)
	:Read(net.ReadDouble)
:SetLocalPlayer() --:SetHook("OnIGSBalanceChanged")


IGS.nw.Register("igs_total_transactions")
	:Write(net.WriteUInt,17) -- 131071
	:Read(net.ReadUInt,17)
:SetLocalPlayer()


IGS.nw.Register("igs_purchases"):Write(function(v)
	net.WriteUInt(#v, 9) -- 511

	for _,id in ipairs(v) do
		net.WriteUInt(id,9)
	end
end):Read(function()

	local res = {}
	for _ = 1,net.ReadUInt(9) do
		local uid = IGS.GetItemByID( net.ReadUInt(9) ):UID()
		res[uid] = res[uid] and (res[uid] + 1) or 1
	end

	return res
end):SetLocalPlayer():SetHook("IGS.PlayerPurchasesLoaded")


-- https://img.qweqwe.ovh/1492003125937.png
IGS.nw.Register("igs_settings")
	:Write(function(t)
		net.WriteUInt(t[1],10) -- minimal charge (max 1023)
		net.WriteDouble(t[2])  -- currecy price
	end)
	:Read(function()
		return {
			net.ReadUInt(10), -- charge
			net.ReadDouble(), -- price
		}
	end)
:SetGlobal():SetHook("IGS.OnSettingsUpdated")



--[[--------------
	CONSTANTS
----------------]]
IGS.BIT_TX = 8 -- max транз в нетворке (255)
IGS.BIT_LATEST_PURCH = 6 -- 63

-- Размер ячейки
IGS.BIT_PURCH_ID = 32 -- 4294967295
IGS.BIT_INV_ID = 32
IGS.BIT_TX_ID = 32


--[[--------------
	.net Helpers
----------------]]
function net.WriteIGSItem(ITEM) net.WriteUInt(ITEM:ID(),9) end
function net.ReadIGSItem() return IGS.GetItemByID(net.ReadUInt(9)) end
-- function net.WriteIGSGroup(GROUP) net.WriteString(GROUP:Name()) end
-- function net.ReadIGSGroup() return IGS.GetGroup(net.ReadString()) end

local function writeIf(value, fWrite, arg_)
	-- Server = 0 записывал false, хоть это значение
	-- Для отлова бага была такая штука:
	-- https://img.qweqwe.ovh/1567089471715.png
	net.WriteBool(value ~= nil)
	if value then
		fWrite(value, arg_)
	end
end

local function readIf(fRead, arg_)
	return net.ReadBool() and fRead(arg_)
end

function net.WriteIGSPurchase(p)
	net.WriteUInt(p.ID,IGS.BIT_PURCH_ID)
	net.WriteString(p.Item)

	writeIf(p.Server,  net.WriteUInt, 6) -- 63
	writeIf(p.Purchase,net.WriteUInt, 32)
	writeIf(p.Expire,  net.WriteUInt, 32)
	writeIf(p.Nick,    net.WriteString)
end

function net.ReadIGSPurchase()
	return {
		id       = net.ReadUInt(IGS.BIT_PURCH_ID),
		item     = net.ReadString(),

		server   = readIf(net.ReadUInt, 6),
		purchase = readIf(net.ReadUInt, 32),
		expire   = readIf(net.ReadUInt, 32),
		nick     = readIf(net.ReadString),
	}
end

function net.WriteIGSTx(tx)
	net.WriteUInt(tx.ID, IGS.BIT_TX_ID)
	writeIf(tx.Server, net.WriteUInt, 6) -- 63
	net.WriteDouble(tx.Sum)
	net.WriteUInt(tx.Time, 32) -- dohuya
	writeIf(tx.Note, net.WriteString)
end

function net.ReadIGSTx()
	return {
		id     = net.ReadUInt(IGS.BIT_TX_ID),
		server = readIf(net.ReadUInt, 6),
		sum    = net.ReadDouble(),
		date   = net.ReadUInt(32), -- timestamp
		note   = readIf(net.ReadString),
	}
end

function net.WriteIGSInventoryItem(inv_it)
	net.WriteUInt(inv_it.ID, IGS.BIT_INV_ID)
	net.WriteString(inv_it.Item)
end

function net.ReadIGSInventoryItem()
	return {
		id = net.ReadUInt(IGS.BIT_INV_ID),
		item = IGS.GetItemByUID(net.ReadString()),
	}
end

function net.WriteIGSMessage(sErr)
	writeIf(sErr, net.WriteString)
end

function net.ReadIGSMessage()
	return net.ReadBool() and net.ReadString()
end

net.WriteIGSError = net.WriteIGSMessage
net.ReadIGSError  = net.ReadIGSMessage



if SERVER then
	local first_time_trigger = true -- не позволяет выполниться IGS.GetMinCharge() и IGS.GetCurrencyPrice(), поскольку будет ошибка из-за nil внутри net вара
	function IGS.UpdateMoneySettings(iMinCharge,iCurrencyPrice)
		iMinCharge     = tonumber(iMinCharge)
		iCurrencyPrice = tonumber(iCurrencyPrice)

		-- Кеш старых данных
		local min_charge = first_time_trigger and 0 or IGS.GetMinCharge()
		local cur_price  = first_time_trigger and 0 or IGS.GetCurrencyPrice()
		first_time_trigger = nil

		local min_charge_changed = min_charge ~= iMinCharge
		local cur_price_changed  = cur_price  ~= iCurrencyPrice

		if min_charge_changed or cur_price_changed then
			IGS.nw.SetGlobal("igs_settings",{
				iMinCharge,
				iCurrencyPrice
			})

			hook.Run("IGS.OnSettingsUpdated")

			-- Может измениться сразу две вещи
			if min_charge_changed then
				IGS.NotifyAll("Изменена минимальная сумма пополнения: " .. ("(%s > %s руб)"):format(min_charge,iMinCharge))
			end

			if cur_price_changed then
				IGS.NotifyAll("Стоимость донат валюты изменена с " .. cur_price .. " до " .. iCurrencyPrice .. " руб за единицу")
			end
		end
	end
end
