--[[-------------------------------------------------------------------------
	Для веб загрузки не подходит PermaProps аддон с воркшопа,
	поскольку он работает на InitPostEntity, который нельзя вызвать после веб загрузки

	Или можно..
---------------------------------------------------------------------------]]

local function getIndex()
	return util.JSONToTable(cookie.GetString("perma_index", "")) or {}
end

local function updateIndex(uid, class)
	local map = getIndex()
	map[uid] = class
	cookie.Set("perma_index", util.TableToJSON(map))
end

local function SpawnSent(class, pos, ang)
	local ent = ents.Create(class)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	return ent
end


function IGS.PermaSaveFeature(class)
	properties.Add(class .. "_perma_add", {
		MenuLabel = "Сохранить на карте",
		Order = 855,
		MenuIcon = "icon16/bullet_disk.png",

		Filter = function(self, ent, pl)
			return IsValid(ent) and pl:IsSuperAdmin() and ent:GetClass() == class
		end,
		Action = function(self, ent)
			self:MsgStart()
				net.WriteEntity( ent )
			self:MsgEnd()
		end,
		Receive = function(self, length, pl)
			local ent = net.ReadEntity()
			if not self:Filter(ent, pl) then return end

			if ent.permaSentUID then
				pl:ChatPrint("Эта энтити уже сохранена. Удалите и сохраните заново, если хотите переместить")
				return
			end

			local uid = math.random(0xFFFF)
			cookie.Set("perma_" .. class .. "_" .. uid, util.TableToJSON({ent:GetPos(), ent:GetAngles()}))
			pl:ChatPrint("Позиция сохранена под UID " .. uid)
			ent.permaSentUID = uid

			updateIndex(uid, class)
		end
	})

	properties.Add(class .. "_perma_delete", {
		MenuLabel = "Удалить с карты",
		Order = 856,
		MenuIcon = "icon16/bin_closed.png",

		Filter = function(self, ent, pl)
			return IsValid(ent) and pl:IsSuperAdmin() and ent:GetClass() == class
		end,
		Action = function(self, ent)
			self:MsgStart()
				net.WriteEntity( ent )
			self:MsgEnd()
		end,
		Receive = function(self, length, pl)
			local ent = net.ReadEntity()
			if not self:Filter(ent, pl) then return end

			if not ent.permaSentUID then
				pl:ChatPrint("Эта энтити не перманентная")
				return
			end

			local uid  = ent.permaSentUID
			cookie.Set("perma_" .. class .. "_" .. uid, nil)
			pl:ChatPrint("Объект удален. UID был " .. uid)
			ent:Remove()

			updateIndex(uid, nil)
		end
	})
end

if SERVER then
	hook.Add("IGS.Loaded", "IGS.PermaSents", function()
	timer.Simple(20, function()
		for _, ent in ipairs(ents.GetAll()) do
			if ent.permaSentUID then
				ent:Remove()
			end
		end

		local map = getIndex()
		for uid,class in pairs(map) do
			if not scripted_ents.GetStored(class) then
				print("IGS.PermaSents: " .. class .. " не существует на сервере")
				continue
			end

			local dat = util.JSONToTable(cookie.GetString("perma_" .. class .. "_" .. uid))
			local ent = SpawnSent(class, util.StringToType(dat[1], "Vector"), util.StringToType(dat[2], "Angle"))
			ent.permaSentUID = uid

			print("IGS.PermaSents: Заспавнили " .. class)
		end
	end)
	end)
end
