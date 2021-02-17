require("pack")

local source, save_to = arg[1], arg[2]
source, save_to = source or "source/lua/igs", save_to or "superfile.txt"

local targ_dir = "minified"
pack.minifyAndSaveFolder(source, targ_dir)

local content = pack.compileSuperfile(targ_dir)
file.AdvWrite(save_to, content)
