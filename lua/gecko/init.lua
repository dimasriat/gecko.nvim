local gecko_ui = require('gecko.ui')

local M = {}

function M.hello()
    print("Wen lambo?")
end

function M.split()
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, {"Hello, world!"})
end

function M.toggle()
    gecko_ui.toggle_window()
end

function M.setup(opts)
    local function set_default(opt, default)
        if vim.g["gecko_" .. opt] ~= nil then
            return
        elseif opts[opt] ~= nil then
            vim.g["gecko_" .. opt] = opts[opt]
        else
            vim.g["gecko_" .. opt] = default
        end
    end

    set_default("window_width", 60)
    set_default("window_height", 10)

    vim.api.nvim_set_keymap('n', '<leader>zs', '<cmd>lua require("gecko").split()<CR>',
        { noremap = true, silent = true })
end

-- Default config setup
M.setup({})

return M
