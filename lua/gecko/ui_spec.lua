local Ui = require("gecko.ui")

describe("Ui", function ()
    describe("toggle_ui", function ()
        it("should toggle the window", function ()
            local ui = Ui.new()

            ui:toggle_ui()
            local actual_status_1 = ui:get_window_id()
            assert.same(vim.api.get_current_win(), actual_status_1)
            assert.same(vim.api.nvim_win_is_valid(actual_status_1), true)

            ui:toggle_ui()
            local actual_status_2 = ui:get_window_id()
            assert.same(vim.api.nvim_win_is_valid(actual_status_2), false)

        end)

        it("should toggle the buffer", function ()
            -- arrange

            -- act
            ui:toggle_ui()
            local actual = ui:get_buffer_id()

            -- assert
        end)
    end)
end)
