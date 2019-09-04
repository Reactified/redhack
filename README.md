# Redhack
Advanced computercraft terminal environment

# Install
Redhack can be installed on any computer with
``pastebin run Wecry95Y``

# Network
Redhack OS has its own networking protocol<br>
Running globally on any Redhack system is the ``net`` API:<br>
``net.ping()`` returns ``computer label OR false``<br>
``net.send(target,data)`` returns ``nil``<br>
``net.receive(timeout,filter)`` returns ``author, data``<br>
``net.ip`` value containing local IP<br>

# Modules
Redhack supports user modules that react to events and allow the user to interact<br>
Modules will be detected in the ``/bin/modules/`` folder, a basic module would be:<br>
```lua
return {
    module = "Module Template",
    draw = function(t)
        t.setBackgroundColor(colors.lightGray)
        t.clear()
        t.setCursorPos(2,2)
        t.setTextColor(colors.black)
        t.write("Module Test")
    end,
    height = 3,
}
```
Modules can use the following events to react to input<br>
``on_click`` ``window, x position, y position, click type``<br>
``on_modem`` ``window, channel, reply, message``<br>
``on_net`` ``window, from IP, data``<br>
