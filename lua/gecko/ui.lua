local popup = require('plenary.popup')
local curl = require("plenary.curl")
local vim = vim

local function get_request(req_url, decode_body_as_json)
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

local M = {}
Gecko_buf = nil
Gecko_win_id = nil

local function create_window(width, height)
    width = width or 60
    height = height or 10
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    local bufnr = vim.api.nvim_create_buf(false, false)

    local win_id, win = popup.create(bufnr, {
        title = "FOO BAR",
        highlight = "GeckoPriceWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.api.nvim_win_set_option(
        win.border.win_id,
        "winhl",
        "Normal:GeckoPriceBorder"
    )

    return {
        bufnr = bufnr,
        win_id = win_id,
    }
end

local function close_window()
    vim.api.nvim_win_close(Gecko_win_id, true)
    Gecko_win_id = nil
    Gecko_buf = nil
end

local function set_buffer_contents(buf, contents)
    vim.api.nvim_buf_set_name(buf, "gecko-menu")
    if #contents < 9 then
        for i = 1, 10 - #contents - 1 do contents[#contents + 1] = "" end
    end
    contents[#contents + 1] = "<leader>zt to close ; <leader>zr to refresh"
    vim.api.nvim_buf_set_lines(buf, 0, #contents, false, contents)

    vim.api.nvim_buf_set_option(buf, "filetype", "gecko")
    vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "delete")
end

local function get_random_full_name()
    local req_url = "https://random-data-api.com/api/v2/users"
    local resp = get_request(req_url, true)

    if not resp.success then
        error("Could not make request")
    end

    local random_full_name = resp.json_table['first_name'] .. " " .. resp.json_table['last_name']

    return random_full_name
end

function M.refresh_prices()
    -- Gather prices and then create the messages which will be displayed

    if Gecko_win_id ~= nil and vim.api.nvim_win_is_valid(Gecko_win_id) then
        local req_status, random_full_name = pcall(get_random_full_name)

        if req_status then
            set_buffer_contents(Gecko_buf, { random_full_name })
        else
            set_buffer_contents(Gecko_buf, { "[ERROR] No prices found" })
        end
    else
        print("Window does not exists, no price data will be shown")
    end
end

function M.toggle_window()
    if Gecko_win_id ~= nil and vim.api.nvim_win_is_valid(Gecko_win_id) then
        close_window()
        return
    end

    local win_info = create_window(vim.g.gecko_window_width, vim.g.gecko_window_height)
    Gecko_win_id = win_info.win_id
    Gecko_buf = win_info.bufnr

    set_buffer_contents(Gecko_buf, { "gm!", "We are gonna make it", "hahaha" })

    M.refresh_prices()

    vim.api.nvim_buf_set_keymap(
        Gecko_buf,
        "n",
        "<leader>zt",
        ":lua require('gecko.ui').toggle_window()<CR>",
        { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        Gecko_buf,
        "n",
        "<leader>zr",
        ":lua require('gecko.ui').refresh_prices()<CR>",
        { silent = true }
    )
end

return M
