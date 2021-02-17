hook.Add("IGS.PlayerPurchasedItem", "IL.Integration", function(owner, ITEM, invDbID)
	if !IGS.C.Inv_Enabled then return end -- #todo сделать inv_log модулем и убрать проверку (mb nil if inv disabled)
	IGS.IL.Log(invDbID, ITEM:UID(), owner:SteamID64(), owner:SteamID64(), IGS.IL.NEW)
end)

-- ранее было на playeractivatedite. но там iPurchID
hook.Add("IGS.PlayerActivatedInventoryItem", "IL.Integration", function(owner, ITEM, invDbID)
	IGS.IL.Log(invDbID, ITEM:UID(), owner:SteamID64(), owner:SteamID64(), IGS.IL.ACT)
end)

hook.Add("IGS.PlayerDroppedGift",   "IL.Integration", function(owner, UID, invDbID)
	IGS.IL.Log(invDbID, UID, owner:SteamID64(), owner:SteamID64(), IGS.IL.DROP)
end)

hook.Add("IGS.PlayerPickedGift",    "IL.Integration", function(owner, UID, invDbID, picker)
	if !IsValid(owner) then return end -- самодельный гифт
	IGS.IL.Log(invDbID, UID, owner:SteamID64(), picker:SteamID64(), IGS.IL.PICK)
end)
