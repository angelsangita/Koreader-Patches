local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Device = require("device")
local Dispatcher = require("dispatcher")
local Event = require("ui/event")
local Font = require("ui/font")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local ImageWidget = require("ui/widget/imagewidget")
local InputContainer = require("ui/widget/container/inputcontainer")
local LineWidget = require("ui/widget/linewidget")
local ProgressWidget = require("ui/widget/progresswidget")
local ReaderUI = require("apps/reader/readerui")
local ReaderView = require("apps/reader/modules/readerview")
local RenderImage = require("ui/renderimage")
local Size = require("ui/size")
local TextWidget = require("ui/widget/textwidget")
local TextBoxWidget = require("ui/widget/textboxwidget")
local UIManager = require("ui/uimanager")
local util = require("util")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local datetime = require("datetime")
local _ = require("gettext")
local Screen = Device.screen	
local T = require("ffi/util").template

local quicklookbox = InputContainer:extend{  
    modal = true,  
    name = "quick_look_box",  
}  

function quicklookbox:init()

    -- book info
    local book_title = ""
    local book_author = ""
    if self.ui.doc_props then
        book_title = self.ui.doc_props.display_title or ""
        book_author = self.ui.doc_props.authors or ""
        if book_author:find("\n") then
            book_author =  T(_("%1 et al."), util.splitToArray(book_author, "\n")[1] .. ",")
        end
    end
    
    -- page count and book percentage
    
    local book_pageno = self.state.page or 1
    local book_pages_total = self.ui.doc_settings.data.doc_pages or 1
    local book_pages_left  = book_pages_total - book_pageno
    local book_percentage = (book_pageno / book_pages_total) * 100
    
    -- chapter Info
    
    local chapter_title = ""
    local chapter_pages_total = 0
    local chapter_pages_left = 0
    local chapter_chapter_pages_done = 0
    if self.ui.toc then
        chapter_title = self.ui.toc:getTocTitleByPage(book_pageno) or ""
        chapter_pages_total = self.ui.toc:getChapterPageCount(book_pageno) or book_pages_total
        chapter_pages_left = self.ui.toc:getChapterPagesLeft(book_pageno) or self.ui.document:getTotalPagesLeft(book_pageno)
        chapter_pages_done = self.ui.toc:getChapterPagesDone(book_pageno) or 0
    end
    chapter_pages_done = chapter_pages_done + 1
    
    -- clock:
    
    local current_time = datetime.secondsToHour(os.time(), G_reader_settings:isTrue("twelve_hour_clock")) or ""
    
    -- battery:
    
    local battery = ""
    if Device:hasBattery() then
        local power_dev = Device:getPowerDevice()
        local batt_lvl = power_dev:getCapacity() or 0
        local is_charging = power_dev:isCharging() or false
        local batt_prefix = power_dev:getBatterySymbol(power_dev:isCharged(), is_charging, batt_lvl) or ""
        battery = batt_prefix .. batt_lvl .. "%"
    end
        
        
    --==================== widget design ====================--		
    
        
    local widget_width = Screen:getWidth() / 2.3  
    local db_font_color = Blitbuffer.COLOR_BLACK
    local db_font_color_lighter = Blitbuffer.COLOR_GRAY_3
    local db_font_color_lightest = Blitbuffer.COLOR_GRAY_9
    local db_font_face = "NotoSans-Regular.ttf"
    local db_font_face_italics = "NotoSans-Italic.ttf"
    local db_font_size_big = 18  
    local db_font_size_mid = 15 
    local db_font_size_small = 12
    local db_padding = 12
    local db_padding_internal = 5 
    
    function databox(db_typename, db_itemname, db_pagedone, db_pagetotal, show_title)
    
        local boxtitle = nil
        if show_title then
            boxtitle = TextWidget:new{
              text = db_typename,
              face = Font:getFace("cfont", db_font_size_big),
              bold = true,
              fgcolor = db_font_color,
              padding = 0,
            }
        end
        
        local book_or_chapter_name = TextBoxWidget:new{
          face = Font:getFace(db_font_face, db_font_size_mid),
          text = db_itemname,
          width = widget_width,
          fgcolor = db_font_color,
        }
        
        local progressbarwidth = widget_width
        local progress_bar = ProgressWidget:new{
          width = progressbarwidth,
          height = Screen:scaleBySize(3), 
          percentage = db_pagedone/db_pagetotal,
          margin_v = 0,
          margin_h = 0,
          radius = 20,
          bordersize = 0,
          bgcolor = db_font_color_lightest,
          fillcolor = db_font_color,
        }
        
        local page_progress = TextWidget:new {
          text = string.format("page %i of %i", db_pagedone, db_pagetotal),
          face = Font:getFace("cfont", db_font_size_small),
          bold = false,
          fgcolor = db_font_color_lighter,
          padding = 0,
          align = "left"
        }
        
        local percentage_display = TextWidget:new {
          text = string.format("%i%%", db_pagedone/db_pagetotal*100 ),
          face = Font:getFace("cfont", db_font_size_small),
          bold = false,
          fgcolor = db_font_color_lighter,
          padding = 0,
          align = "right"
        }	
        
        local progressmodule = VerticalGroup:new{
          progress_bar,
          HorizontalGroup:new{
            page_progress, 
            HorizontalSpan:new{width = progressbarwidth - page_progress:getSize().w - percentage_display:getSize().w},
            percentage_display,
          },
        }
        
        local box_structure = VerticalGroup:new{}
        
        if boxtitle then
            box_structure[#box_structure + 1] = boxtitle
            box_structure[#box_structure + 1] = VerticalSpan:new{ width = db_padding_internal}
        end
        
        box_structure[#box_structure + 1] = book_or_chapter_name
        box_structure[#box_structure + 1] = VerticalSpan:new{ width = db_padding_internal}
        box_structure[#box_structure + 1] = progressmodule
      
    return box_structure
    end

    local batt_pct_box = TextWidget:new {
        text = battery,
        face = Font:getFace("cfont", db_font_size_small),
        bold = false,
        fgcolor = db_font_color,
        padding = 0,
      }
    
    local glyph_clock = "⌚"	
    local time_box = TextWidget:new {
        text = string.format("%s%s", glyph_clock, current_time),
        face = Font:getFace("cfont", db_font_size_small),
        bold = false,
        fgcolor = db_font_color,
        padding = 0,
      }
      
    local bottom_bar = HorizontalGroup:new{
        batt_pct_box,
        HorizontalSpan:new{width = (widget_width - time_box:getSize().w - batt_pct_box:getSize().w)},
        time_box,
      }
  

    -- Create book title widget
    local book_title_widget = TextBoxWidget:new{
        face = Font:getFace(db_font_face, db_font_size_mid),
        text = book_title,
        width = widget_width,
        fgcolor = db_font_color,
        bold = true,
        padding = 0,
    }
    
    -- Create author widget (smaller font, lighter color)
    local book_author_widget = TextBoxWidget:new{
        face = Font:getFace(db_font_face, db_font_size_small),
        text = book_author,
        width = widget_width,
        fgcolor = db_font_color,
        padding = 0,
    }
    
    -- Create book info section with title, author, and progress
    local progressbarwidth = widget_width
    local book_progress_bar = ProgressWidget:new{
        width = progressbarwidth,
        height = Screen:scaleBySize(3), 
        percentage = book_pageno/book_pages_total,
        margin_v = 0,
        margin_h = 0,
        radius = 20,
        bordersize = 0,
        bgcolor = db_font_color_lightest,
        fillcolor = db_font_color,
    }
    
    local book_page_progress = TextWidget:new {
        text = string.format("page %i of %i", book_pageno, book_pages_total),
        face = Font:getFace("cfont", db_font_size_small),
        bold = false,
        fgcolor = db_font_color_lighter,
        padding = 0,
        align = "left"
    }
    
    local book_percentage_display = TextWidget:new {
        text = string.format("%i%%", book_pageno/book_pages_total*100 ),
        face = Font:getFace("cfont", db_font_size_small),
        bold = false,
        fgcolor = db_font_color_lighter,
        padding = 0,
        align = "right"
    }
    
    local book_progressmodule = VerticalGroup:new{
        book_progress_bar,
        HorizontalGroup:new{
            book_page_progress, 
            HorizontalSpan:new{width = progressbarwidth - book_page_progress:getSize().w - book_percentage_display:getSize().w},
            book_percentage_display,
        },
    }
    
    local bookbox = VerticalGroup:new{
        book_title_widget,
        book_author_widget,
        VerticalSpan:new{ width = db_padding_internal },
        book_progressmodule,
    }
    
    -- Add "Chapter" prefix if not already present
    local chapter_display_title = chapter_title
    if chapter_title ~= "" and not chapter_title:lower():match("^chapter") then
        chapter_display_title = "Chapter " .. chapter_title
    end
    local chapterbox = databox("Chapter", chapter_display_title, chapter_pages_done, chapter_pages_total, false)

    local cover_widget
    if self.ui and self.ui.bookinfo and self.ui.document then
        local cover_bb = self.ui.bookinfo:getCoverImage(self.ui.document)
        if cover_bb then
            local cover_width = cover_bb:getWidth()
            local cover_height = cover_bb:getHeight()
            local max_width = widget_width
            local max_height = math.floor(Screen:getHeight() / 7)  
            
            local scale = max_width / cover_width
            local scaled_w = max_width
            local scaled_h = math.max(1, math.floor(cover_height * scale))
            
            if scale ~= 1 then
                cover_bb = RenderImage:scaleBlitBuffer(cover_bb, scaled_w, scaled_h, true)
            end
            
            if scaled_h > max_height then
                cover_bb = cover_bb:viewport(0, 0, scaled_w, max_height)
            end
            
            cover_widget = CenterContainer:new{
                dimen = Geom:new{
                    w = widget_width,
                    h = max_height,
                },
                FrameContainer:new{
                    padding = 0,
                    margin = 0,
                    bordersize = 0,
                    radius = 10,
                    clip = true,
                    ImageWidget:new{
                        image = cover_bb,
                        width = scaled_w,
                        height = math.min(scaled_h, max_height),
                    },
                },
            }
        end
    end

    local content_children = {}
    if cover_widget then
        content_children[#content_children + 1] = cover_widget
        content_children[#content_children + 1] = VerticalSpan:new{ width = db_padding_internal }
    end
    content_children[#content_children + 1] = bookbox
    content_children[#content_children + 1] = VerticalSpan:new{ width = db_padding_internal }
    content_children[#content_children + 1] = chapterbox
    content_children[#content_children + 1] = VerticalSpan:new{ width = db_padding_internal }
    content_children[#content_children + 1] = bottom_bar

    local final_frame = FrameContainer:new{
        radius = 15,  
        bordersize = 3, 
        padding_top = db_padding,
        padding_right = db_padding,
        padding_bottom = db_padding,
        padding_left = db_padding, 
        background = Blitbuffer.COLOR_WHITE, 
        VerticalGroup:new(content_children),
    }

    self[1] = CenterContainer:new{
          dimen = Screen:getSize(),
          final_frame,
    }
    
    -- taps and keypresses
    
    if Device:hasKeys() then        
        self.key_events.AnyKeyPressed = { { Device.input.group.Any } }
    end
    if Device:isTouchDevice() then
        self.ges_events.Swipe = {
            GestureRange:new{
                ges = "swipe",
                range = function() return self.dimen end,
            }
        }
        self.ges_events.Tap = {
            GestureRange:new{
                ges = "tap",
                range = function() return self.dimen end,
            }
        }
        self.ges_events.MultiSwipe = {
            GestureRange:new{
                ges = "multiswipe",
                range = function() return self.dimen end,
            }
        }
    end
    
end

function quicklookbox:onTap()
    UIManager:close(self)
end

function quicklookbox:onSwipe(arg, ges_ev)
    if ges_ev.direction == "south" then
        self:onClose()
    elseif ges_ev.direction == "east" or ges_ev.direction == "west" or ges_ev.direction == "north" then
        self:onClose()
    else
        self:onClose()
    end
end

function quicklookbox:onClose()
    UIManager:close(self)
    return true
end

quicklookbox.onAnyKeyPressed = quicklookbox.onClose

quicklookbox.onMultiSwipe = quicklookbox.onClose


Dispatcher:registerAction("quicklookbox_action", {
                            category="none", 
                            event="QuickLook", 
                            title=_("Book Receipt"), 
                            reader=true,})

function ReaderUI:onQuickLook()

UIManager:nextTick(function()

local widget = quicklookbox:new{

ui = self,

document = self.document,

state = self.view and self.view.state,

}

UIManager:show(widget)

end)

end
