IGS.LVL = IGS.LVL or setmetatable({
	MAP    = {},
	STORED = {}
},{
	__call = function(self,...)
		return self.Add(...)
	end
})



local LVL = {}
LVL.__index = LVL

function LVL:SetBonus(fOnReach)
	self.bonus = fOnReach -- ply in args
	return self
end

function LVL:SetName(sName) -- OUTDATED (удалено 2018.03.12)
	self.name = sName
	return self
end

function LVL:SetDescription(sDesc)
	self.description = sDesc
	return self
end

function LVL:Name()
	return self.name
end

function LVL:Description()
	return self.description
end

function LVL:LVL()
	return self.lvl
end

function LVL:Cost()
	return self.cost
end

function LVL:GetNext() -- may be nil
	local ilvl,OBJ = next(IGS.LVL.MAP,self.lvl)
	return OBJ,ilvl
end

-- Разница между уровнями
-- function LVL:NeedToRaise() -- nil on last lvl
-- 	local n = self:GetNext()
-- 	return n and n.cost - self.cost
-- end

function IGS.LVL.Add(iNeedSum, sName)
	local OBJ = setmetatable({
		cost = iNeedSum,
		name = sName
	},LVL)

	IGS.LVL.STORED[iNeedSum] = OBJ
	IGS.LVL.Rearrange()

	return OBJ
end

function IGS.LVL.Get(iLVL)
	return IGS.LVL.MAP[iLVL]
end

-- Дает объект лвл, соответствующий указанной сумме
function IGS.LVL.GetByCost(iRealCost)
	for lvl = 1,#IGS.LVL.MAP do
		if !IGS.LVL.MAP[lvl + 1] or IGS.LVL.MAP[lvl + 1].cost > iRealCost then
			return IGS.LVL.MAP[lvl]
		end
	end
end

-- Уровни в диапазоне стоимости.
-- Начало юзаться при выдаче бонусов за пополнение: https://trello.com/c/EjmPOeso/476--
-- function IGS.LVL.GetRange(iFromCost, iToCost)
-- 	local t = {}

-- 	for iLVL,lvl in ipairs(IGS.LVL.MAP) do
-- 		if lvl.cost >= iFromCost and lvl.cost <= iToCost then
-- 			table.insert(t,lvl)
-- 		end
-- 	end

-- 	return t
-- end

-- Перестраивает кэш порядка левелов
-- Нужно на случай, если сначала добавили 30 лвл, а потом 10
-- то чтобы не считалось, что 30 ниже 10
function IGS.LVL.Rearrange()
	IGS.LVL.MAP = {} -- reset

	local i = 0
	for sum in SortedPairs(IGS.LVL.STORED) do
		-- долго объяснять. Короче сортедпэирс по ходу копирует объект перед тем,
		-- как вернуть его в цикл и нельзя сделать for sum,OBJ
		local OBJ = IGS.LVL.STORED[sum]
		i = i + 1
		OBJ.lvl = i

		IGS.LVL.MAP[i] = OBJ
	end
end