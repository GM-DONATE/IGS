
local col_lime  = Color(100,210,40)
local col_light = Color(228,228,228)
local col_red   = Color(250,30,90)

function IGS.NotifyAll(...)
	chat.AddTextSV(
		col_lime, "[IGS]",
		col_red,  " > ",
		col_light,...
	)
end


function IGS.Notify(pl, ...)
	pl:ChatPrintColor(
		col_lime, "[IGS]",
		col_red,  " > ",
		col_light,...
	)
end


-- todo реальный логгинг
function IGS.LogError(err)
	error(err)
end


--[[---------------------------
	API
-----------------------------]]
-- Проще https://qweqwe.ovh/9vAdB
local limit_per_query = 255
local function getTxsNoLimit(cb, s64, am_, _tmp_)
	_tmp_ = _tmp_ or {}
	am_   =   am_ or math.huge
	local left = am_ - #_tmp_
	-- print("need, done, left", am_, #_tmp_, left)
	IGS.GetTransactions(function(data)
		for _,tr in ipairs(data) do
			local i = table.insert(_tmp_,tr)
			if am_ and i == am_ then cb(_tmp_) return end -- собрали нужное кол-во
		end

		if #data < limit_per_query then cb(_tmp_) -- Последняя страница
		else getTxsNoLimit(cb, s64, am_, _tmp_)
		end
	end, s64, true, math.min(limit_per_query, left), #_tmp_)
end

IGS.GetPlayerTransactionsBypassingLimit = getTxsNoLimit

-- getTxsNoLimit(function(all)
-- 	for i,tx in ipairs(all) do
-- 		print(i, DateTime(tx.Time), tx.Note)
-- 	end
-- 	print("#all", #all)
-- end, AMD():SteamID(), 20)