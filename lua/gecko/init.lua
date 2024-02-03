local curl = require("plenary.curl")

local utils = require('gecko.utils')

-------------------- Module Helpers --------------------

local function fetch_coingecko_coins_list()
    local req_url = "https://api.coingecko.com/api/v3/coins/list?include_platform=true"
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

-------------------- Main --------------------

local M = {}

function M.setup(opts)
    require('plenary.reload').reload_module('gecko', true)
    vim.api.nvim_set_keymap('n', '<leader>zs', '<cmd>lua require("gecko").fetch_api()<CR>',
        { noremap = true, silent = true })
end

function M.hello()
    print("Wen lambo?")
end

-- lua require("gecko").fetch_api()
function M.fetch_api()
    local response = fetch_coingecko_coins_list()

    local lines = {}
    local response_decoded = vim.fn.json_decode(response)
    for _, coin in ipairs(response_decoded) do
        table.insert(lines, vim.fn.json_encode(coin))
    end
    utils.create_split_buffer(lines)
end

function M.split()
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "Hello, world!" })
end

M.setup({})

return M
