require("file")
require("stringex")

local pat_mcomment_lua = "(%-%-%[(=*)%[.-%]%2%])"
local pat_mcomment_cpp = "(/%*.-%*/)"
local function stripMultiline(content)
	return content
		:gsub(pat_mcomment_lua, "")
		:gsub(pat_mcomment_cpp, "")
end

-- https://img.qweqwe.ovh/1556969630528.png
-- #TODO shitcoded heavy function
local pat_scomment_lua = "(%-%-[^\n]*)"
local pat_scomment_cpp = "[^:?](//[^\n]*)"
local function stripSingleline(content)
	local str = ""
	for _,line in ipairs(content:Split("\n")) do
		if string.sub(line, 1, 2) == '//' then line = '' end
		str = str .. line
			:gsub(pat_scomment_lua, "")
			:gsub(pat_scomment_cpp, "") .. "\n"
	end
	return str
end

local function removeComments(content)
	local a = stripMultiline(content)
	local b = stripSingleline(a)
	return b
end

local function removeUselessNewlines(content) -- compresses code
	local res = ""
	content:gsub("[^\n]+", function(line)
		if line:match("^%s*(.-)%s*$") ~= "" then
			res = res .. line:TrimRight() .. "\n" -- Trim даже слева табы уберет
		end
	end)
	return res
end

-- Use only after removing comments
local function multilineToSingle(content)
	return content:gsub("%c+", " "):TrimRight()
end

local function cleanupCode(content)
	local no_comments = removeComments(content)
	local no_extra_newlines = removeUselessNewlines(no_comments)
	return no_extra_newlines
end





pack = {}

function pack.compileSuperfile(from_dir)
	local files = file.Index(from_dir)
	local superfile = ""
	for _,file_path in ipairs(files) do
		local content = file.Read(file_path)
		local relative_path = string.sub(file_path, #from_dir + 2)
		superfile = superfile .. relative_path .. " " .. content .. "\n"
	end
	return superfile
end

function pack.minifyFile(file_path)
	local content = file.Read(file_path) -- original
	local clear   = cleanupCode(content) -- without comments, trailing spaces and unecessary newlines
	local single  = multilineToSingle(clear) -- 1 line file

	return single or clear
end

function pack.minifyAndSaveFolder(path, save_to)
	local files = file.Index(path)
	for _,file_path in ipairs(files) do
		local pref_pat  = string.PatternSafe(path)
		local file_dest = save_to .. "/" .. file_path:match(pref_pat .. "/(.+)$")--:gsub(".lua", ".txt")

		local minified = pack.minifyFile(file_path)
		-- print("Creating minified", file_dest, #minified)
		if not file.AdvWrite(file_dest, minified) then
			error("Cannot write data to " .. file_dest)
		end
	end
end
