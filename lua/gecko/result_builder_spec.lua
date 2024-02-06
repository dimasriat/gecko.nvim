local ResultBuilder = require("gecko.result_builder")

describe("ResultBuilder", function ()
    describe("push_buffer_line", function ()
        it("should add a newline to the output", function ()
            -- arrange
            local input = "Hello, world!"
            local expected = { input }
            local rb = ResultBuilder.new()

            -- act
            rb:push_buffer_line("Hello, world!")
            local actual = rb:get_buffer_lines()

            -- assert
            assert.same(expected, actual)
        end)

        it("should add multiple lines to the output", function ()
            -- arrange
            local input1 = "Hello, world!"
            local input2 = "Goodbye, world!"
            local expected = { input1, input2 }
            local rb = ResultBuilder.new()

            -- act
            rb:push_buffer_line("Hello, world!")
            rb:push_buffer_line("Goodbye, world!")
            local actual = rb:get_buffer_lines()

            -- assert
            assert.same(expected, actual)
        end)
    end)

    describe("add_heading", function ()
        it("should add a heading to the output", function ()
            -- arrange
            local heading = "Hello, world!"
            local expected = {
                "================================================================================",
                heading,
                ""
            }
            local rb = ResultBuilder.new()

            -- act
            rb:add_heading("Hello, world!")
            local actual = rb:get_buffer_lines()

            -- assert
            assert.same(expected, actual)
        end)
    end)

    describe("filter_lines", function ()
        it("should remove empty lines from the input", function ()
            -- arrange
            local input = {
                "foo",
                "",
                "bar",
                vim.NIL,
                "baz",
                "",
            }
            local expected = {
                "foo",
                "bar",
                "baz"
            }
            local rb = ResultBuilder.new()

            -- act
            local actual = rb:filter_lines(input)

            -- assert
            assert.same(expected, actual)
        end)
    end)

    describe("add_content", function ()
        it("should add a title and lines to the output", function ()
            -- arrange
            local title = "Hello, world!"
            local lines = {
                "",
                "foo",
                "bar",
                "",
                "baz",
            }
            local expected = {
                title,
                "*\tfoo",
                "*\tbar",
                "*\tbaz",
                ""
            }
            local rb = ResultBuilder.new()

            -- act
            rb:add_content(title, lines)
            local actual = rb:get_buffer_lines()

            -- assert
            assert.same(expected, actual)
        end)

        it("should not add a title if there are no lines", function ()
            -- arrange
            local title = "Hello, world!"
            local lines = {}
            local expected = {}
            local rb = ResultBuilder.new()

            -- act
            rb:add_content(title, lines)
            local actual = rb:get_buffer_lines()

            -- assert
            assert.same(expected, actual)
        end)
    end)
end)
