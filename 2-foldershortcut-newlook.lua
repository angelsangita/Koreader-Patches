local FileManagerShortcuts = require("apps/filemanager/filemanagershortcuts")

-- Override the updateItemTable function
FileManagerShortcuts.updateItemTable = function(self)
    local item_table = {}
    for folder, item in pairs(self.folder_shortcuts) do
        table.insert(item_table, {
            text = item.text,
            folder = folder,
            name = item.text,
        })
    end
    table.sort(item_table, function(l, r)
        return l.text < r.text
    end)
    self.shortcuts_menu:switchItemTable(nil, item_table, -1)
end