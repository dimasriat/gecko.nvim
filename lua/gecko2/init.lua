local curl = require("plenary.curl")

-------------------- Module Helpers --------------------

local function fetch_coingecko_coins_list()
    -- local req_url = "https://api.coingecko.com/api/v3/coins/list"
    local req_url = "https://api.coingecko.com/api/v3/ping"
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

local function create_split_buffer(line)
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, { line })
    return win, buf
end

-------------------- Main --------------------

local M = {}

function M.setup(opts)
    require('plenary.reload').reload_module('gecko2', true)
    vim.api.nvim_set_keymap('n', '<leader>zs', '<cmd>lua require("gecko2").fetch_api()<CR>',
        { noremap = true, silent = true })
end

function M.hello()
    print("Wen lambo?")
end

-- lua require("gecko2").fetch_api()
function M.fetch_api()
    local json_str = fetch_coingecko_coins_list()
    create_split_buffer(json_str)
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
