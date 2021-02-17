if dash then return end
-- Thanks to SuperiorServers.co

local Start = net.Start
local Send  = SERVER and net.Send or net.SendToServer
function net.Ping(msg, recipients)
	Start(msg)
	Send(recipients)
end


if CLIENT then
	local surface_SetFont 		= surface.SetFont
	local surface_GetTextSize 	= surface.GetTextSize
	local string_Explode 		= string.Explode
	local ipairs 				= ipairs

	function string.Wrap(font, text, width)
		surface_SetFont(font)

		local sw = surface_GetTextSize(' ')
		local ret = {}

		local w = 0
		local s = ''

		local t = string_Explode('\n', text)
		for i = 1, #t do
			local t2 = string_Explode(' ', t[i], false)
			for i2 = 1, #t2 do
				local neww = surface_GetTextSize(t2[i2])

				if (w + neww >= width) then
					ret[#ret + 1] = s
					w = neww + sw
					s = t2[i2] .. ' '
				else
					s = s .. t2[i2] .. ' '
					w = w + neww + sw
				end
			end
			ret[#ret + 1] = s
			w = 0
			s = ''
		end

		if (s ~= '') then
			ret[#ret + 1] = s
		end

		return ret
	end

	local formathex = '%%%02X'
	function string:URLEncode()
		return string.gsub(string.gsub(string.gsub(self, '\n', '\r\n'), '([^%w ])', function(c)
			return string.format(formathex, string.byte(c))
		end), ' ', '+')
	end

	local surface_DrawRect     = surface.DrawRect
	local surface_SetDrawColor = surface.SetDrawColor
	function draw.Box(x, y, w, h, col)
		surface_SetDrawColor(col)
		surface_DrawRect(x, y, w, h)
	end
end
