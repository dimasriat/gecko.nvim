local telescope = require('telescope')

telescope.load_extension('gecko')

local M = {}

function M.find_coin()
    vim.cmd([[:Telescope gecko find_coin]])
end

function M.reload()
    require('plenary.reload').reload_module('gecko', true)
    print("Gecko Reloaded! wen lambo?")
end

return M
