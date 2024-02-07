local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local ResultBuilder = require('gecko.result_builder')

local CoinPicker = {}
CoinPicker.__index = CoinPicker

function CoinPicker:new(api, ui)
    local obj = {
        api = api,
        ui = ui,
        selected_coin_id = nil,
    }
    local coin_picker = setmetatable(obj, self)
    return coin_picker
end

function CoinPicker:generate_new_finder()
    local coin_list = self.api:get_coin_list()

    local lines = {}
    for _, coin in ipairs(coin_list) do
        local line = coin['id'] .. " : " .. coin['name'] .. " (" .. coin['symbol'] .. ")"
        table.insert(lines, line)
    end

    return finders.new_table({ results = lines })
end

function CoinPicker:generate_finder_action(coin_display)
    local coin_id = string.match(coin_display, "(.-) :")
    local coin_detail = self.api:get_coin_detail(coin_id)
    local rb = ResultBuilder.new()
    rb:generate_result_header(coin_detail['web_slug'], coin_detail['last_updated'])

    rb:add_heading("OVERVIEW")
    rb:add_content("Name", { coin_detail['name'] })
    rb:add_content("Symbol", { coin_detail['symbol'] })
    rb:add_content("Description", rb:description_parser(coin_detail['description']['en']))

    rb:add_heading("MARKET DATA")
    rb:add_content("Price", { rb:line_modifier("", coin_detail['market_data']['current_price']['usd'], " USD") })
    rb:add_content("Market Cap", { rb:line_modifier("", coin_detail['market_data']['market_cap']['usd'], " USD") })
    rb:add_content("Total Volume", { rb:line_modifier("", coin_detail['market_data']['total_volume']['usd'], " USD") })

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
    rb:add_content("Twitter", {
        rb:line_modifier("https://twitter.com/", coin_detail['links']['twitter_screen_name'], "")
    })
    rb:add_content("Telegram",
        { rb:line_modifier("https://t.me/", coin_detail['links']['telegram_channel_identifier'], "") })
    rb:add_content("Github", coin_detail['links']['repos_url']['github'])

    local lines = rb:get_buffer_lines()
    self.ui:toggle_ui(lines)
end

function CoinPicker:find_coin()
    local opts = {}
    return pickers.new(opts, {
        prompt_title = "Find Coins",
        finder = self:generate_new_finder(),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local coin_display = selection['value']
                self:generate_finder_action(coin_display)
            end)
            return true
        end,

    }):find()
end

return CoinPicker
