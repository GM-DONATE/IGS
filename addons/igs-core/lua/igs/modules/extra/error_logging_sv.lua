hook.Add("IGS.OnApiError", "LogError", function(sMethod, error_uid, tParams)
	if error_uid == "http_error" then
		IGS.prints(Color(255, 0, 0), "", "CEPBEPA GMD BPEMEHHO HE9OCTynHbI. y}{e PEWAEM nPO6JIEMy")
	end

	local sparams = "\n"
	for k,v in pairs(tParams) do
		sparams = sparams .. ("\t%s = %s\n"):format(k,v)
	end

	local split = string.rep("-",50)
	local err_log =
		os.date("%Y-%m-%d %H:%M\n") ..
		split ..
		"\nMethod: " .. sMethod ..
		"\nError: "  .. error_uid ..
		"\nParams: " .. sparams ..
		split .. "\n\n\n"

	file.Append("igs_errors.txt",err_log)
	IGS.dprint(Color(250, 50, 50), err_log)
end)
