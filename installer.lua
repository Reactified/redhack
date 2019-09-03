--/ Redhack Installer / Reactified /--
local repo = "http://raw.github.com/Reactified/redhack/master/"

--/ Function /--
local function getfile(gitfile,target)
    h = http.get(repo..gitfile)
    if h then
        local data = h.readAll()
        f = fs.open(target,"w")
        f.writeLine(data)
        f.close()
    else
        return false
    end
end

getfile("startup.lua","startup.lua")
