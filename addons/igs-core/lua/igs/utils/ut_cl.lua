-- Норм название сервера по его ИД
-- Если вернут "-", значит сервер скорее всего, отключен
function IGS.ServerName(iID)
	local serv_name = iID == 0 and IGS.GetPhrase("statusdisabled") or IGS.SERVERS(iID)
	      serv_name = serv_name or IGS.GetPhrase("statusglobal") -- IGS.SERVERS(iID) вернул nil = везде
	      -- serv_name = serv_name[1]:upper() .. serv_name:sub(2) -- апперкейсит первую букву

	return serv_name
end


function IGS.ProcessActivate(dbID, cb)
	IGS.Activate(dbID,function(ok, iPurchID, sMsg_)
		sMsg_ = sMsg_ or IGS.GetPhrase("itemactivatedthx")
		IGS.ShowNotify(sMsg_, ok and IGS.GetPhrase("itemactivated") or IGS.GetPhrase("acterror"))

		if cb then
			cb(ok, iPurchID, sMsg_)
		end
	end)
end
