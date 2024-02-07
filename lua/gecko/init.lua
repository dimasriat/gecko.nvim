local Ui = require('gecko.ui')
local Api = require('gecko.api')
local CoinPicker = require('gecko.coin_picker')

local Gecko = {}
Gecko.__index = Gecko

function Gecko:new()
    local ui = Ui:new()
    local api = Api:new()
    local picker = CoinPicker:new(api, ui)
    local obj = {
        ui = ui,
        picker = picker,
    }
    local gecko = setmetatable(obj, self)
    return gecko
end

function Gecko:find_coin()
    self.picker:find_coin()
end

function Gecko:reload()
    require('plenary.reload').reload_module('gecko', true)
    print("Gecko Reloaded! wen lambo?")
end

function Gecko:toggle_ui()
    self.ui:toggle_ui()
    print("ui should be toggled")
end

local the_gecko = Gecko:new()

return the_gecko
