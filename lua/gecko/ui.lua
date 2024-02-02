local popup = require('plenary.popup')
local reqs = require("gecko.random_api")
local vim = vim

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
    local resp = reqs.get_random_user()

    if not resp.success then
       error("Could not make request")
    end

    local random_full_name = resp.json_table['first_name'] .. " " .. resp.json_table['last_name']

    return random_full_name
end

local function create_price_data()
    local contents = {}
    local req_status, random_full_name = pcall(get_random_full_name)

    if req_status then
        contents[1] = random_full_name
    else
        contents[1] = "[ERROR] No prices found"
    end
    return contents
end

function M.refresh_prices()
    -- Gather prices and then create the messages which will be displayed

    if Gecko_win_id ~= nil and vim.api.nvim_win_is_valid(Gecko_win_id) then
        local contents = create_price_data()
        set_buffer_contents(Gecko_buf, contents)
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
