IGS.SERVERS = --[[ IGS.SERVERS or --]] setmetatable({
	ID   = function() return IGS.SERVERS.CURRENT end,
	Name = function() return IGS.SERVERS.MAP[IGS.SERVERS.CURRENT] end,

	-- Отправляет на клиент таблицу IGS.SERVERS
	Broadcast = function()
		-- нельзя nil
		IGS.nw.SetGlobal("igs_servers",true)
	end,

	MAP  = {}, -- id, name

	-- CURRENT -- int
	-- LOADED -- bool
	TOTAL   = 0, -- для считывания серверов в nw
	ENABLED = 0, -- для подсчета скидки
},{
	__call = function(self,id)
		return IGS.SERVERS.MAP[id]
	end
})


IGS.nw.Register("igs_servers")
	:Write(function()
		net.WriteUInt(IGS.SERVERS.CURRENT,16) -- 65535
		net.WriteUInt(IGS.SERVERS.TOTAL,8) -- 256
		net.WriteUInt(IGS.SERVERS.ENABLED,8) -- 256

		for id,name in pairs(IGS.SERVERS.MAP) do
			net.WriteUInt(id,16)
			net.WriteString(name)
		end
	end)
	:Read(function()
		IGS.SERVERS.CURRENT = net.ReadUInt(16)
		IGS.SERVERS.TOTAL   = net.ReadUInt(8)
		IGS.SERVERS.ENABLED = net.ReadUInt(8)

		for i = 1,IGS.SERVERS.TOTAL do
			IGS.SERVERS.MAP[net.ReadUInt(16)] = net.ReadString()
		end

		return IGS.SERVERS
	end)
:SetGlobal():SetHook("IGS.ServersLoaded")
