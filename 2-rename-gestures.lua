local _ = require("gettext")
local Dispatcher = require("dispatcher")
local Device = require("device")

local original_registerAction = Dispatcher.registerAction

Dispatcher.registerAction = function(self, name, value)
    local settingsList
    local i = 1
    while true do
        local n, v = debug.getupvalue(original_registerAction, i)
        if not n then break end
        if n == "settingsList" then
            settingsList = v
            break
        end
        i = i + 1
    end
    
    if settingsList and settingsList[name] then
        for key, val in pairs(value) do
            settingsList[name][key] = val
        end
        return true
    end
    
    return original_registerAction(self, name, value)
end

-- Add in whatever gesture you want from dispatcher.lua and give it a new title!
Dispatcher:registerAction("toggle_frontlight",
    {category="none", event="ToggleFrontlight", title=_("Toggle Light"), screen=true, condition=Device:hasFrontlight()})
Dispatcher:registerAction("wifi_on",
    {category="none", event="InfoWifiOn", title=_("Wifi On"), screen=true, condition=Device:hasWifiToggle()})
Dispatcher:registerAction("wifi_off",
    {category="none", event="InfoWifiOff", title=_("Wifi Off"), screen=true, condition=Device:hasWifiToggle()})
Dispatcher:registerAction("start_usbms",
    {category="none", event="RequestUSBMS", title=_("Connect to PC"), screen=true, condition=Device:canToggleMassStorage()})
-- Make sure you're putting in the right information!

Dispatcher.registerAction = original_registerAction