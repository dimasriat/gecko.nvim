local utils = require("gecko.utils")

local Api = {}
Api.__index = Api

function Api:new()
    local obj = {}
    local ui = setmetatable(obj, self)
    return ui
end

function Api:get_coin_list()
    local req_url = "https://api.coingecko.com/api/v3/coins/list"
    local response = utils.fetch_url(req_url)
    local response_decoded = vim.fn.json_decode(response)
    return response_decoded
end

function Api:get_coin_detail(coin_id)
    local req_url = "https://api.coingecko.com/api/v3/coins/" .. coin_id
    local response = utils.fetch_url(req_url)
    local response_decoded = vim.fn.json_decode(response)
    return response_decoded
end

return Api
