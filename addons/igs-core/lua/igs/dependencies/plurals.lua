local plural_type = function(i)
	return i % 10 == 1 and i % 100 ~= 11 and 1
		or (i % 10 >= 2 and i % 10 <= 4 and (i % 100 < 10 or i % 100 >= 20) and 2
			or 3
		)
end

function util.formatPlural(plurals, num)
	local type = plural_type(num)
	local suffix = plurals[type]
	return num .. " " .. suffix, suffix
end

function PLUR(plurals)
	return function(num)
		return util.formatPlural(plurals, num)
	end
end

-- local P = PLUR({"пост", "поста", "постов"})
-- PRINT(P(1), P(2), P(5))
