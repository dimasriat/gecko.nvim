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
        self.window_id = vim.api.nvim_open_win(0, true, {
            relative = "editor",
            width = 80,
            height = 20,
            row = 10,
            col = 10,
            style = "minimal",
            border = "single",
        })
        self.buffer_id = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(self.window_id, self.buffer_id)
        self.is_window_open = true

        -- add keymap to close the window
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
