local actions = setmetatable({},{__index = function() return IGS.GetPhrase("error") end})
actions[1] = IGS.GetPhrase("buy")
actions[2] = IGS.GetPhrase("activation")
actions[3] = IGS.GetPhrase("drop")
actions[4] = IGS.GetPhrase("pick")

local function beautyS64(s64)
	local pl = player.GetBySteamID64(s64)
	return pl and pl:Nick() or util.SteamIDFrom64(s64):sub(#"STEAM_0")
end

local function isSteamID64(s)
	return #s == 17 and s:StartWith("7656")
end

local function anyTo64(sid)
	local res = isSteamID64(sid) and sid or util.SteamIDTo64(sid)
	return res ~= "0" and res
end

local function getNameBySid(cb, s64)
	IGS.IL.NameRequest(function(name_)
		cb(name_)
	end, s64)
end

function IGS.WIN.InvLog()
	return uigs.Create("igs_frame", function(bg)
		bg:SetTitle(IGS.GetPhrase("actionswithinv"))
		bg:SetSize(800, 600)
		bg:Center()
		bg:MakePopup()

		function bg:SearchSteamID(s64)
			bg.table:Clear()
			bg:Search(1, s64)
		end

		function bg:SearchGiftUID(uid)
			bg.table:Clear()
			bg:Search(1, nil, uid)
		end

		function bg:ResetSearch()
			bg.table:Clear()
			bg:Search()
		end

		function bg:AddLine(sOwner, sInfli, sItem, sAction, sDate, r)
			local line = bg.table:AddLine(sOwner, sInfli, sItem, r.gift_id, sAction, sDate)
			line:SetTooltip(Format(IGS.GetPhrase("r.action_id"), r.action_id))

			local btn_giftid = line.columns[4]
			btn_giftid.text_color = IGS_IL_ROW_SOLID_COLOR or HSVToColor(((r.gift_id * 10) * 5) % 360, 1, 1)

			for _,v in ipairs(line.columns) do
				v:SetCursor("hand")
			end

			for i,s64 in ipairs({r.owner, r.inflictor}) do
				if not player.GetBySteamID64(s64) then -- игрок не в сети, ник не получен
					getNameBySid(function(name_)
						if not name_ then return end

						local btn_owner = line.columns[i] -- 1, 2 колонка
						btn_owner:SetText(name_)
					end, s64)
				end
			end

			line.DoClick = function()
				local m = DermaMenu(line)
				m:AddOption(IGS.GetPhrase("plinvlogcopysidowner"),function() SetClipboardText(r.owner) end)
				m:AddOption(IGS.GetPhrase("plinvlogcopysidinfl"),function() SetClipboardText(r.inflictor) end)
				m:AddOption(IGS.GetPhrase("plinvlogactions"),function() bg:SearchSteamID(r.owner) end)
				m:AddOption(IGS.GetPhrase("plinvlogactionswith") .. sItem,function() bg:SearchGiftUID(r.gift_uid) end)
				if sAction == IGS.GetPhrase("plinvactivation") then -- а таких записях написан ID покупки, а не гифта (аве шиткодинг!)
					m:AddOption(IGS.GetPhrase("plinvdisable"), function()
						IGS.DeactivateItem(r.gift_id)
					end)
				end
				m:Open()
			end
		end

		function bg:Search(page, sid_, uid_) -- sid ИЛИ uid (Так сделан SELECT запрос)
			page = page or 1
			self.prev_page = page
			self.prev_sid  = sid_
			self.prev_uid  = uid_

			IGS.IL.GetLog(function(tLog)
				if not IsValid(bg) then return end -- Долго данные получались

				for _,r in ipairs(tLog) do
					local ITEM = IGS.GetItemByUID(r.gift_uid)

					local sDate   = IGS.TimestampToDate(r.date, true)
					local sAction = actions[r.action]
					local sItem   = ITEM.isnull and (r.gift_uid .. " (NULL)") or ITEM:Name()

					local sOwner = beautyS64(r.owner)
					local sInfli = beautyS64(r.inflictor)

					bg:AddLine(sOwner, sInfli, sItem, sAction, sDate, r)
				end

				bg.table:PerformLayout()
				bg.load:UpdateLoaded(#bg.table.lines, tLog[0])
			end, page, sid_, uid_)
		end

		bg.table = uigs.Create("igs_table", function(pnl)
			pnl:Dock(FILL)
			pnl:DockMargin(5,5,5,5)
			-- pnl:SetSize(790, 565)

			pnl:SetTitle(IGS.GetPhrase("doninvlogactions"))

			pnl:AddColumn(IGS.GetPhrase("doninvlogowner"),120)
			pnl:AddColumn(IGS.GetPhrase("doninvloginfl"),120)
			pnl:AddColumn(IGS.GetPhrase("doninvlogitem"))
			pnl:AddColumn(IGS.GetPhrase("doninvloggiftid"), 65)
			pnl:AddColumn(IGS.GetPhrase("doninvlogaction"),110)
			pnl:AddColumn(IGS.GetPhrase("doninvlogdate"),130)
		end, bg)

		local bottom = uigs.Create("Panel", function(self)
			self:SetHeight(30)
			self:Dock(BOTTOM)
			self:DockMargin(5,0,5,5)
		end, bg)

		local entry = uigs.Create("DTextEntry", function(self)
			self:Dock(LEFT)
			self:SetWide(200)
			self:SetValue(IGS.GetPhrase("doninvsearch"))
			self.OnEnter = function()
				local val = self:GetValue():Trim()
				local s64 = anyTo64(val)

				if val == "" then
					bg:ResetSearch()
				elseif s64 then
					bg:SearchSteamID(s64)
				else
					bg:SearchGiftUID(val)
				end
			end
		end, bottom)

		uigs.Create("igs_button", function(self)
			self:Dock(LEFT)
			self:SetWide(150)
			self:DockMargin(5,0,0,0)
			self:SetText(IGS.GetPhrase("doninvfind"))
			self.DoClick = entry.OnEnter
		end, bottom)

		bg.load = uigs.Create("igs_button", function(self)
			self:Dock(RIGHT)
			self:SetWide(200)
			self.DoClick = function()
				-- bg.table:Clear()
				bg:Search(bg.prev_page + 1, bg.prev_sid, bg.prev_uid)
			end
			self.UpdateLoaded = function(_, iLoaded, iTotal)
				if iLoaded == iTotal then
					self:SetText(Format(IGS.GetPhrase("doninvallloaded"), iTotal))
					self:SetActive(false)
				else
					self:SetText(Format(IGS.GetPhrase("doninvloadmore"), iLoaded, iTotal))
					self:SetActive(true)
				end
			end
		end, bottom)

		bg:Search()
		bg.load:UpdateLoaded(0, 0)
	end)
end

concommand.Add("igs_invlog",IGS.WIN.InvLog)

-- for i = 1,1 do
-- 	local fr = IGS.WIN.InvLog()
-- 	timer.Simple(10,function()
-- 		if IsValid(fr) then
-- 			fr:Remove()
-- 		end
-- 	end)
-- end
