ENT.Type      = "anim"
ENT.Base      = "base_anim"
ENT.PrintName = "Донат итем"
ENT.Author    = "GMDonate"
ENT.Category  = "IGS"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("String", 0, "UID")
end
