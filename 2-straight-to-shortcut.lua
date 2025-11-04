local _ = require("gettext")
local Dispatcher = require("dispatcher")

-- Basically just replace "Screenshots" with your folder shortcut name
Dispatcher:registerAction("goto_Screenshots_shortcut",
    {category="none", event="GotoNamedShortcut", arg="Screenshots", title=_("Screenshots"), filemanager=true})
-- Add as much as you want
	
	