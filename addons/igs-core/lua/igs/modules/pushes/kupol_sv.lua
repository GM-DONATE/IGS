-- 2021.01.18 4:16
-- Polling client for gm-donate.ru's polling server
-- Author: amd-nick.me/about

-- 2 copy of this file in some cases in different places with different include methods
if not lolib then require("lolib") end
-- require bib

kupol = kupol or {
	log = lolib.new()
}


local log = kupol.log
log.setFormat("{time} polling {message}")
log.setCvar("kupol_logging_level")


local function get_updates(base_url, uid, sleep, ts, fOnResponse)
	local url = base_url .. uid .. "/getUpdates?sleep=" .. (sleep or "") .. "&ts=" .. (ts or "")
	log.debug("http.Fetch({})", url)
	http.Fetch(url, function(json)
		local t = util.JSONToTable(json)
		if t and t.ok then
			fOnResponse(t)
		else
			fOnResponse(false, t and t.description or "response is not a json")
		end
	end, function()
		fOnResponse(false)
	end)
end


function kupol.new(sUrl, uid, iTimeout)
	local o = {uid = uid, url = sUrl, timeout = iTimeout, handler = false, running = false, stopping = false}

	o.poll = function(ts, fOnResponse)
		get_updates(o.url, o.uid, o.timeout, ts, fOnResponse)
	end

	local processResponse = function(requested_ts, res)
		local remote_ts = res.ts

		local a = remote_ts < requested_ts -- переезд, бэкап, обнуление временем
		local b = #res.updates == 0 and requested_ts > remote_ts -- переход с dev на prod, где ts больше

		if a or b then
			local log_pattern = a and "ts сервера ({}) меньше локального ({})"
				or "Похоже, что на сервере произошел баг или сервер изменился. ts {} prev {}"

			log.warning(log_pattern, remote_ts, requested_ts)
			bib.setNum("lp:ts:" .. o.uid, remote_ts)
			requested_ts = remote_ts
		end

		local ts_diff = remote_ts - requested_ts
		if #res.updates > 0 then
			log.info("From uid {} received {} new messages. Ts diff: {} items", o.uid, #res.updates, ts_diff)
		end

		for _,upd in ipairs(res.updates) do
			-- возможно проскальзывание https://img.qweqwe.ovh/1609615123638.png
			-- bib.setNum("lp:ts", remote_ts)
			local i = bib.getNum("lp:ts:" .. o.uid, 0) + 1
			bib.setNum("lp:ts:" .. o.uid, i) -- increment

			local ok, err = pcall(o.handler, upd)
			if err then
				log.error("Внутри хендлера произошла ошибка и работа чуть не прекратилась: {}", err)
			end
		end

		-- https://t.me/c/1353676159/43747
		if ts_diff > #res.updates then
			log.warning("Апдейты долго не запрашивались и {} шт утеряно", ts_diff - #res.updates)
			bib.setNum("lp:ts:" .. o.uid, remote_ts)
		end
	end

	o.consume_updates = function()
		local previous_ts = bib.getNum("lp:ts:" .. o.uid) or 0

		-- log.info("Polling uid: {}. Timeout {} sec. Requested Ts {}", uid, sleep, previous_ts)
		o.poll(previous_ts, function(res, err)
			if o.checkStopping() then return end

			if res then
				processResponse(previous_ts, res)
				o.consume_updates()

			else
				log.error("Error: {}. Waiting 5 sec and retrying", err)
				timer.Simple(5, o.consume_updates)
			end
		end)

		return o
	end

	o.start = function(fHandler)
		local stopping = o.stopping

		o.running  = true
		o.stopping = false
		o.handler  = fHandler

		if not stopping then
			o.consume_updates()
		end

		return o
	end

	o.stop = function(fOnStopped)
		fOnStopped = fOnStopped or function() end
		if not o.running then fOnStopped() return end
		o.stopping = fOnStopped
		return o
	end

	o.checkStopping = function()
		local onStopped = o.stopping
		if onStopped then
			o.stopping = false
			o.running  = false
			onStopped()
			return true
		end
		return false
	end

	return o
end
