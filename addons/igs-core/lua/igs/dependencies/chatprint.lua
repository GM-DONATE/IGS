if TRIGON then return end


if SERVER then
	util.AddNetworkString("ChatPrintColor")


	local function sayColor(targ, ...)
		local args = {...}
		-- PrintTable(args)
		net.Start("ChatPrintColor")
			net.WriteTable(IsColor(args[1]) and args or args[1])
		net[targ and "Send" or "Broadcast"](targ)
	end

	local PLAYER = FindMetaTable("Player")
	function PLAYER:ChatPrintColor(...)
		sayColor(self, ...)
	end

	chat = chat or {}
	function chat.AddTextSV(...)
		sayColor(nil, ...)
	end

else
	net.Receive("ChatPrintColor",function()
		chat.AddText(unpack(net.ReadTable()))
	end)
end
