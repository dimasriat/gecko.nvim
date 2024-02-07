local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local ResultBuilder = require('gecko.result_builder')

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

local function generate_result_header(web_slug, last_updated)
    local coin_list = api.get_coin_list()

    local header_text = [[
 _______  _______  _______  ___   _  _______        __    _  __   __  ___   __   __ 
|       ||       ||       ||   | | ||       |      |  |  | ||  | |  ||   | |  |_|  |
|    ___||    ___||       ||   |_| ||   _   |      |   |_| ||  |_|  ||   | |       |
|   | __ |   |___ |       ||      _||  | |  |      |       ||       ||   | |       |
|   ||  ||    ___||      _||     |_ |  |_|  | ___  |  _    ||       ||   | |       |
|   |_| ||   |___ |     |_ |    _  ||       ||   | | | |   | |     | |   | | ||_|| |
|_______||_______||_______||___| |_||_______||___| |_|  |__|  |___|  |___| |_|   |_|
    ]]

    rb:push_buffer_line("Last updated: " .. coin_detail['last_updated'])
end

local function generate_finder_action(coin_display)
    local coin_id = string.match(coin_display, "(.-) :")
    local coin_detail = api.get_coin_detail(coin_id)
    local rb = ResultBuilder.new()
    rb:generate_result_header(coin_detail['web_slug'], coin_detail['last_updated'])

    rb:add_heading("OVERVIEW")
    rb:add_content("Name", { coin_detail['name'] })
    rb:add_content("Symbol", { coin_detail['symbol'] })
    rb:add_content("Description", rb:description_parser(coin_detail['description']['en']))

    rb:add_heading("MARKET DATA")
    rb:add_content("Price", { coin_detail['market_data']['current_price']['usd'] .. " USD" })
    rb:add_content("Market Cap", { coin_detail['market_data']['market_cap']['usd'] .. " USD" })
    rb:add_content("Total Volume", { coin_detail['market_data']['total_volume']['usd'] .. " USD" })

    rb:add_heading("PLATFORMS")
    for platform_id, platform_value in pairs(coin_detail['detail_platforms']) do
        if platform_id ~= "" then
            local list = {}
            if platform_value['contract_address'] ~= vim.NIL then
                table.insert(list, "address: " .. platform_value['contract_address'])
            end
            if platform_value['decimal_place'] ~= vim.NIL then
                table.insert(list, "decimals: " .. platform_value['decimal_place'])
            end
            rb:add_content(platform_id, list)
        end
    end

    rb:add_heading("RESOURCES")
    rb:add_content("Homepage", coin_detail['links']['homepage'])
    rb:add_content("Blockchain Site", coin_detail['links']['blockchain_site'])
    rb:add_content("Official Forum", coin_detail['links']['official_forum_url'])
    rb:add_content("Chat URL", coin_detail['links']['chat_url'])
    rb:add_content("Announcement URL", coin_detail['links']['announcement_url'])
    rb:add_content("Twitter", { "https://twitter.com/" .. coin_detail['links']['twitter_screen_name'] })
    rb:add_content("Telegram", { rb:line_modifier("https://t.me/", coin_detail['links']['telegram_channel_identifier']) })
    rb:add_content("Github", coin_detail['links']['repos_url']['github'])
    rb:output_window()
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
