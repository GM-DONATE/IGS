-- источник и альтернативные решения:
-- https://forum.gm-donate.net/t/usluga-beskonechnye-patrony/633/10?u=gmd

-- IGS("Бесконечные патроны", "infammo", 100)
-- 	:SetInfAmmo()
-- 	:SetTerm(10)

local ITEM = FindMetaTable("IGSItem")

local function setInfAmmo(pl)
	local weapon = pl:GetActiveWeapon()
	if not IsValid(weapon) then return end

	local maxClip      = weapon:GetMaxClip1()
	local maxClip2     = weapon:GetMaxClip2()
	local primAmmoType = weapon:GetPrimaryAmmoType()
	local secAmmoType  = weapon:GetSecondaryAmmoType()

	if maxClip == -1 and maxClip2 == -1 then
		maxClip = 100
		maxClip2 = 100
	end

	if maxClip <= 0 and primAmmoType ~= -1 then
		maxClip = 1
	end

	if maxClip2 == -1 and secAmmoType ~= -1 then
		maxClip2 = 1
	end

	if maxClip > 0 then
		weapon:SetClip1(maxClip)
	end

	if maxClip2 > 0 then
		weapon:SetClip2(maxClip2)
	end

	if primAmmoType ~= -1 then
		pl:SetAmmo( maxClip, primAmmoType, true)
	end

	if secAmmoType ~= -1 and secAmmoType ~= primAmmoType then
		pl:SetAmmo( maxClip2, secAmmoType, true)
	end
end


local infammo_players = {}

timer.Create("igs_infammo", 3.3, 0, function()
	if not infammo_players[1] then return end

	for i = #infammo_players, 0, -1 do -- reversed ipairs
		local pl = infammo_players[i]
		if IsValid(pl) then
			setInfAmmo(pl)
		else
			table.remove(infammo_players, i)
		end
	end
end)

function ITEM:SetInfAmmo()
	return self:SetInstaller(function(pl)
		if not table.HasValue(infammo_players, pl) then
			table.insert(infammo_players, pl)
		end
	end):SetValidator(function(pl)
		return false
	end)
end
