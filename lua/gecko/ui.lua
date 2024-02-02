local popup = require('plenary.popup')
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
        title = "Gecko Prices",
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
    contents[#contents + 1] = "(Press 'q' to close this window, 'r' to refresh prices)"
    vim.api.nvim_buf_set_lines(buf, 0, #contents, false, contents)

    vim.api.nvim_buf_set_option(buf, "filetype", "gecko")
    vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "delete")
end

function M.toggle_window()
    if Gecko_win_id ~= nil and vim.api.nvim_win_is_valid(Gecko_win_id) then
        close_window()
        return
    end

    local win_info = create_window(vim.g.gecko_window_width, vim.g.gecko_window_height)
    Gecko_win_id = win_info.win_id
    Gecko_buf = win_info.bufnr

    set_buffer_contents(Gecko_buf, { "gm!", "We are gonna make it" })

    vim.api.nvim_buf_set_keymap(
        Gecko_buf,
        "n",
        "q",
        ":lua require('gecko.ui').toggle_window()<CR>",
        { silent = true }
    )
end

return M
