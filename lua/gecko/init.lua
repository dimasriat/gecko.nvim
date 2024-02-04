local telescope = require('telescope')
local gecko = telescope.load_extension('gecko')

local M = {}

function M.find_coin()
    gecko.find_coin()
end

function M.reload()
    require('plenary.reload').reload_module('gecko', true)
    print("Gecko Reloaded! wen lambo?")
end

vim.keymap.set('n', '<leader>zs', M.find_coin, {})

return M
