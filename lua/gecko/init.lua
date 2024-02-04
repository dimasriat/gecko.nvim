local telescope = require('telescope')

local M = {}

function M.setup(opts)
    telescope.load_extension('gecko')
    vim.api.nvim_set_keymap('n', '<leader>zs', '<cmd>lua require("gecko").hello()<CR>',
        { noremap = true, silent = true })
end

function M.hello()
    require('plenary.reload').reload_module('gecko', true)
    print("Wen lambo?")
end

M.setup({})

return M
