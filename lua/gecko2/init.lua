local curl = require("plenary.curl")

-------------------- Internal Helpers --------------------

local function fetch_api(req_url, decode_body_as_json)
    local response = curl.request{
        url=req_url,
        method="get",
        accept="application/json"
    }

    local response_decoded = nil

    if response.status ~= 200 then
        return {success=false, json_table=response_decoded}
    end

    if decode_body_as_json then
        response_decoded = vim.fn.json_decode(response.body)
    end

    return {success=true, json_table=response_decoded}
end

-------------------- Module Helpers --------------------

local function fetch_coingecko_coins_list()
    -- local req_url = "https://api.coingecko.com/api/v3/coins/list"
    -- local resp = fetch_api(req_url, true)
    -- 
    -- if not resp.success then
    --     error("Could not make request")
    -- end

    -- return resp.json_table
    --
    -- local req_url = "https://api.coingecko.com/api/v3/coins/list"
    local req_url = "https://api.coingecko.com/api/v3/ping"
    local response = curl.request{
        url=req_url,
        method="get",
        accept="application/json"
    }
    if response.status ~= 200 then
        error("Could not make request")
        -- return {success=false, json_table=response_decoded}
    end
    local result = vim.fn.json_decode(response.body)
    return result
end

-------------------- Main --------------------

local M = {}

function M.setup(opts)
    require('plenary.reload').reload_module('gecko2', true)
    vim.api.nvim_set_keymap('n', '<leader>zs', '<cmd>lua require("gecko").split()<CR>',
        { noremap = true, silent = true })
end

function M.hello()
    print("Wen lambo?")
end

-- lua require("gecko2").fetch_api()
function M.fetch_api()
    local response = fetch_coingecko_coins_list()
    print("hello world hihihi")
    -- print(response)
end

function M.split()
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, {"Hello, world!"})
end

M.setup({})

return M

