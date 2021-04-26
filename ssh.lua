--/ Redhack SSH Tool / Reactified /--
if not net then
    printError("Not running in Redhack environment.")
    return
end
if not net.ping then
    printError("System not online, reboot with modem.")
    return
end
local args = {...}
if not args[1] then
    printError("Usage: ssh <IP>")
    return
end
local label = net.ping(args[1])
if not label then
    printError("Invalid target.")
    return
end

local normal = term.getTextColor()
local fancy = ui.theme.txtAccent
local target = args[1]

term.setTextColor(fancy)
print(label)
term.setTextColor(normal)
write("Password: ")
local solve = read("*")

net.send(args[1],{packet = "solve",solve=solve})
local ip,data = net.receive(1,args[1])

if not ip then
    print("Access Denied")
    return
end

print("Error 53")
