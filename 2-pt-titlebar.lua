local userpatch = require("userpatch")
local logger = require("logger")
local Device = require("device")
local Screen = Device.screen

local function patchCoverBrowser(plugin)
    local TitleBar = require("titlebar")
    
    local original_init = TitleBar.init
    
    TitleBar.init = function(self)
        self.center_icon_size_ratio = 1.0
        
        original_init(self)
        
        local button_padding = Screen:scaleBySize(11)
        local icon_reserved_width = self.icon_size + button_padding
        local icon_padding_width = icon_reserved_width * 0.65
        local icon_padding_height = Screen:scaleBySize(6)
        local icon_padding_side_offset = Screen:scaleBySize(5)  -- Reduced from 14 to push buttons to edges
        
        self.left1_button = require("ui/widget/iconbutton"):new {
            icon = self.left1_icon,
            icon_rotation_angle = 0,
            width = icon_reserved_width,
            height = self.icon_size,
            padding = button_padding,
            padding_left = icon_padding_side_offset,
            padding_right = icon_padding_width / 2,
            padding_bottom = self.icon_size * 0.2,
            padding_top = icon_padding_height,
            overlap_align = "left",
            callback = self.left1_icon_tap_callback,
            hold_callback = self.left1_icon_hold_callback,
            show_parent = self.show_parent,
        }
        
        self.left2_button = require("ui/widget/iconbutton"):new {
            icon = self.left2_icon,
            icon_rotation_angle = 0,
            width = icon_reserved_width,
            height = self.icon_size,
            padding = button_padding,
            padding_left = icon_padding_side_offset + icon_reserved_width + (0.5 * icon_padding_width),
            padding_right = icon_padding_width / 2,
            padding_bottom = self.icon_size * 0.2,
            padding_top = icon_padding_height,
            overlap_align = "left",
            callback = self.left2_icon_tap_callback,
            hold_callback = self.left2_icon_hold_callback,
            show_parent = self.show_parent,
        }
        
        self.left3_button = require("ui/widget/iconbutton"):new {
            icon = self.left3_icon,
            icon_rotation_angle = 0,
            width = icon_reserved_width,
            height = self.icon_size,
            padding = button_padding,
            padding_left = icon_padding_side_offset + (2 * icon_reserved_width) + (1 * icon_padding_width),
            padding_right = icon_padding_width / 2,
            padding_bottom = self.icon_size * 0.2,
            padding_top = icon_padding_height,
            overlap_align = "left",
            callback = self.left3_icon_tap_callback,
            hold_callback = self.left3_icon_hold_callback,
            show_parent = self.show_parent,
        }
        
        self.center_button = require("ui/widget/iconbutton"):new {
            icon = self.center_icon,
            icon_rotation_angle = 0,
            width = icon_reserved_width,
            height = self.icon_size,
            padding = button_padding,
            padding_left = 0,
            padding_right = 0,
            padding_bottom = self.icon_size * 0.2,
            padding_top = icon_padding_height,
            overlap_align = "center",
            callback = self.center_icon_tap_callback,
            hold_callback = self.center_icon_hold_callback,
            show_parent = self.show_parent,
        }
        
        self.right3_button = require("ui/widget/iconbutton"):new {
            icon = self.right3_icon,
            icon_rotation_angle = 0,
            width = icon_reserved_width,
            height = self.icon_size,
            padding = button_padding,
            padding_left = icon_padding_width / 2,
            padding_right = icon_padding_side_offset + (2 * icon_reserved_width) + (1 * icon_padding_width),
            padding_bottom = self.icon_size * 0.2,
            padding_top = icon_padding_height,
            overlap_align = "right",
            callback = self.right3_icon_tap_callback,
            hold_callback = self.right3_icon_hold_callback,
            show_parent = self.show_parent,
        }
        
        self.right2_button = require("ui/widget/iconbutton"):new {
            icon = self.right2_icon,
            icon_rotation_angle = 0,
            width = icon_reserved_width,
            height = self.icon_size,
            padding = button_padding,
            padding_left = icon_padding_width / 2,
            padding_right = icon_padding_side_offset + icon_reserved_width + (0.5 * icon_padding_width),
            padding_bottom = self.icon_size * 0.2,
            padding_top = icon_padding_height,
            overlap_align = "right",
            callback = self.right2_icon_tap_callback,
            hold_callback = self.right2_icon_hold_callback,
            show_parent = self.show_parent,
        }
        
        self.right1_button = require("ui/widget/iconbutton"):new {
            icon = self.right1_icon,
            icon_rotation_angle = 0,
            width = icon_reserved_width,
            height = self.icon_size,
            padding = button_padding,
            padding_left = icon_padding_width / 2,
            padding_right = icon_padding_side_offset,
            padding_bottom = self.icon_size * 0.2,
            padding_top = icon_padding_height,
            overlap_align = "right",
            callback = self.right1_icon_tap_callback,
            hold_callback = self.right1_icon_hold_callback,
            show_parent = self.show_parent,
        }
        
        self.left1_button_container = self.left1_button
        self.left2_button_container = self.left2_button
        self.left3_button_container = self.left3_button
        self.center_button_container = self.center_button
        self.right3_button_container = self.right3_button
        self.right2_button_container = self.right2_button
        self.right1_button_container = self.right1_button
        
        for i = #self, 1, -1 do
            self[i] = nil
        end
        
        table.insert(self, self.center_button_container)
        table.insert(self, self.left1_button_container)
        table.insert(self, self.right1_button_container)
        table.insert(self, self.left2_button_container)
        table.insert(self, self.right2_button_container)
        
        if self.left3_button and self.right3_button then
            table.insert(self, self.left3_button_container)
            table.insert(self, self.right3_button_container)
        end
        
        if self.left4_button and self.right4_button then
            table.insert(self, self.left4_button_container)
            table.insert(self, self.right4_button_container)
        end
        if self.left5_button and self.right5_button then
            table.insert(self, self.left5_button_container)
            table.insert(self, self.right5_button_container)
        end
        
        self.left_button = self.left1_button
        self.right_button = self.right1_button
    end
    
    logger.info("TitleBar patched: center icon size normalized and spacing fixed")
end

userpatch.registerPatchPluginFunc("coverbrowser", patchCoverBrowser)
