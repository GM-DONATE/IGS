local STORE_ITEM = MT_IGSItem

function STORE_ITEM:SetPremiumPoints(iAmount)
	return self:SetInstaller(function(pl)
		pl:PS2_AddPremiumPoints(iAmount)
	end):SetMeta("ps2_prempoints", iAmount)
end

function STORE_ITEM:SetPoints(iAmount)
	return self:SetInstaller(function(pl)
		pl:PS2_AddStandardPoints(iAmount, "/donate")
	end):SetMeta("ps2_points", iAmount)
end
