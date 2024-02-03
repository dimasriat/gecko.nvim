local M = {}

function M.setup(opts)
    require('plenary.reload').reload_module('gecko', true)
    vim.api.nvim_set_keymap('n', '<leader>zs', '<cmd>lua require("gecko").fetch_api()<CR>',
        { noremap = true, silent = true })
end

function M.hello()
    print("Wen lambo?")
end

M.setup({})

return M
