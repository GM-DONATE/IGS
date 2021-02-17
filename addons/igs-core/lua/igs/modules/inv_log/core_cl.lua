IGS.IL = IGS.IL or {}

local callbacks,last,MAX = {},0,7
function IGS.IL.GetLog(fCb, iPage, s64_owner, gift_uid)
	net.Start("IGS.InvLog")
		net.WriteBool(s64_owner)
		if s64_owner then
			net.WriteString(s64_owner)
		end

		net.WriteBool(gift_uid)
		if gift_uid then
			net.WriteString(gift_uid)
		end

		net.WriteBool(iPage)
		if iPage then
			net.WriteUInt(iPage,8)
		end

		last = (last + 1) % MAX + 1
		callbacks[last] = fCb

		net.WriteUInt(last,3)
	net.SendToServer()
end
-- IGS.IL.GetLog(PRINT, 1, nil, "chat_prefix")

net.Receive("IGS.InvLog", function()
	local cb_id = net.ReadUInt(3)
	local cb = callbacks[cb_id]
	-- prt({callbacks = callbacks,cb_id = cb_id})
	assert(cb,"No callback with id " .. cb_id)

	local data = {[0] = net.ReadUInt(22)}
	for i = 1,net.ReadUInt(6) do
		data[i] = {
			owner     = net.ReadString(),
			inflictor = net.ReadString(),
			gift_uid  = net.ReadString(),
			gift_id   = net.ReadUInt(22),
			action    = net.ReadUInt(3),
			action_id = net.ReadUInt(22),
			date      = net.ReadUInt(32),
		}
	end

	cb(data)
	callbacks[cb_id] = nil
end)



local sid_to_name_cache = {}
function IGS.IL.NameRequest(fCb, s64)
	if sid_to_name_cache[s64] then -- cached or queued {}
		local cached = sid_to_name_cache[s64][0]
		if cached ~= nil then
			fCb(cached) -- mb false
		else -- добавляем еще одного желающего получить результат запроса
			table.insert(sid_to_name_cache[s64], fCb)
		end
	else
		-- скок же я проебался, забыв добавить в таблицу fCb
		sid_to_name_cache[s64] = {fCb}
		net.Start("IGS.NameRequest")
			net.WriteString(s64)
		net.SendToServer()
	end
end

net.Receive("IGS.NameRequest", function()
	local requested_s64 = net.ReadString()
	local name_ = net.ReadBool() and net.ReadString()

	local cbs = sid_to_name_cache[requested_s64]
	for i = #cbs,1,-1 do
		cbs[i](name_ or false)
		cbs[i] = nil
	end
	cbs[0] = name_ -- cache
end)
-- IGS.IL.NameRequest(PRINT, AMD():SteamID64())
-- IGS.IL.NameRequest(PRINT, "76561198109429966")


function IGS.DeactivateItem(iPurchID)
	net.Start("IGS.DeactivateItem")
		net.WriteUInt(iPurchID, IGS.BIT_PURCH_ID)
	net.SendToServer()
end
