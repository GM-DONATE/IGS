require("file")
require("stringex")

local function unpackSuperfile(file_path, extract_to)
	local content = file.Read(file_path, "DATA")
	local lines = string.Split(content, "\n")

	for _,line in ipairs(lines) do
		local path,code = string.match(line, "^(.-) (.*)$")
		if path then -- !last_line
			file.AdvWrite(extract_to .. "/" .. path, code)
		end
	end
end
-- unpackSuperfile("igs/superfile" .. IGS.Version .. ".txt", "igs/unpack_1")
