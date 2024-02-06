-- UTILS
local function create_separator(symbol)
    if symbol == nil then
        symbol = ""
    end
    local lines = ""
    for _ = 1, 80 do
        lines = lines .. symbol
    end
    return lines
end

-- CLASS
local OutputBuilder = {}
OutputBuilder.__index = OutputBuilder

function OutputBuilder.new()
    local instance = setmetatable({}, OutputBuilder)
    instance.buffer_lines = {}
    return instance
end

-- get buffer_lines
function OutputBuilder:get_buffer_lines()
    return self.buffer_lines
end

-- push buffer line to buffer_lines
function OutputBuilder:push_buffer_line(line)
    table.insert(self.buffer_lines, line)
end

-- add heading to buffer_lines
function OutputBuilder:add_heading(heading)
    self:push_buffer_line(create_separator("="))
    self:push_buffer_line(heading)
    self:push_buffer_line("")
end

function OutputBuilder:output_window()
    local lines = self.buffer_lines
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    return win, buf
end

function OutputBuilder:add_content(heading, list_groups)
    self:add_heading(heading)
    self:add_list(list_groups)
end

function OutputBuilder:add_list(list_groups)
    for _, list_group in ipairs(list_groups) do
        local list_title = list_group[1]
        local list_contents = list_group[2]
        print(vim.inspect(list_contents))
        self:push_buffer_line(list_title .. ":")
        for _, list_content in ipairs(list_contents) do
            if list_content ~= vim.NIL and list_content ~= "" then
                self:push_buffer_line("*\t" .. list_content)
            end
        end
        self:push_buffer_line("")
    end
end

return OutputBuilder

-- example

-- local ob = OutputBuilder.new()
--
-- ob:add_content("OVERVIEW", {
--     { "Name",   { "Chainlink" } },
--     { "Symbol", { "LINK" } },
--     { "Link",
--         {
--             "https://chain.link",
--             "https://coinmarketcap.com/currencies/chainlink/",
--         }
--     },
-- })
-- ob:add_content("OVERVIEW", {
--     { "Name",   { "Chainlink" } },
--     { "Symbol", { "LINK" } },
--     { "Link",
--         {
--             "https://chain.link",
--             "https://coinmarketcap.com/currencies/chainlink/",
--         }
--     },
-- })
--
-- ob:output_window()
