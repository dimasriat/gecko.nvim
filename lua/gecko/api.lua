local utils = require("gecko.utils")

local M = {}

function M.get_coin_list()
    local req_url = "https://api.coingecko.com/api/v3/coins/list"
    local response = utils.fetch_url(req_url)
    local response_decoded = vim.fn.json_decode(response)
    return response_decoded
end

function M.get_coin_detail(coin_id)
    local req_url = "https://api.coingecko.com/api/v3/coins/" .. coin_id
    local response = utils.fetch_url(req_url)
    local response_decoded = vim.fn.json_decode(response)
    return response_decoded
end

return M
