-- Автор @Joch
-- https://forum.gm-donate.net/t/sh-whitelist-dobavlenie-professii/2129/7

local ITEM = FindMetaTable("IGSItem")

function ITEM:SetSHWhitelist(team_cmd)
	return self:SetCanActivate(function(pl)
		if SH_WHITELIST:CanBecomeJob(pl, DarkRP.getJobByCommand(team_cmd)) then
			return "Вы в вайтлисте"
		end
	end):AddHook("SH_WHITELIST.CanBecomeJob", function(pl, job)
		return job.command == team_cmd
	end):SetValidator(function(pl)
		return SH_WHITELIST:CanBecomeJob(pl, DarkRP.getJobByCommand(team_cmd))
	end)
end
