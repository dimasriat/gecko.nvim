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
        local line = "[" .. coin['id'] .. "] " .. coin['name'] .. " (" .. coin['symbol'] .. ")"
        table.insert(lines, line)
    end

    return lines
end


local generate_new_finder = function()
    local result = generate_finder_result()
    return finders.new_table {
        results = result,
    }
end

-- our picker function: colors
local colors = function(opts)
    opts = opts or {}
    print(vim.inspect(opts))
    pickers.new(opts, {
        prompt_title = "Find Coins",
        finder = generate_new_finder(),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                create_split_buffer({ selection[1] })
            end)
            return true
        end,

    }):find()
end

-- to execute the function
colors()
