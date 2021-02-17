if TRIGON then return end

local function plural_type(i)
	return i % 10 == 1 and i % 100 ~= 11 and 1
		or (i % 10 >= 2 and i % 10 <= 4 and (i % 100 < 10 or i % 100 >= 20) and 2
			or 3
		)
end


PL = PL or setmetatable({
	list = {}
},{__call = function(self,name,i)
	return self.Get(name,i)
end})

local mt = {__call = function(self,i)
	local pl = self[ plural_type(i) ]
	return i .. " " .. pl, pl
end}




function PL.Add(name,plurals)
	PL.list[name] = setmetatable(plurals,mt)
	return PL.list[name]
end

function PL.Get(name,i)
	return PL.list[name](i)
end