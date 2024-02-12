-- Thanks to SuperiorServers.co

IGS.nw = {}

local vars     = {}
local mappings = {}
local data     = {
	[0] = {}
}
local globals   = data[0]
local callbacks = {}

local NETVAR   = {}
NETVAR.__index = NETVAR

MT_IGSNetVar = NETVAR

local bitmap = {
	[3]	  = 3,
	[7]   = 4,
	[15]  = 5,
	[31]  = 6,
	[63]  = 7,
	[127] = 8
}

local bitcount = 2

local ENTITY = FindMetaTable 'Entity'

local pairs  = pairs
local Entity = Entity

local net_WriteUInt = net.WriteUInt
local net_ReadUInt  = net.ReadUInt
local net_Start     = net.Start
local net_Send      = SERVER and net.Send or net.SendToServer
local net_Broadcast = net.Broadcast
local sorted_pairs  = SortedPairsByMemberValue

function IGS.nw.Register(var) -- You must always call this on both the client and server. It will serioulsy break shit if you don't.
	local t = {
		Name = var,
		NetworkString = 'IGS.nw_' .. var,
		WriteFunc = net.WriteType,
		ReadFunc = net.ReadType,
		SendFunc = function(self, ent, value, recipients)
			if (recipients ~= nil) then
				net_Send(recipients)
			else
				net_Broadcast()
			end
		end,
	}
	setmetatable(t, NETVAR)
	vars[var] = t

	if (SERVER) then
		util.AddNetworkString(t.NetworkString)
	else
		net.Receive(t.NetworkString, function()
			local index, value = t:_Read()

			if (not data[index]) then
				data[index] = {}
			end

			data[index][var] = value

			t:_CallHook(index, value)
		end)
	end

	return t:_Construct()
end

function NETVAR:Write(func, opt)
	self.WriteFunc = function(value)
		func(value, opt)
	end
	return self:_Construct()
end

function NETVAR:Read(func, opt)
	self.ReadFunc = function()
		return func(opt)
	end
	return self:_Construct()
end

function NETVAR:Filter(func)
	self.SendFunc = function(_, ent, value, recipients)
		net_Send(recipients or func(ent, value))
	end
	return self:_Construct()
end

function NETVAR:SetPlayer()
	self.PlayerVar = true
	return self:_Construct()
end

function NETVAR:SetLocalPlayer()
	self.LocalPlayerVar = true
	return self:_Construct()
end

function NETVAR:SetGlobal()
	self.GlobalVar = true
	return self:_Construct()
end

function NETVAR:SetNoSync()
	self.NoSync = true
	return self:_Construct()
end

function NETVAR:SetHook(name)
	self.Hook = name
	return self
end

function NETVAR:_Send(ent, value, recipients)
	net_Start(self.NetworkString)
		self:_Write(ent, value)
	self:SendFunc(ent, value, recipients)
end

function NETVAR:_CallHook(index, value)
	if self.Hook then
		if (index ~= 0) then -- not global
			hook.Call(self.Hook, GAMEMODE, Entity(index), value)
		else
			hook.Call(self.Hook, GAMEMODE, value)
		end
	end
end

function NETVAR:_Construct()
	local WriteFunc = self.WriteFunc
	local ReadFunc 	= self.ReadFunc

	if self.PlayerVar then
		self._Write = function(_, ent, value)
			net_WriteUInt(ent:EntIndex(), 7)
			WriteFunc(value)
		end
		self._Read = function(_)
			return net_ReadUInt(7), ReadFunc()
		end
	elseif self.LocalPlayerVar then
		self._Write = function(_, ent, value)
			WriteFunc(value)
		end
		self._Read = function(_)
			return LocalPlayer():EntIndex(), ReadFunc()
		end
		self.SendFunc = function(_, ent, value, recipients)
			net_Send(ent)
		end
	elseif self.GlobalVar then
		self._Write = function(_, ent, value)
			WriteFunc(value)
		end
		self._Read = function(_)
			return 0, ReadFunc()
		end
	else
		self._Write = function(_, ent, value)
			net_WriteUInt(ent:EntIndex(), 12)
			WriteFunc(value)
		end
		self._Read = function(_)
			return net_ReadUInt(12), ReadFunc()
		end
	end

	mappings = {}
	for k, v in sorted_pairs(vars, 'Name', false) do
		local c = #mappings + 1
		vars[k].ID = c
		mappings[c] = v
		if bitmap[c] then
			bitcount = bitmap[c]
		end
	end

	return self
end

function IGS.nw.GetGlobal(var)
	return globals[var]
end

function ENTITY:GetIGSVar(var)
	local index = self:EntIndex()
	return data[index] and data[index][var]
end

if (SERVER) then
	util.AddNetworkString 'IGS.nw.PlayerSync'
	util.AddNetworkString 'IGS.nw.NilEntityVar'
	util.AddNetworkString 'IGS.nw.NilPlayerVar'
	util.AddNetworkString 'IGS.nw.EntityRemoved'
	util.AddNetworkString 'IGS.nw.PlayerRemoved'

	net.Receive('IGS.nw.PlayerSync', function(len, pl)
		if (pl.IGSEntityCreated ~= true) then
			hook.Call('PlayerEntityCreated', GAMEMODE, pl)

			pl.IGSEntityCreated = true

			for index, _vars in pairs(data) do
				for var, value in pairs(_vars) do
					local ent = Entity(index)
					if (not vars[var].LocalPlayerVar and not vars[var].NoSync) or (ent == pl) then
						vars[var]:_Send(ent, value, pl)
					end
				end
			end

			if (callbacks[pl] ~= nil) then
				for i = 1, #callbacks[pl] do
					callbacks[pl][i](pl)
				end
			end
			callbacks[pl] = nil
		end
	end)

	hook.Add('EntityRemoved', 'IGS.nw.EntityRemoved', function(ent)
		local index = ent:EntIndex()
		if (index ~= 0) and (data[index] ~= nil) then -- For some reason this kept getting called on Entity(0), not sure why...
			if ent:IsPlayer() then
				net_Start('IGS.nw.PlayerRemoved')
					net_WriteUInt(index, 7)
				net_Broadcast()
			else
				net_Start('IGS.nw.EntityRemoved')
					net_WriteUInt(index, 12)
				net_Broadcast()
			end

			data[index] = nil
		end
	end)

	function IGS.nw.WaitForPlayer(pl, cback)
		if (pl.IGSEntityCreated == true) then
			cback(pl)
		else
			if (callbacks[pl] == nil) then
				callbacks[pl] = {}
			end
			callbacks[pl][#callbacks[pl] + 1] = cback
		end
	end

	function IGS.nw.SetGlobal(var, value)
		globals[var] = value
		if (value ~= nil) then
			vars[var]:_Send(0, value)
		else
			net_Start('IGS.nw.NilEntityVar')
				net_WriteUInt(0, 12)
				net_WriteUInt(vars[var].ID, bitcount)
			vars[var]:SendFunc(0, value)
		end
	end

	function ENTITY:SetIGSVar(var, value)
		local index = self:EntIndex()

		if (not data[index]) then
			data[index] = {}
		end

		data[index][var] = value

		if (value ~= nil) then
			vars[var]:_Send(self, value)
		else
			if self:IsPlayer() then
				net_Start('IGS.nw.NilPlayerVar')
				net_WriteUInt(index, 7)
			else
				net_Start('IGS.nw.NilEntityVar')
				net_WriteUInt(index, 12)
			end
				net_WriteUInt(vars[var].ID, bitcount)
			vars[var]:SendFunc(self, value)
		end
	end
else
	hook.Add('InitPostEntity', 'IGS.nw.InitPostEntity', function()
		net_Start('IGS.nw.PlayerSync')
		net_Send()
	end)

	net.Receive('IGS.nw.NilEntityVar', function()
		local index, id = net_ReadUInt(12), net_ReadUInt(bitcount)
		if data[index] and mappings[id] then
			data[index][mappings[id].Name] = nil
		end
	end)

	net.Receive('IGS.nw.NilPlayerVar', function()
		local index, id = net_ReadUInt(7), net_ReadUInt(bitcount)
		if data[index] and mappings[id] then
			data[index][mappings[id].Name] = nil
		end
	end)

	net.Receive('IGS.nw.EntityRemoved', function()
		data[net_ReadUInt(12)] = nil
	end)

	net.Receive('IGS.nw.PlayerRemoved', function()
		data[net_ReadUInt(7)] = nil
	end)
end
