local _ = require("gettext")
local Dispatcher = require("dispatcher")

Dispatcher:registerAction("stats_calendar_view",
    {category="none", event="ShowCalendarView", title=_("Calendar"), general=true})
Dispatcher:registerAction("stats_calendar_day_view",
    {category="none", event="ShowCalendarDayView", title=_("Daily Stats"), general=true})
Dispatcher:registerAction("stats_sync",
    {category="none", event="SyncBookStats", title=_("Sync Stats"), general=true, separator=true})
	Dispatcher:registerAction("book_statistics",
    {category="none", event="ShowBookStats", title=_("Book Stats"), general=true, separator=true})

-- Add others if you need to! :)