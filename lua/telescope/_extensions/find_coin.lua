local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local OutputBuilder = require('gecko.output')

local api = require('gecko.api')

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

    -- links
    ob:add_content("LINKS", {
        { "CoinGecko",        { "https://www.coingecko.com/en/coins/" .. coin_detail['web_slug'] } },
        { "Homepage",         coin_detail['links']['homepage'] },
        { "Blockchain Site",  coin_detail['links']['blockchain_site'] },
        { "Official Forum",   coin_detail['links']['official_forum_url'] },
        { "Chat URL",         coin_detail['links']['chat_url'] },
        { "Announcement URL", coin_detail['links']['announcement_url'] },
        { "Twitter",          { coin_detail['links']['twitter_screen_name'] } },
        { "Telegram",         { coin_detail['links']['telegram_channel_identifier'] } },
        { "Github",           coin_detail['links']['repos_url']['github'] },
    })

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
