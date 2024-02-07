local gecko = require("gecko")

local eq = assert.are.same

describe("Ui", function()
    describe("toggle_ui", function()
        it("should toggle the window and buffer", function()
            gecko.ui:toggle_ui()

            local window_id = gecko.ui:get_window_id()
            local buffer_id = gecko.ui:get_buffer_id()

            eq(vim.api.nvim_win_is_valid(window_id), true)
            eq(vim.api.nvim_buf_is_valid(buffer_id), true)
            eq(gecko.ui:get_is_window_open(), true)

            gecko.ui:toggle_ui()

            eq(vim.api.nvim_win_is_valid(window_id), false)
            eq(vim.api.nvim_buf_is_valid(buffer_id), false)
            eq(gecko.ui:get_is_window_open(), false)
        end)

        it("should close when key pressed `q`", function ()
            gecko.ui:toggle_ui()

            local window_id = gecko.ui:get_window_id()
            local buffer_id = gecko.ui:get_buffer_id()

            eq(vim.api.nvim_win_is_valid(window_id), true)
            eq(vim.api.nvim_buf_is_valid(buffer_id), true)
            eq(gecko.ui:get_is_window_open(), true)

            -- press q
            vim.api.nvim_input("q")

            eq(vim.api.nvim_win_is_valid(window_id), false)
            eq(vim.api.nvim_buf_is_valid(buffer_id), false)
            eq(gecko.ui:get_is_window_open(), false)
        end)

        it("should close when key pressed `esc`", function ()
            gecko.ui:toggle_ui()

            local window_id = gecko.ui:get_window_id()
            local buffer_id = gecko.ui:get_buffer_id()

            eq(vim.api.nvim_win_is_valid(window_id), true)
            eq(vim.api.nvim_buf_is_valid(buffer_id), true)
            eq(gecko.ui:get_is_window_open(), true)

            -- press esc
            vim.api.nvim_input("<esc>")

            eq(vim.api.nvim_win_is_valid(window_id), false)
            eq(vim.api.nvim_buf_is_valid(buffer_id), false)
            eq(gecko.ui:get_is_window_open(), false)
        end)

        it("should close when type :q", function ()
            gecko.ui:toggle_ui()

            local window_id = gecko.ui:get_window_id()
            local buffer_id = gecko.ui:get_buffer_id()

            eq(vim.api.nvim_win_is_valid(window_id), true)
            eq(vim.api.nvim_buf_is_valid(buffer_id), true)
            eq(gecko.ui:get_is_window_open(), true)

            -- type :q
            vim.api.nvim_input(":q<cr>")

            eq(vim.api.nvim_win_is_valid(window_id), false)
            eq(vim.api.nvim_buf_is_valid(buffer_id), false)
            eq(gecko.ui:get_is_window_open(), false)
        end)
    end)
end)
