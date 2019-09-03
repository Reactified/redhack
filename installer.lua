--/ Redhack Installer / Reactified /--
local repo = "http://raw.github.com/Reactified/redhack/master/"
local themes = {
    Blue = "x-server-blue.sys",
    Red = "x-server-red.sys",
}
local files = {
    {"startup.lua","startup.lua"},
    {"config.sys","sys/config.sys"},
}

--/ Function /--
local w,h = term.getSize()
local accent = colors.blue
if not term.isColor() then
    accent = colors.black
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
    term.setTextColor(colors.lightGray)
    term.write(tab)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
end
function prompt(name,options,question)
    local cursor = 1
    while true do
        drawTab(name)
        term.setCursorPos(2,3)
        write(question)
        for i,v in pairs(options) do
            term.setCursorPos(2,5+i)
            if cursor == i then
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.white)
            else
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.lightGray)
            end
            write(" "..v.." ")   
        end
        local e,k = os.pullEvent("key")
        if k == keys.down then
            if cursor < #options then
                cursor = cursor + 1
            end
        elseif k == keys.enter then
            return cursor
        elseif k == keys.up then
            if cursor > 1 then
                cursor = cursor - 1
            end
        end
    end
end
local function getfile(gitfile,target)
    h = http.get(repo..gitfile)
    if h then
        local data = h.readAll()
        f = fs.open(target,"w")
        f.writeLine(data)
        f.close()
        h.close()
    else
        return false
    end
end

--/ Routine /--
local h = http.get(repo.."version.dat")
local version = -1
if h then
    version = tonumber(h.readAll())
    h.close()
end
drawTab("Init")
term.setCursorPos(2,3)
write("Welcome to Redhack")
term.setCursorPos(2,4)
term.setTextColor(colors.lightGray)
if version >= 1 then
    write("Release v"..tostring(version))
else
    write("Alpha v0"..tostring(version))
end
if fs.exists("/startup") or fs.exists("/startup.lua") then
    term.setCursorPos(2,9)
    if term.isColor() then term.setTextColor(colors.red) end
    write("! Current startup will be lost")
end
term.setCursorPos(2,6)
term.setTextColor(colors.white)
write("Would you like to install")
term.setCursorPos(2,7)
write("Redhack OS? y/n")
local evt,key = os.pullEvent("key")
if key ~= keys.y then
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.lightGray)
    write("Installation cancelled.")
    return
end
local options = {}
for i,v in pairs(themes) do
    options[#options+1] = i
end
local theme = options[prompt("Theme",options,"Select a theme")]
term.clear()
term.setCursorPos(2,2)
write(theme)
files[#files+1] = {themes[theme],"sys/x-server.sys"}
drawTab("Install")
