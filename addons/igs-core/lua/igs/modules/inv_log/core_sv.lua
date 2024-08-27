IGS.IL = IGS.IL or { -- InventoryLogger
	["NEW"] = 1, -- покупка итема
	["ACT"] = 2, -- активация
	["DROP"] = 3,
	["PICK"] = 4,
}

util.AddNetworkString("IGS.InvLog")
util.AddNetworkString("IGS.NameRequest")
util.AddNetworkString("IGS.DeactivateItem")

local function WriteLog(tLog)
	net.WriteUInt(tLog[0],22) -- 4194305 (Кол-во записей всего)
	net.WriteUInt(#tLog,6) -- 63 (По 50 лимит на страницу)

	for _,row in ipairs(tLog) do
		net.WriteString(row.owner)
		net.WriteString(row.inflictor)
		net.WriteString(row.gift_uid)
		net.WriteUInt(row.gift_id,22)   -- 4194305
		net.WriteUInt(row.action,3)     -- 7
		net.WriteUInt(row.action_id,22) -- 4194305
		net.WriteUInt(row.date,32)      -- 4294967295
	end
end

local function ShitLog()
	local log = {}
	log[0] = 5
	for i = 1,log[0] do
		log[i] = {
			owner     = util.SteamIDTo64("STEAM_0:1:23456789"),
			inflictor = util.SteamIDTo64("STEAM_0:1:23456789"),
			gift_uid  = "Только для SuperAdmin",
			gift_id   = 1337,
			action    = 0,
			action_id = 1488,
			date      = os.time(),
		}
	end
	return log
end

net.Receive("IGS.InvLog",function(_, pl)
	-- Или s64_owner или gift_uid
	local s64_owner = net.ReadBool() and net.ReadString()
	local gift_uid  = net.ReadBool() and net.ReadString()
	local iPage     = net.ReadBool() and net.ReadUInt(8)
	local cb_id     = net.ReadUInt(3) -- 7


	local tLog = pl:IsSuperAdmin() and IGS.IL.GetLog(50, iPage, s64_owner, gift_uid) or ShitLog()
	net.Start("IGS.InvLog")
		net.WriteUInt(cb_id,3) -- 7
		WriteLog(tLog)
	net.Send(pl)
end)

net.Receive("IGS.NameRequest",function(_, pl)
	if not pl:IsSuperAdmin() then return end

	local s64 = net.ReadString()
	IGS.GetPlayer(s64, function(d_)
		net.Start("IGS.NameRequest")
			net.WriteString(s64)

			if d_ then
				net.WriteBool(true)
				net.WriteString(Format("%d - %s", d_.Score, d_.Name))
			else
				net.WriteBool(false)
			end
		net.Send(pl)
	end)
end)

net.Receive("IGS.DeactivateItem", function(_, pl)
	local iPurchID = net.ReadUInt(IGS.BIT_PURCH_ID)
	if not (iPurchID and pl:IsSuperAdmin()) then return end

	IGS.DisablePurchase(iPurchID, function(bUpdated)
		IGS.Notify(pl, bUpdated and IGS.GetPhrase("deactivated") or IGS.GetPhrase("alrdeactivated"))
	end)
end)




-- Вносит новое значение
function IGS.IL.Log(iGiftOrPurchaseId, sGiftUID, s64_owner, s64_inflictor, iActionId)
	sGiftUID = sql.SQLStr(sGiftUID)

	sql.Query([[
		INSERT INTO `igs_inv_log`(`gift_id`,`gift_uid`,`owner`,`inflictor`,`action`,`date`)
		VALUES (]] ..
			iGiftOrPurchaseId .. [[, ]] .. sGiftUID .. [[, ]] .. s64_owner .. [[, ]] .. s64_inflictor .. [[, ]] .. iActionId .. [[, ]] .. os.time() ..
		[[)
	]])
end

-- Параметры опциональны
function IGS.IL.GetLog(iLimit, iPage, s64_owner, gift_uid)
	sql.Begin()

	local q = "SELECT * FROM `igs_inv_log`"
	if s64_owner then
		q = q .. " WHERE `owner` = " .. sql.SQLStr(s64_owner)
	elseif gift_uid then
		q = q .. " WHERE `gift_uid` = " .. sql.SQLStr(gift_uid)
	end

	q = q .. " ORDER BY `action_id` DESC"

	if iLimit then
		q = q .. " LIMIT " .. iLimit

		if iPage then
			q = q .. " OFFSET " .. (iPage * iLimit - iLimit)
		end
	end

	local q_count = "SELECT COUNT(*) FROM `igs_inv_log`"
	if s64_owner then
		q_count = q_count .. " WHERE `owner` = " .. sql.SQLStr(s64_owner)
	end

	local total = sql.QueryValue(q_count)
	local log   = sql.Query(q) or {}
	log[0] = total

	sql.Commit()
	return log
end
-- PRINT(IGS.IL.GetLog(50, 1, AMD():SteamID64()))
-- PRINT(IGS.IL.GetLog(50, 1, nil, "chat_prefix"))

function IGS.IL.CreateTable()
	sql.Begin()

	sql.Query([[
	CREATE TABLE IF NOT EXISTS `igs_inv_log` (
		`action_id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		`gift_id`   INTEGER NOT NULL,
		`gift_uid`  TEXT    NOT NULL,
		`owner`     TEXT    NOT NULL,
		`inflictor` TEXT    NOT NULL,
		`action`    NUMERIC NOT NULL,
		`date`      INTEGER NOT NULL
	);
	]])

	sql.Query("CREATE INDEX `owner` ON `igs_inv_log` (`owner`)")

	sql.Commit()
end

IGS.IL.CreateTable()
