IGS.sh("shared.lua")
IGS.cl("cl_init.lua")

function ENT:Initialize()
	-- self:SetModel("models/props_junk/Shoe001a.mdl") -- ботинок
	-- self:SetModel("models/christmas_gift2/christmas_gift2.mdl") -- подарок

	self:SetModel("models/dav0r/hoverball.mdl")
	self:SetModelScale(1.5)
	self:SetAngles(Angle(90, 0, 0))

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
end

-- Чтобы нельзя было убить NPC
function ENT:OnTakeDamage()
	return 0
end

function ENT:Use(_, caller)
	if caller:IsPlayer() then
		self:PlayerUse(caller)
	end
end

function ENT:PlayerUse(pl)
	if IGS.IsInventoryOverloaded(pl) then
		IGS.Notify(pl, "У вас слишком много предметов в инвентаре")
		return
	end

	if self.Busy or self.Removed then -- хз нужно ли именно здесь, но я добавил
		-- https://vk.com/gim143836547?sel=383010676&msgid=90338
		if CurTime() - self.Busy > 5 then
			IGS.Notify(pl,"Предмет в процессе перемещения в инвентарь")
			IGS.Notify(pl,"Если процесс бесконечный, то поскорее сделайте доказательства и сообщите администратору")
		end
		return
	end
	self.Busy = CurTime()

	local UID = self:GetUID()
	IGS.AddToInventory(pl, UID, function(invDbID)
		self.Removed = true
		self:Remove()

		IGS.Notify(pl,"Предмет помещен в /donate инвентарь")

		-- вставлять новый ID не совсем корректно
		-- Думаю, надо кешировать тот ИД, что был при покупке
		hook.Run("IGS.PlayerPickedGift", self:Getowning_ent(), UID, invDbID, pl)
	end)
end

function IGS.CreateGift(sUid, plOwner, vPos)
	assert(sUid, "Item UID expected")

	local ent = ents.Create("ent_igs")

	if vPos then
		ent:SetPos(vPos)
	end

	ent:SetUID(sUid)
	ent:Setowning_ent(plOwner)

	if vPos then
		ent:Spawn()
	end

	return ent
end
