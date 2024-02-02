local gecko_ui = require('gecko.ui')

local M = {}

function M.hello()
    print("Wen lambo?")
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

    vim.api.nvim_set_keymap('n', '<leader>zt', '<cmd>lua require("gecko").toggle()<CR>', { noremap = true, silent = true })
end

-- Default config setup
M.setup({})

return M
