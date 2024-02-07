local Ui = require('gecko.ui')
local telescope = require('telescope')
telescope.load_extension('gecko')

local ui = Ui:new()

local Gecko = {}
Gecko.__index = Gecko

function Gecko:new()
    local obj = {
        ui = Ui:new(),
    }
    local gecko = setmetatable(obj, self)
    return gecko
end

function Gecko:find_coin()
    vim.cmd([[:Telescope gecko find_coin]])
end

function Gecko:reload()
    require('plenary.reload').reload_module('gecko', true)
    print("Gecko Reloaded! wen lambo?")
end

function Gecko:toggle_ui()
    ui:toggle_ui()
    print("ui should be toggled")
end

local the_gecko = Gecko:new()

return the_gecko
