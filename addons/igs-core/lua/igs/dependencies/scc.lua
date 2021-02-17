-- Simple Chat Commands
-- Special for IGS by _AMD_
-- 2019.11.08 01:47

scc = {
	commands = {},
}

if SERVER then
	util.AddNetworkString("scc.run")
end

function scc.add(command, callback)
	scc.commands[command:lower()] = callback
end

function scc.run(pl, command, args)
	local callback = scc.commands[command:lower()]
	callback(pl, unpack(args or {}))
end


if SERVER then
	hook.Add("PlayerSay", "scc", function(pl, text)
		text = text:Trim()
		if text[1] == "/" then
			local pieces  = text:Split(" ")
			local command = pieces[1]:sub(2):lower()

			if scc.commands[command] then
				local args = {}
				for i = 2,#pieces do
					args[#args + 1] = pieces[i]
				end

				scc.run(pl, command, args)
				return ""
			end
		end
	end)
end


--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]

local PLAYER = FindMetaTable("Player")
function PLAYER:RunSCC(command, ...)
	scc.run(self, command, {...})
end

-- function scc.addWithCooldown(cooldown, command, callback)
-- 	local runIfNotCooldown = function(pl, ...)
-- 		if !pl.sccLastRun then pl.sccLastRun = {} end
-- 		if CurTime() - (pl.sccLastRun[command] or 0) >= cooldown then
-- 			pl.sccLastRun[command] = CurTime()
-- 			callback(pl, ...)
-- 		end
-- 	end

-- 	scc.add(command, runIfNotCooldown)
-- end

if SERVER then
	util.AddNetworkString("scc.run")
else
	net.Receive("scc.run", function()
		local command = net.ReadString()
		local args = {}
		for i = 1, net.ReadUInt(4) do
			args[i] = net.ReadString()
		end

		scc.run(LocalPlayer(), command, args)
	end)
end

function scc.addClientside(command, callback)
	local runOnClient = SERVER and function(pl, ...)
		local args = {...}
		net.Start("scc.run")
			net.WriteString(command)
			net.WriteUInt(#args, 4)
			for _,arg in ipairs(args) do
				net.WriteString(arg)
			end
		net.Send(pl)
	end or callback

	scc.add(command, runOnClient)
end
