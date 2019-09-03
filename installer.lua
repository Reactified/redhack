--/ Redhack Installer / Reactified /--
local repo = "http://raw.github.com/Reactified/redhack/master/"
local files = {
    {"startup.lua","startup.lua"},
    {"config.sys","sys/config.sys"},
}

--/ Function /--
local w,h = term.getSize()
local accent = colors.blue
if term.isColor() then
    accent = colors.black
end
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
local function drawTab(tab)
    term.setBackgroundColor(colors.gray)
    term.clear()
    term.setCursorPos(1,1)
    term.setBackgroundColor(accent)
    term.clearLine()
    term.setCursorPos(2,1)
    term.setTextColor(colors.white)
    term.write("Redhack Installer")
    term.setCursorPos(w-#tab,1)
    term.write(tab)
end

--/ Routine /--
drawTab("fucktm")
