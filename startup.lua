---/ REDHACK OS (c) Reactified 2018 /--
--/ PLEASE DO NOT MODIFY THIS FILE /---

--/ SYSTEM VARIABLES /--
local isColor = term.isColor()
local w,h = term.getSize()
local modem = nil
_G.ui = {}
_G.net = {}

--/ SYSTEM INIT /--
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
print("SYS INIT")
sleep(0.1)
if fs.exists("/sys/config.sys") then
    write("LOADING CONFIG")
    f = fs.open("/sys/config.sys","r")
    cfg = f.readAll()
    f.close()
    sleep(0.1)
    write(".")
    cfg = textutils.unserialise(cfg)
    sleep(0.1)
    print(".")
else
    printError("MISSING 'config.sys' SYSTEM FILE")
    printError("RESTORE VALID CONFIG TO CONTINUE")
    return
end
local sysLabel = os.getComputerLabel() or cfg.sys.name or "Computer #"..tostring(os.getComputerID())
sleep(0.1)
print("TERMINAL INIT")
sleep(0.2)
print("PERIPHERAL INIT")
sleep(0.3)
for i,v in pairs(peripheral.getNames()) do
    write("- "..string.upper(peripheral.getType(v)).." ")
    if peripheral.getType(v) == "modem" then
        modem = peripheral.wrap(v)
        if modem.isWireless() then
            write("(WIRELESS)")
        else
            write("(WIRED)")
        end
    end
    print()
    sleep(0.2)
end
if not modem then
    printError("NO MODEM DETECTED")
else
    write("INIT NETWORKING")
    net.list = {}
    if fs.exists("/sys/network.txt") then
        f = fs.open("/sys/network.txt","r")
        line = true
        while line do
            line = f.readLine()
            if line then
                net.list[line] = "Offline"
            end
        end
        f.close()
    end
    net.ip = "192.168.0."..tostring(os.getComputerID())
    if cfg.net.customIP then
        if type(cfg.net.customIP == "string") then
            net.ip = cfg.net.customIP
        end
    end
    modem.open(cfg.net.channel or 2048)
    function _G.net.send(ip,msg)
        modem.transmit(cfg.net.channel or 2048,os.getComputerID(),{
            redhack = true,
            target = ip,
            author = net.ip,
            data = msg,
        })
    end
    function _G.net.receive(timeout,sender)
        local timerId
        if timeout then
            timerId = os.startTimer(timeout)
        end
        while true do
            e,s,c,r,m = os.pullEvent()
            if e == "timer" and s == timerId then
                return
            elseif e == "modem_message" then
                if c == cfg.net.channel or 2048 then
                    if m.redhack and m.target == net.ip then
                        if sender == nil or sender == m.author then
                            if timeout then
                                os.cancelTimer(timerId)
                            end
                            return m.author, m.data
                        end
                    end
                end
            end
        end
    end
    function _G.net.ping(ip)
        net.send(ip,{
            packet = "ping",
        })
        ip,data = net.receive(cfg.net.timeout or 1,ip)
        if not ip or not data then
            return false
        end
        if data.packet == "pong" then
            return data.label
        end
        return false
    end
    function netRoutine()
        while true do
            ip,data = net.receive()
            if data.packet == "ping" then
                net.send(ip,{
                    packet = "pong",
                    label = sysLabel,
                })
            else
                for i,v in pairs(modules) do
                    if v.on_net then
                        v.on_net(v.window,ip,data)
                    end
                end
            end
        end
    end
    function netCoroutine()
        while true do
            for i,v in pairs(net.list) do
                local status = net.ping(i)
                if status then
                    net.list[i] = status
                elseif i == net.ip then
                    net.list[i] = "Local"
                else
                    net.list[i] = "Offline"
                end
            end
            sleep(cfg.net.refresh or 4)
        end
    end
    sleep(0.2)
    write(".")
    sleep(0.2)
    print(".")
end
modules = {}
if fs.exists('/bin') then
    for i,v in pairs(fs.list("/bin/")) do
        if not fs.isDir('/bin/'..v) then
            shell.setAlias(string.gsub(v,".lua",""),"/bin/"..v)
            shell.setAlias(v,"/bin/"..v)
        end
    end
    if fs.exists('/bin/modules') then
        for i,v in pairs(fs.list("/bin/modules")) do
            local module = dofile("/bin/modules/"..v)
            if module.module then
                print(string.upper(module.module).." LOADED")
                if module.init then
                    module.init()
                end
                modules[#modules+1] = module
            end
        end
    else
        printError("MISSING MODULES FOLDER")
    end
else
    printError("MISSING BIN FOLDER")
end
sleep(0.1)
if fs.exists("/sys/x-server.sys") then
    write("LOADING X-SERVER")
    _G.ui = dofile("/sys/x-server.sys")
    sleep(0.1)
    write(".")
    sleep(0.1)
    print(".")
    sleep(0.1)
    if ui.size.width ~= w or ui.size.height ~= h then
        printError("INCOMPATIBLE X-SERVER")
        printError("SCREEN SIZE MISMATCH.")
        sleep(1)
    end
else
    printError("MISSING 'x-server.sys' SYSTEM FILE")
    printError("RESTORE VALID X-SERVER TO CONTINUE")
    return
end
sleep(0.1)
write("FINALIZING")
sleep(0.1)
write(".")
sleep(0.1)
write(".")
sleep(0.5)

--/ UI ROUTINE /--
ui.term = window.create(term.current(),ui.windows.terminal.xPos,ui.windows.terminal.yPos,ui.windows.terminal.width,ui.windows.terminal.height,true)
ui.netmap = window.create(term.current(),ui.windows.netmap.xPos,ui.windows.netmap.yPos,ui.windows.netmap.width,ui.windows.netmap.height,true)
ui.module = window.create(term.current(),ui.windows.modules.xPos,ui.windows.modules.yPos,ui.windows.modules.width,ui.windows.modules.height,true)
-- Module Allocation --
local modPos = 1
local modClick = {}
for i,v in pairs(modules) do
    modules[i].window = window.create(ui.module,1,modPos,ui.windows.modules.width,v.height,true)
    modPos = modPos + v.height
    modClick[i] = {
        x = ui.windows.modules.xPos,
        y = ui.windows.modules.yPos,
        w = ui.windows.modules.width,
        h = v.height,
    }
end
local termX,termY = ui.term.getSize()
local netmapX,netmapY = ui.netmap.getSize()
local moduleX,moduleY = ui.module.getSize()
local moduleScroll = 1
local netmapScroll = 1
local timer
local position
local termHistory = {}
local termDirectory = shell.dir()
local termPrefix = termDirectory.."> "
local termInput = ""
local termOffset = 0
function termWrite(str)
    ui.term.scroll(1)
    ui.term.setTextColor(ui.theme.txtMain)
    ui.term.setBackgroundColor(ui.theme.bgMain)
    ui.term.setCursorPos(1,termY-1)
    ui.term.clearLine()
    ui.term.setCursorPos(1,termY-1)
    ui.term.write(string.sub(str,1,termX))
    ui.term.setCursorPos(1,termY)
    ui.term.setTextColor(ui.theme.txtDark)
    ui.term.write(termPrefix)
end
function uiRoutine()
    -- Draw Window Outlines --
    term.setBackgroundColor(ui.theme.bgFill)
    term.clear()
    sleep(0.2)
    ui.term.setBackgroundColor(ui.theme.bgMain)
    ui.term.clear()
    sleep(0.1)
    ui.netmap.setBackgroundColor(ui.theme.bgMain)
    ui.netmap.clear()
    sleep(0.1)
    ui.module.setBackgroundColor(ui.theme.bgMain)
    ui.module.clear()
    sleep(0.1)
    -- Draw Window Headers --
    term.setCursorPos(ui.windows.terminal.xPos,ui.windows.terminal.yPos-1)
    term.setBackgroundColor(ui.theme.bgTab)
    write(string.rep(" ",ui.windows.terminal.width))
    sleep(0.1)
    term.setCursorPos(ui.windows.netmap.xPos,ui.windows.netmap.yPos-1)
    write(string.rep(" ",ui.windows.netmap.width))
    sleep(0.1)
    term.setCursorPos(ui.windows.modules.xPos,ui.windows.modules.yPos-1)
    write(string.rep(" ",ui.windows.modules.width))
    sleep(0.1)
    -- Fill Window Headers --
    term.setCursorPos(ui.windows.terminal.xPos+1,ui.windows.terminal.yPos-1)
    term.setTextColor(ui.theme.txtTab)
    write("Terminal")
    sleep(0.1)
    term.setCursorPos(ui.windows.netmap.xPos+1,ui.windows.netmap.yPos-1)
    write("Netmap")
    sleep(0.1)
    term.setCursorPos(ui.windows.modules.xPos+1,ui.windows.modules.yPos-1)
    write("Modules")
    -- Initiate UI Elements --
    for i,v in pairs(ui.splash) do
        ui.term.setCursorPos(termX/2-#v/2,(termY/2+#ui.splash/2)+1)
        if i < #ui.splash/2 then
            ui.term.setTextColor(ui.theme.txtAccent)
        else
            ui.term.setTextColor(ui.theme.txtMain)
        end
        ui.term.write(" "..v)
        sleep()
        ui.term.scroll(1)
    end
    ui.netmap.setCursorPos(netmapX,1)
    ui.netmap.setBackgroundColor(ui.theme.raisedBg)
    ui.netmap.setTextColor(ui.theme.raisedTxt)
    ui.netmap.write("^")
    for i=2,netmapY-1 do
        ui.netmap.setCursorPos(netmapX,i)
        ui.netmap.write(" ")
    end
    ui.netmap.setCursorPos(netmapX,netmapY)
    ui.netmap.write("v")
    
    timer = os.startTimer(0.1)
    local moduleCounter = 0
    while true do
        if not timer then
            timer = os.startTimer(cfg.net.refresh or 4)
        end
        moduleCounter = moduleCounter - 1
        if moduleCounter <= 0 then
            moduleCounter = 5
            for i,v in pairs(modules) do
                if v.draw then
                    local oldX,oldY = term.getCursorPos()
                    local oldBg,oldFg = term.getBackgroundColor(),term.getTextColor()
                    v.draw(v.window)
                    term.setCursorPos(oldX,oldY)
                    term.setBackgroundColor(oldBg)
                    term.setTextColor(oldFg)
                end
            end
        end
        e,c,x,y,z = os.pullEvent()
        if e == "mouse_click" then
            if x == ui.windows.netmap.xPos + netmapX - 1 and y == ui.windows.netmap.yPos + netmapY - 1 then
                netmapScroll = netmapScroll + 1
            elseif x == ui.windows.netmap.xPos + netmapX - 1 and y == ui.windows.netmap.yPos then
                netmapScroll = netmapScroll - 1
                if netmapScroll < 1 then
                    netmapScroll = 1
                end
            end
            x = x + 1 y = y + 1 -- Click offset
            for i,v in pairs(modClick) do
                if x >= v.x and x <= (v.x + v.w) and y >= v.y and y <= (v.y + v.h) and modules[i].on_click then
                    modules[i].on_click(modules[i].window,x-v.x,y-v.y,c)
                end
            end
            x = x - 1 y = y - 1 -- Revert offset
        elseif e == "timer" and c == timer then
            timer = false
        elseif e == "char" then
            termInput = termInput..c
        elseif e == "key" then
            if c == 14 then
                termInput = string.sub(termInput,1,#termInput-1)
            elseif c == 28 then
                ui.term.setCursorBlink(false)
                ui.term.scroll(2)
                local native = term.current()
                term.redirect(ui.term)
                term.setCursorPos(1,termY-1)
                local oldPull = os.pullEvent
                function _G.os.pullEvent(eventFilter)
                    ev1,ev2,ev3,ev4,ev5,ev6,ev7,ev8 = oldPull(eventFilter)
                    if ev1 == "mouse_click" or ev1 == "mouse_drag" then
                        return ev1,ev2,ev3-(ui.windows.terminal.xPos-1),ev4-(ui.windows.terminal.yPos-1)
                    else
                        return ev1,ev2,ev3,ev4,ev5,ev6,ev7,ev8
                    end
                end
                local oldBg = term.getBackgroundColor()
                shell.run(termInput)
                if oldBg ~= term.getBackgroundColor() then
                    term.setBackgroundColor(ui.theme.bgMain)
                    term.clear()
                end
                os.pullEvent = oldPull
                if string.sub(termInput,1,2) == "cd" then
                    term.setTextColor(ui.theme.txtAccent)
                    print("$/"..shell.dir())
                end
                term.redirect(native)
                termInput = ""
            end
        end
        if e ~= "modem_message" then
            for i,v in pairs(modules) do
                if v.on_modem then
                    v.on_modem(v.window,x,y,z)
                end
            end
            position = 2-netmapScroll
            ui.netmap.setBackgroundColor(ui.theme.bgMain)
            for i=1,netmapY do
                ui.netmap.setCursorPos(1,i)
                ui.netmap.write(string.rep(" ",netmapX-1))
            end
            for i,v in pairs(net.list) do
                ui.netmap.setCursorPos(1,position)
                position = position+1
                if v == "Offline" then
                    ui.netmap.setTextColor(ui.theme.txtDark)
                elseif v == "Local" then
                    ui.netmap.setTextColor(ui.theme.txtAccent)
                else
                    ui.netmap.setTextColor(ui.theme.txtMain)
                end
                ui.netmap.setBackgroundColor(ui.theme.bgMain)
                ui.netmap.write(string.sub(v,1,netmapX-1))
                ui.netmap.setCursorPos(1,position)
                position = position+1
                ui.netmap.setTextColor(ui.theme.txtDark)
                ui.netmap.write(string.sub(i,1,netmapX-1))
            end
            termOffset = 1+#termPrefix+#termInput-termX
            if termOffset <= 0 then
                termOffset = 0  
            end
            termDirectory = shell.dir()
            ui.term.setCursorPos(1,termY)
            ui.term.setBackgroundColor(ui.theme.bgMain)
            ui.term.clearLine()
            ui.term.setCursorPos(1-termOffset+#termPrefix,termY)
            ui.term.setTextColor(ui.theme.txtMain)
            ui.term.write(termInput)
            ui.term.setCursorPos(1,termY)
            ui.term.setTextColor(ui.theme.txtDark)
            ui.term.write(termPrefix)
            ui.term.setCursorPos(#termInput+#termPrefix+1-termOffset,termY)
            ui.term.setCursorBlink(true)
        end
    end
end
if not modem then
    netRoutine = function() end
    netCoroutine = function() end
    net.list = {}
end

--/ ERROR HANDLING /--
function mainRoutine()
    parallel.waitForAll(uiRoutine,netRoutine,netCoroutine)
end
while true do
    local ok,err = pcall(mainRoutine)
    if err == "Terminated" then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        term.setTextColor(ui.theme.txtAccent)
        print("Terminal Mode")
        for i,v in pairs(fs.list("/bin/")) do
            shell.clearAlias(v)
            shell.clearAlias(string.gsub(v,".lua",""))
        end
        break
    else
        if not ok then
            if not ui.theme then
                ui = {
                    ["theme"] = {
                        bgTab = colors.gray,
                        txtTab = colors.white,
                        txtDark = colors.lightGray,
                    }
                }
            end
            term.setBackgroundColor(ui.theme.bgTab)
            term.clear()
            term.setBackgroundColor(ui.theme.txtTab)
            term.setTextColor(ui.theme.bgTab)
            term.setCursorPos(3,3)
            write(" System Failure ")
            term.setBackgroundColor(ui.theme.bgTab)
            term.setTextColor(ui.theme.txtTab)
            term.setCursorPos(3,5)
            write("An error has occured,")
            term.setCursorPos(3,6)
            term.setTextColor(ui.theme.txtDark)
            write(err)
            local sel = 1
            while true do
                term.setCursorPos(3,8)
                if sel == 1 then
                    term.setBackgroundColor(ui.theme.txtTab)
                    term.setTextColor(ui.theme.bgTab)
                else
                    term.setBackgroundColor(ui.theme.bgTab)
                    term.setTextColor(ui.theme.txtTab)
                end
                write(" Reboot ")
                term.setCursorPos(3,9)
                if sel == 2 then
                    term.setBackgroundColor(ui.theme.txtTab)
                    term.setTextColor(ui.theme.bgTab)
                else
                    term.setBackgroundColor(ui.theme.bgTab)
                    term.setTextColor(ui.theme.txtTab)
                end
                write(" Reset ")
                term.setCursorPos(3,10)
                if sel == 3 then
                    term.setBackgroundColor(ui.theme.txtTab)
                    term.setTextColor(ui.theme.bgTab)
                else
                    term.setBackgroundColor(ui.theme.bgTab)
                    term.setTextColor(ui.theme.txtTab)
                end
                write(" Shell ")
                local e,k = os.pullEventRaw("key")
                if k == keys.up then
                    if sel > 1 then
                        sel = sel - 1
                    end
                elseif k == keys.down then
                    if sel < 3 then
                        sel = sel + 1
                    end
                elseif k == keys.enter then
                    if sel == 1 then
                        os.reboot()
                    elseif sel == 2 then
                        term.setBackgroundColor(colors.black)
                        term.clear()
                        sleep(0.25)
                        break
                    elseif sel == 3 then
                        term.setBackgroundColor(colors.black)
                        term.clear()
                        term.setCursorPos(1,1)
                        return
                    end
                end
            end
        end
    end
end