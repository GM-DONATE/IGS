-- TRIGON.IM 12 dec 2021
-- Упрощенная версия texture либы от dash
-- 2024.12.27 dec 2024 добавлена проверка is_normal_image, чтобы всякие 429 и 403 от imgur не кешировали говно

matex = matex or {}

file.CreateDir("matex")

local PNG_START = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A}
local PNG_TRAIL = {0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82}
local is_png = function(raw)
	for i = 1, 8 do
		if PNG_START[i] ~= string.byte(raw, i) then return false end
		if PNG_TRAIL[i] ~= string.byte(raw, -(9 - i)) then return false end
	end
	return true
end


local JPG_START = {0xFF, 0xD8, 0xFF}
local JPG_TRAIL = {0xFF, 0xD9}
local is_jpg = function(raw)
	for i = 1, 3 do
		if JPG_START[i] ~= string.byte(raw, i) then return false end
		if i == 3 then break end
		if JPG_TRAIL[i] ~= string.byte(raw, -(3 - i)) then return false end
	end
	return true
end


-- https://mimesniff.spec.whatwg.org/#matching-an-image-type-pattern
-- https://www.garykessler.net/library/file_sigs.html
local function is_normal_image(raw)
	local png, jpg = is_png(raw), is_jpg(raw)
	return png or jpg
end

function matex.download(url, callback, useproxy)
	local id = util.CRC(url)

	local filepath = "matex/" .. id .. ".png"
	local matpath  = "../data/matex/" .. id .. ".png"

	if file.Exists(filepath, "DATA") then
		callback( Material(matpath, "noclamp smooth") )
		return
	end

	local baseurl = useproxy and "https://proxy.duckduckgo.com/iu/?u=" .. url or url
	http.Fetch(baseurl, function(body)
		if is_normal_image(body) then file.Write(filepath, body) end
		callback( Material(matpath, "noclamp smooth") )
	end, function()
		if useproxy then callback( Material("nil") ) return end
		matex.download(url, callback, true)
	end)
end

local cache = {}
function matex.now(url)
	if cache[url] then return cache[url].material end
	cache[url] = {material = nil}
	matex.download(url, function(material) cache[url].material = material end)
	return cache[url].material
end


--[[
-- example:
hook.Add("HUDPaint", "mater", function()
	local mater = matex.now("https://i.imgur.com/TZcJ1CK.png")
	if mater then
		surface.SetDrawColor(color_white)
		surface.SetMaterial(mater)
		surface.DrawTexturedRect(35, 35, 570, 460)
	end
end)
-- hook.Remove("HUDPaint", "mater")
--]]
