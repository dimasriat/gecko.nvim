local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local utils = require('gecko.utils')
local api = require('gecko.api')

local function generate_finder_result()
    local coin_list = api.get_coin_list()

    local lines = {}
    for _, coin in ipairs(coin_list) do
        local coin_data = {
            coin['id'],
            coin['name'],
            coin['symbol'],
        }

        table.insert(lines, coin_data)
    end

    return lines
end

local function generate_coin_detail_buffers(json)
    local title = json['name'] .. " (" .. json['symbol'] .. ")"
    local link = json['links']['homepage'][1]
    local price_usd = json['market_data']['current_price']['usd'] .. " USD"
    local platform = json['platforms']
    print(vim.inspect(platform))

    -- iterate

    local lines = {
        title,
        "",
        "Link: " .. link,
        "",
        utils.create_separator("="),
        "Market Data: ",
        "",
        "Price: " .. price_usd,
        -- "Description: " .. json['description']['en'],
        "",
        utils.create_separator("="),
        "Address accross chain: ",
    }

    for k, v in pairs(platform) do
        table.insert(lines, "")
        table.insert(lines, k)
        table.insert(lines, v)
        print(vim.inspect(k .. v))
    end

    return lines
end

local function generate_finder_action(coin_display)
    local coin_id = string.match(coin_display, "(.-) :")
    local coin_detail = api.get_coin_detail(coin_id)
    local lines = generate_coin_detail_buffers(coin_detail)

    utils.create_split_buffer(lines)
end

local generate_new_finder = function()
    local result = generate_finder_result()
    return finders.new_table {
        results = result,
        entry_maker = function(entry)
            local display = entry[1] .. " : " .. entry[2] .. " (" .. entry[3] .. ")"
            return {
                value = display,
                display = display,
                ordinal = display
            }
        end

    }
end

-- our picker function: colors
local coin_finder = function(opts)
    opts = opts or {}
    pickers.new(opts, {
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

-- to execute the function
coin_finder()
