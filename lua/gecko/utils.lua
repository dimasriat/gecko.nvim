local curl = require("plenary.curl")

local M = {}

function M.create_split_buffer(lines)
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    return win, buf
end

function M.fetch_url(req_url)
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

function M.create_separator(symbol)
    if symbol == nil then
        symbol = ""
    end
    local lines = ""
    for _ = 1, 80 do
        lines = lines .. symbol
    end
    return lines
end

-- TODO: add description parser

return M
