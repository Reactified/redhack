# redhack
Advanced computercraft terminal environment

# install
Redhack can be installed on any computer with
``pastebin run Wecry95Y``

# modules
Redhack supports user modules that react to events and allow the user to interact
Modules will be detected in the ``/bin/modules/`` folder, a basic module would be:
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
``on_click | window, x position, y position, click type``<br>
``on_modem | window, channel, reply, message``<br>
``on_net   | window, from IP, data``<br>
