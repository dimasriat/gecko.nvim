local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local curl = require("plenary.curl")

local function fetch_coingecko_coins_list()
    local req_url = "https://api.coingecko.com/api/v3/coins/list"
    local response = curl.request {
        url = req_url,
        method = "get",
        accept = "application/json"
    }
    if response.status ~= 200 then
        error("Could not make request")
    end
    return response.body
end

local function fetch_coingecko_coin_details(coin_id)
    local req_url = "https://api.coingecko.com/api/v3/coins/" .. coin_id
    local response = curl.request {
        url = req_url,
        method = "get",
        accept = "application/json"
    }
    if response.status ~= 200 then
        error("Could not make request")
    end
    return response.body
end

local function create_split_buffer(lines)
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)
    return win, buf
end

local function generate_finder_result()
    local response = fetch_coingecko_coins_list()

    local lines = {}
    local response_decoded = vim.fn.json_decode(response)
    for _, coin in ipairs(response_decoded) do
        local coin_data = {
            coin['id'],
            coin['name'],
            coin['symbol'],
        }

        table.insert(lines, coin_data)
    end

    return lines
end

local function create_separator(symbol)
    if symbol == nil then
        symbol = ""
    end
    local lines = ""
    -- iterate symbol  80 times and add to lines
    for _ = 1, 80 do
        lines = lines .. symbol
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
        create_separator("="),
        "Market Data: ",
        "",
        "Price: " .. price_usd,
        -- "Description: " .. json['description']['en'],
        "",
        create_separator("="),
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
    -- coin_display == "foo-spam : bar (baz)"
    -- need to get coin_id = "foo-spam" which is everything before " :"
    local coin_id = string.match(coin_display, "(.-) :")
    local response = fetch_coingecko_coin_details(coin_id)
    local json = vim.fn.json_decode(response)
    local lines = generate_coin_detail_buffers(json)

    create_split_buffer(lines)
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
local colors = function(opts)
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
colors()
