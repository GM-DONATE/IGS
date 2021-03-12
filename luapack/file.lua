require("stringex") -- Split
require("tableex")  -- Add

file = {}

function file.Find(path, pattern)
	local f = io.popen(string.format("ls -dp1 %s/%s", path, pattern or "*"), "r")
	local data = f:read("*all")
	f:close()
	local files, dirs = {}, {}
	for _, line in pairs(string.Split(data, "\n")) do
		local name = string.sub(line, #path + 2, #line)
		if #name > 0 then
			local is_dir = string.byte(name, #name) == 0x2f
			table.insert(is_dir and dirs or files, is_dir and string.sub(name, 1, #name - 1) or name)
		end
	end
	return files, dirs
end

-- function file.IsDir(path)  return os.execute(string.format("bash -c '[ -d %q ]'", path)) == 0 end
-- function file.IsFile(path) return os.execute(string.format("bash -c '[ -f %q ]'", path)) == 0 end

-- function file.Exists(path)
-- 	return file.IsDir(path) or file.IsFile(path)
-- end

function file.Read(path)
	local f = io.open(path, "r")
	if not f then return nil end
	local data = f:read("*all")
	f:close()
	return data
end

function file.Write(path, data)
	local f = io.open(path, "wb")
	if not f then return false end
	f:write(data)
	f:close()
	return true
end

function file.CreateDir(path)
	local f = io.popen(string.format("mkdir -p %q 2>&1 echo $?", path), "r")
	local data = string.Split(f:read("*all"), "\n")
	local msg, code = data[1], tonumber(data[2])
	f:close()
	-- os.execute("rm -r 0/ echo/")
	return code == nil, code ~= nil and msg or nil
end




function file.Index(path)
	local list = {}
	local files,dirs = file.Find(path)
	for _,f in ipairs(files) do
		list[#list + 1] = path .. "/" .. f
	end
	for _,d in ipairs(dirs) do
		local res = file.Index(path .. "/" .. d)
		table.Add(list, res)
	end
	return list
end

function file.AdvWrite(sPath, sData)
	-- bla2/bla3/kek.txt > bla2/bla3
	file.CreateDir(sPath:match("(.+)/"))
	return file.Write(sPath, sData)
end


