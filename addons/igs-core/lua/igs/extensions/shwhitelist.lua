-- Автор @Joch
-- Тут и пример использования
-- https://forum.gm-donate.net/t/2129/7

local ITEM = MT_IGSItem

function ITEM:SetSHWhitelist(team_cmd)
	return self:SetCanActivate(function(pl)
		if SH_WHITELIST:CanBecomeJob(pl, DarkRP.getJobByCommand(team_cmd)) then
			return "Вы в вайтлисте"
		end
	end):AddHook("SH_WHITELIST.CanBecomeJob", function(pl, job)
		if job.command == team_cmd then return true end
	end):SetValidator(function(pl)
		return SH_WHITELIST:CanBecomeJob(pl, DarkRP.getJobByCommand(team_cmd))
	end)
end
