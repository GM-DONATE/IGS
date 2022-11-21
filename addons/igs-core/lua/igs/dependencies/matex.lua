-- TRIGON.IM 12 dec 2021
-- Упрощенная версия texture либы от dash

matex = matex or {}

file.CreateDir("matex")

function matex.url(url, useproxy)
	local id = util.CRC(url)

	local filepath = "matex/" .. id .. ".png"
	local matpath  = "../data/matex/" .. id .. ".png"

	local def = {material = nil}

	if file.Exists(filepath, "DATA") then
		def.material = Material(matpath, "noclamp smooth")
		return def
	end

	local baseurl = useproxy and "https://proxy.duckduckgo.com/iu/?u=" .. url or url

	http.Fetch(baseurl, function(body)
		file.Write(filepath, body)
		def.material = Material(matpath, "noclamp smooth")
		return def.material
	end, function(error)
		if useproxy then def.material = Material("nil") return def end
		return matex.url(url, true)
	end)

	return def
end

-- function matex.imgur(id)
-- 	return matex.url("https://i.imgur.com/" .. id .. ".png")
-- end

-- local furl = fl.memoize(matex.url)
-- function matex.url_async(url)
-- 	return furl(url).material
-- end

-- function matex.imgur_async(id)
-- 	return furl("https://i.imgur.com/" .. id .. ".png").material
-- end



/* example
local mater = matex.imgur("TZcJ1CK")

hook.Add("HUDPaint", "mater", function()
	if not mater.material then return end

	surface.SetDrawColor(color_white)
	surface.SetMaterial(mater.material)
	surface.DrawTexturedRect(35, 35, 570, 460)
end)
-- hook.Remove("HUDPaint", "mater")
