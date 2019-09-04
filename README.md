# Redhack
Please note that all "hacking" in this project takes place<br>
inside of isolated in-game computers that do not effect actual systems<br>
<br>
Redhack is an advanced computercraft terminal environment with<br>
unique hacknet style networks.<br>

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

# Hacking
By default, a system will be vulnerable with Level 2 encryption security<br>
Security can be increased, or the system can be put into ghost mode in ``config.sys``<br>
**Ghost Mode** protects a system from being hacked, but other systems will block attempts from you.<br>
**Security Level** the number of characters required to solve the security hash and gain control<br>
**Static Pass** allows you to set a static hash and password that will allow reliable remote access<br>
<br>
At the moment, you can ``hack <ip>`` to open a simple CLI hacking interface.  This is pretty basic and will likely<br>
be replaced with a graphical interface along with better control tools once connected, such as a file explorer<br>
and file editor.

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
