local OutputBuilder = require('gecko.output')

describe("OutputBuilder", function()
    local ob

    before_each(function()
        ob = OutputBuilder.new()
    end)

    describe("push_buffer_line", function()
        it("should add a newline to the output", function()
            -- arrange
            local input = "Hello, world!"
            local expected = { input }

            -- act
            ob:push_buffer_line("Hello, world!")
            local actual = ob:get_buffer_lines()

            -- assert
            assert.same(expected, actual)
        end)

        it("should add multiple lines to the output", function()
            -- arrange
            local input1 = "Hello, world!"
            local input2 = "Goodbye, world!"
            local expected = { input1, input2 }

            -- act
            ob:push_buffer_line("Hello, world!")
            ob:push_buffer_line("Goodbye, world!")
            local actual = ob:get_buffer_lines()

            -- assert
            assert.same(expected, actual)
        end)
    end)

    describe("add_heading", function()
        it("should add a heading to the output", function()
            -- arrange
            local heading = "Hello, world!"
            local expected = {
                "================================================================================",
                heading,
                ""
            }

            -- act
            ob:add_heading("Hello, world!")
            local actual = ob:get_buffer_lines()

            -- assert
            assert.same(expected, actual)
        end)
    end)
end)
