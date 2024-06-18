--[[-------------------------------------------------------------------------
	Отображение рекордного доната
---------------------------------------------------------------------------]]
-- Если включить, то в чате начнут появляться сообщения, которые написаны ниже
IGS.C.TopDon_Echo = true

-- Частота сброса последнего рекорда доната
-- %H - раз в час, %d - раз в день, %u - раз в неделю. %m - раз в месяц
IGS.C.TopDon_Periodicity = "%u" -- %m


--#### ПЕРЕЕХАЛ В LANGUAGE ####

-- IGS.C.TopDon_TextRecord   = "$nick побил рекорд доната в этом месяце, пополнив счет на $sum руб.\nПредыдущий рекорд установил $nick_prev, пополнив счет на $sum_prev руб"
-- IGS.C.TopDon_TextFirstDon = "$nick стал первым, кто задонатил в этом месяце. $nick умничка. Будь как $nick - /donate" -- доступен шаблон $sum

--#### ПЕРЕЕХАЛ В LANGUAGE ####



--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]
local SUM,TIME,SID,NAME =
	"igs:hugecharge_sum",
	"igs:hugecharge_time",
	"igs:hugecharge_sid",
	"igs:hugecharge_name"


local function resetHugeCharge()
	bib.delete(SUM)
	bib.delete(TIME)
	bib.delete(SID)
	bib.delete(NAME)

	-- cprint("Сбросили")
end

local function setHugeCharge(sum, sid, nick)
	bib.set(SUM,  sum)
	bib.set(TIME, os.time()) --+ 60*60*24*2) -- +2 дня
	bib.set(SID,  sid)
	bib.set(NAME, nick)
end

local function getHugeCharge(bSumOnly)
	if bSumOnly then -- микрооптимизация
		return tonumber(bib.get(SUM))
	end

	return {
		sum  = tonumber(bib.get(SUM)),
		time = tonumber(bib.get(TIME)),
		sid  = bib.get(SID),
		nick = bib.get(NAME)
	}
end

-- print(getHugeCharge())
-- setHugeCharge(1,AMD():SteamID64(),"_AMD_")




-- Если есть запись о предыдущем рекорде и сейчас час/день/неделя/месяц меньше, чем было в предыдущей записи
-- значит день/неделя/месяц/год начались сначала и пора удалять эту запись, чтобы начать учет сначала
local prev_rec = getHugeCharge()
-- cprint(os.date(IGS.C.TopDon_Periodicity))
-- cprint(os.date(IGS.C.TopDon_Periodicity,prev_rec.time))

if prev_rec and os.date(IGS.C.TopDon_Periodicity) < os.date(IGS.C.TopDon_Periodicity,prev_rec.time) then
	resetHugeCharge()
end



local function charge(pl, sum)
	sum = tonumber(sum)

	if sum > (getHugeCharge(true) or 0) then
		local pr = getHugeCharge() -- Previous Record

		local s = pr.nick and IGS.GetPhrase("TopDon_TextRecord") or IGS.GetPhrase("TopDon_TextFirstDon")

		-- Не первый донат
		if pr.nick then
			local s32 = util.SteamIDFrom64(pr.sid)

			s = s
			:gsub("$nick_prev", ("%s(%s)"):format(pr.nick,s32) )
			:gsub("$sum_prev",pr.sum)
		end

		s = s
		:gsub("$nick",pl:Nick())
		:gsub("$sum",sum)

		IGS.NotifyAll(s)

		setHugeCharge(sum,pl:SteamID64(),pl:Nick())
	end
end

-- charge(AMD(),6)


hook.Add("IGS.PlayerDonate","TopDonateEcho",function(pl, sum)
	if IGS.C.TopDon_Echo then
		charge(pl, sum)
	end
end)
