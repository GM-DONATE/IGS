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

-- До 16 фев 2022 передавались чисто ID предметов
-- Но веб лоад приводит к тому, что еще до загрузки самого игрока на сервер ему могли
-- передаваться ID предметов, которые на клиенте не успели создаться (например создавались в хуке IGS.Loaded)
IGS.nw.Register("igs_purchases"):Write(function(networked_purchases)
	local flatten = {}
	for uid, am in pairs(networked_purchases) do
		local s = #flatten
		flatten[s + 1] = uid
		flatten[s + 2] = am
	end

	net.WriteUInt(#flatten / 2, 8) -- 255

	for i = 1,#flatten,2 do
		net.WriteString(flatten[i])
		net.WriteUInt(flatten[i + 1], 9)
	end
end):Read(function()
	local res = {}
	for _ = 1,net.ReadUInt(8) do
		res[net.ReadString()] = net.ReadUInt(9)
	end
	return res
end):SetLocalPlayer():SetHook("IGS.PlayerPurchasesLoaded")


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
function net.WriteIGSItem(ITEM) net.WriteString(ITEM:UID()) end
function net.ReadIGSItem() return IGS.GetItemByUID(net.ReadString()) end
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
