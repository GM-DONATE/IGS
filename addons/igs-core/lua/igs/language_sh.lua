local files = file.Find("igs/language/*", "LUA")

for k, v in pairs(files) do
    if (SERVER) then
        include("igs/language/" .. v)
        AddCSLuaFile("igs/language/" .. v)
        MsgC(Color(0, 0, 255), "[IGS] " .. v .. " language found\n")
    else
        include("igs/language/" .. v)
    end
end

function IGS.GetPhrase(name, ...)
    return IGS.LANG[IGS.C.LANG][name] or name
end