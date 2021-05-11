-- Для предложения совершения покупок в определенных ситуациях
-- /igsitem group_premium_30d

if SERVER then
	local function RunCommand(c)
		return function(pl, arg) pl:RunSCC(c, arg) end
	end

	IGS.WIN = IGS.WIN or {}
	IGS.WIN.Item    = RunCommand("IGSItem")
	IGS.WIN.Group   = RunCommand("IGSGroup")
	IGS.WIN.Deposit = RunCommand("IGSDeposit")
end

scc.addClientside("IGSItem",    function(_, arg) IGS.WIN.Item(arg)    end)
scc.addClientside("IGSDeposit", function(_, arg) IGS.WIN.Deposit(arg) end)
scc.addClientside("IGSGroup",   function(_, arg) IGS.WIN.Group(arg)   end)


IGS.PermaSaveFeature("npc_igs")
