local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local utils = require('gecko.utils')
local OutputBuilder = require('gecko.output')

local api = require('gecko.api')

local function generate_coin_detail_buffers(json)
    -- local title = json['name'] .. " (" .. json['symbol'] .. ")"
    -- local link = json['links']['homepage'][1]
    -- local price_usd = json['market_data']['current_price']['usd'] .. " USD"
    -- local platform = json['platforms']
    -- print(vim.inspect(platform))

    -- -- iterate

    -- local lines = {
    --     title,
    --     "",
    --     "Link: " .. link,
    --     "",
    --     utils.create_separator("="),
    --     "Market Data: ",
    --     "",
    --     "Price: " .. price_usd,
    --     -- "Description: " .. json['description']['en'],
    --     "",
    --     utils.create_separator("="),
    --     "Address accross chain: ",
    -- }

    -- for k, v in pairs(platform) do
    --     table.insert(lines, "")
    --     table.insert(lines, k)
    --     table.insert(lines, v)
    --     print(vim.inspect(k .. v))
    -- end

    -- return lines
end

local function generate_new_finder()
    local coin_list = api.get_coin_list()

    local lines = {}
    for _, coin in ipairs(coin_list) do
        local line = coin['id'] .. " : " .. coin['name'] .. " (" .. coin['symbol'] .. ")"
        table.insert(lines, line)
    end

    return finders.new_table({ results = lines })
end

local function generate_finder_action(coin_display)
    local coin_id = string.match(coin_display, "(.-) :")
    local coin_detail = api.get_coin_detail(coin_id)

    local ob = OutputBuilder.new()

    -- overview
    ob:add_content("OVERVIEW", {
        { "Name",   { coin_detail['name'] } },
        { "Symbol", { coin_detail['symbol'] } },
        { "URL", {
            coin_detail['links']['homepage'][1],
            "https://www.coingecko.com/en/coins/" .. coin_detail['id'],
        } },
    })

    -- market data
    ob:add_content("MARKET DATA", {
        { "Price",        { coin_detail['market_data']['current_price']['usd'] .. " USD" } },
        { "Market Cap",   { coin_detail['market_data']['market_cap']['usd'] .. " USD" } },
        { "Total Volume", { coin_detail['market_data']['total_volume']['usd'] .. " USD" } },
    })

    -- platforms
    local platform_list = {}
    for platform_id, platform_value in pairs(coin_detail['detail_platforms']) do
        if platform_id ~= "" then
            local list = {}
            -- check if platform_value['contract_address'] is not nil, then table insert to list
            if platform_value['contract_address'] ~= vim.NIL then
                table.insert(list, "address: " .. platform_value['contract_address'])
            end
            if platform_value['decimal_place'] ~= vim.NIL then
                table.insert(list, "decimals: " .. platform_value['decimal_place'])
            end
            table.insert(platform_list, { platform_id, list })
        end
    end
    ob:add_content("PLATFORMS", platform_list)

    ob:output_window()
end

local function find_coin(opts)
    opts = opts or {}
    return pickers.new(opts, {
        prompt_title = "Find Coins",
        finder = generate_new_finder(),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- print(vim.inspect(selection))
                local coin_id = selection['value']
                generate_finder_action(coin_id)
            end)
            return true
        end,

    }):find()
end

-- telescope_picker()

return find_coin
