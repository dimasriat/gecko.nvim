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

function Ui:toggle_ui(lines)
    lines = lines or {}
    if self.window_id == nil and self.buffer_id == nil then
        local buffer_id, window_id = self:create_ui()

        self.buffer_id = buffer_id
        self.window_id = window_id
        self.is_window_open = true

        -- set buffer to window
        vim.api.nvim_win_set_buf(self.window_id, self.buffer_id)

        -- set buffer content
        vim.api.nvim_buf_set_lines(buffer_id, 0, #lines, false, lines)

        -- set buffer to readonly
        vim.api.nvim_buf_set_option(buffer_id, "modifiable", false)

        return
    end
    self:close_ui()
end

function Ui:create_ui()
    local width = vim.api.nvim_win_get_width(0) - 10;
    local height = vim.api.nvim_win_get_height(0) - 10;
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    local buffer_id = vim.api.nvim_create_buf(false, true)
    local window_id, _ = popup.create(buffer_id, {
        title = "Results",
        line = math.floor(((vim.o.lines - height) / 2)),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.keymap.set("n", "q", function()
        self:close_ui()
    end, { noremap = true, silent = true, buffer = buffer_id })

    vim.keymap.set("n", "<esc>", function()
        self:close_ui()
    end, { noremap = true, silent = true, buffer = buffer_id })

    vim.api.nvim_create_autocmd("ExitPre", {
        buffer = buffer_id, -- Target the current buffer
        once = true,
        callback = function(ev)
            self:close_ui()
        end
    })

    return buffer_id, window_id
end

function Ui:close_ui()
    if self.buffer_id ~= nil then
        if vim.api.nvim_buf_is_valid(self.buffer_id) then
            vim.api.nvim_buf_delete(self.buffer_id, { force = true })
        end
    end
    if self.window_id ~= nil then
        if vim.api.nvim_win_is_valid(self.window_id) then
            vim.api.nvim_win_close(self.window_id, true)
        end
    end
    self.buffer_id = nil
    self.window_id = nil
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
