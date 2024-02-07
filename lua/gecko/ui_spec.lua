local Ui = require("gecko.ui")
local gecko = require("gecko")

local eq = assert.are.same

describe("Ui", function ()
    describe("toggle_ui", function ()
        it("should toggle the window and buffer", function ()
            local ui = Ui:new()
            ui:toggle_ui()

            local window_id = ui:get_window_id()
            local buffer_id = ui:get_buffer_id()

            eq(vim.api.nvim_win_is_valid(window_id), true)
            eq(vim.api.nvim_buf_is_valid(buffer_id), true)
            eq(ui:get_is_window_open(), true)

            ui:toggle_ui()
            eq(vim.api.nvim_win_is_valid(window_id), false)
            eq(vim.api.nvim_buf_is_valid(buffer_id), false)
            eq(ui:get_is_window_open(), false)
        end)
    
        -- it("should close when key pressed `q`", function ()
        --     local ui = Ui.new()
        --     ui:toggle_ui()

        --     local window_id = ui:get_window_id()
        --     local buffer_id = ui:get_buffer_id()

        --     eq(vim.api.nvim_win_is_valid(window_id), true)
        --     eq(vim.api.nvim_buf_is_valid(buffer_id), true)
        --     eq(ui:get_is_window_open(), true)

        --     vim.api.nvim_feedkeys("q", "n", true)
        --     eq(vim.api.nvim_win_is_valid(window_id), false)
        --     eq(vim.api.nvim_buf_is_valid(buffer_id), false)
        --     eq(ui:get_is_window_open(), false)
        -- end)
    end)

    describe("toggle_ui using gecko", function ()
        it("should toggle the window and buffer", function ()
            gecko:toggle_ui()

            local window_id = gecko:get_window_id()
            local buffer_id = gecko:get_buffer_id()

            eq(vim.api.nvim_win_is_valid(window_id), true)
            eq(vim.api.nvim_buf_is_valid(buffer_id), true)
            eq(gecko:get_is_window_open(), true)

            gecko:toggle_ui()
            eq(vim.api.nvim_win_is_valid(window_id), false)
            eq(vim.api.nvim_buf_is_valid(buffer_id), false)
            eq(gecko:get_is_window_open(), false)
        end)
    end)
end)
