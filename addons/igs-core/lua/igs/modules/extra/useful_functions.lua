-- Функции, которые могут быть полезны, но не используются в самом ядре

-- Списать деньги у SteamID и отправить другому.
-- Если SteamID в сети, то баланс обновится сразу.
-- Впервые использовалось в коде "аукциона".
function IGS.PayP2P(s64Who, s64Targ, iSum, sNote, fCallback)
	local pWho  = player.GetBySteamID64(s64Who)
	local pTarg = player.GetBySteamID64(s64Targ)

	local fCreateTxWho  = pWho  and  pWho.AddIGSFunds or IGS.Transaction
	local fCreateTxTarg = pTarg and pTarg.AddIGSFunds or IGS.Transaction

	fCreateTxWho(pWho or s64Who, -iSum, sNote, function()
		fCreateTxTarg(pTarg or s64Targ, iSum, sNote, fCallback) -- tx id in callback
	end)
end
