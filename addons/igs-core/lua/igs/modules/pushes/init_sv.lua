local log = kupol.log

local function handleUpdate(upd)
	if log.level == 1 or log.level == 2 then
		PrintTable(upd)
	end

	if not upd.ok then
		log.warning("GMD вернул ошибку: {}", upd.error)
		return
	end

	-- {cp = true/false, data = {}, ok = true, method = "payment"}
	hook.Run("IGS.IncomingMessage", upd.data, upd.method, upd)
end

hook.Add("IGS.Loaded", "polling", function()
	if IGS.POLLING then
		log.debug("Stopping previous poller")
		IGS.POLLING.stop()
	end

	log.info("Start polling")
	local uid = string.format("gmd_%s_%s", IGS.C.ProjectID, IGS.C.ProjectKey) -- antinil
	IGS.POLLING = kupol.new("https://poll.gmod.app/", uid, 30).start(handleUpdate)
end)
