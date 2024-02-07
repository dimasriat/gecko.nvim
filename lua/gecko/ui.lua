local popup = require("plenary.popup")

local Ui = {}
Ui.__index = Ui

function Ui:new()
    local obj = {
        window_id = nil,
        buffer_id = nil,
        is_window_open = false,
    }
    local ui = setmetatable(obj, self)
    return ui
end

function Ui:toggle_ui()
    if self.window_id == nil and self.buffer_id == nil then
        local width = 160
        local height = 40
        local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

        self.buffer_id = vim.api.nvim_create_buf(false, true)
        local window_id, _ = popup.create(self.buffer_id, {
            title = "Results",
            line = math.floor(((vim.o.lines - height) / 2)),
            col = math.floor((vim.o.columns - width) / 2),
            minwidth = width,
            minheight = height,
            borderchars = borderchars,
        })
        self.window_id = window_id
        vim.api.nvim_win_set_buf(self.window_id, self.buffer_id)
        self.is_window_open = true

        return
    end
    self:close_ui()
end

function Ui:close_ui()
    if self.window_id == nil and self.buffer_id == nil then
        return
    end
    vim.api.nvim_win_close(self.window_id, true)
    vim.api.nvim_buf_delete(self.buffer_id, { force = true })

    self.window_id = nil
    self.buffer_id = nil

    self.is_window_open = false
end

function Ui:get_window_id()
    return self.window_id
end

function Ui:get_buffer_id()
    return self.buffer_id
end

function Ui:get_is_window_open()
    return self.is_window_open
end

return Ui
