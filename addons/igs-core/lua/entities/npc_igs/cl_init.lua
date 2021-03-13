IGS.sh("shared.lua")

-- #todo сделать такое же для подарка?

local COL_TEXT = Color(255,255,255)
local COL_BG   = Color(0,0,0,150)
local FONT     = "igs.40"

local function textPlate(text,y)
	surface.SetFont(FONT)
	local tw,th = surface.GetTextSize(text)
	local bx,by = -tw / 2 - 10, y - 5
	local bw,bh = tw + 10 + 10, th + 10 + 10

	-- Background
	surface.SetDrawColor(COL_BG)
	surface.DrawRect(bx,by, bw,bh)
	surface.SetDrawColor(COL_TEXT)
	surface.DrawRect(bx, by + bh - 4, bw, 4)

	-- text
	surface.SetTextColor(COL_TEXT)
	surface.SetTextPos(-tw / 2,y)
	surface.DrawText(text)
end

local function drawInfo(ent, text, dist)
	dist = dist or EyePos():DistToSqr(ent:GetPos())

	if dist < 60000 then
		surface.SetAlphaMultiplier( math.Clamp(3 - (dist / 20000), 0, 1) )

		local _,max = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs() )
		local rot = (ent:GetPos() - EyePos()):Angle().yaw - 90
		local sin = math.sin(CurTime() + ent:EntIndex()) / 3 + .5 -- EntIndex дает разницу в движении
		local center = ent:LocalToWorld(ent:OBBCenter())

		cam.Start3D2D(center + Vector(0, 0, math.abs(max.z / 2) + 12 + sin), Angle(0, rot, 90), 0.13)
			textPlate(text,15)
		cam.End3D2D()

		surface.SetAlphaMultiplier(1)
	end
end

-- https://vk.com/gim143836547?msgid=46147&q=рендер&sel=88943099
IGS_NPC_HIDE_ON_DISTANCE = nil -- 100000
function ENT:Draw()
	local dist = EyePos():DistToSqr(self:GetPos())
	if IGS_NPC_HIDE_ON_DISTANCE and dist > IGS_NPC_HIDE_ON_DISTANCE then return end -- не отрисовывать

	self:DrawModel()
	drawInfo(self, "Донат услуги", dist)
end
