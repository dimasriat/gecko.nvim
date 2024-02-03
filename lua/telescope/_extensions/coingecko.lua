local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function create_split_buffer(lines)
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)
    return win, buf
end

local generate_new_finder = function()
    local result = { "red", "green", "blue" }
    return finders.new_table {
        results = result,
    }
end

-- our picker function: colors
local colors = function(opts)
    opts = opts or { "red", "green", "blue" }
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
