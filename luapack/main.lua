local source, save_to = arg[1], arg[2]
source, save_to = source or "source/lua/igs", save_to or "superfile.json"


local superfile = {}

local index = file.Index(source)
for _,path in ipairs(index) do
	local pref_pat  = string.PatternSafe(source)
	local path_sub = path:match(pref_pat .. "/(.+)$")
	superfile[path_sub] = file.Read(path)
end

local json = require("json")
local superfile_json = json.stringify(superfile)
file.AdvWrite(save_to, superfile_json)
