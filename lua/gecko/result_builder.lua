local function wrap_lines(lines, maxWidth)
    local wrappedLines = {}   -- To hold the wrapped lines
    maxWidth = maxWidth or 80 -- Default maxWidth to 80 if not specified

    for _, line in ipairs(lines) do
        local currentLine = ""            -- Initialize the current line
        local lineLength = 0              -- Track the length of the current line

        for word in line:gmatch("%S+") do -- Iterate through each word
            if lineLength + #word + 1 > maxWidth then
                -- If adding the next word exceeds maxWidth, wrap to the next line
                table.insert(wrappedLines, currentLine)
                currentLine = word
                lineLength = #word
            else
                -- Add the word to the current line
                currentLine = lineLength > 0 and currentLine .. " " .. word or word
                lineLength = lineLength + #word + (lineLength > 0 and 1 or 0) -- Add 1 for space if not the first word
            end
        end
        -- Don't forget to add the last line for the current sentence
        if currentLine ~= "" then
            table.insert(wrappedLines, currentLine)
        end
    end

    return wrappedLines
end

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

local ResultBuilder = {}
ResultBuilder.__index = ResultBuilder

function ResultBuilder.new()
    local instance = setmetatable({}, ResultBuilder)
    instance.buffer_lines = {}
    return instance
end

function ResultBuilder:generate_result_header(web_slug, last_updated)
    self:push_buffer_line("press q to close the window")
    self:push_buffer_line("")

    local header_text = [[
 _______  _______  _______  ___   _  _______        __    _  __   __  ___   __   __
|       ||       ||       ||   | | ||       |      |  |  | ||  | |  ||   | |  |_|  |
|    ___||    ___||       ||   |_| ||   _   |      |   |_| ||  |_|  ||   | |       |
|   | __ |   |___ |       ||      _||  | |  |      |       ||       ||   | |       |
|   ||  ||    ___||      _||     |_ |  |_|  | ___  |  _    ||       ||   | |       |
|   |_| ||   |___ |     |_ |    _  ||       ||   | | | |   | |     | |   | | ||_|| |
|_______||_______||_______||___| |_||_______||___| |_|  |__|  |___|  |___| |_|   |_|
    ]]

    -- push the header text to the buffer lines (trim first, then split by newline)
    -- split '\n' to a new line
    for line in string.gmatch(header_text:match("^%s*(.-)%s*$"), "[^\r\n]+") do
        self:push_buffer_line(line)
    end
    self:push_buffer_line("")

    local source_with_label = self:line_modifier("Source: https://www.coingecko.com/en/coins/", web_slug, "")
    self:push_buffer_line(source_with_label)
    self:push_buffer_line("")

    local last_updated_with_label = self:line_modifier("Last updated: ", last_updated, "")
    if last_updated_with_label ~= "" then
        self:push_buffer_line(last_updated_with_label)
        self:push_buffer_line("")
    end
end

function ResultBuilder:get_buffer_lines()
    return self.buffer_lines
end

function ResultBuilder:push_buffer_line(line)
    table.insert(self.buffer_lines, line)
end

function ResultBuilder:add_heading(heading)
    self:push_buffer_line(create_separator("="))
    self:push_buffer_line(heading)
    self:push_buffer_line("")
end

function ResultBuilder:filter_lines(lines)
    local filtered_lines = {}
    for _, line in ipairs(lines) do
        if line ~= "" and line ~= vim.NIL and line ~= nil then
            table.insert(filtered_lines, line)
        end
    end
    return filtered_lines
end

function ResultBuilder:add_content(title, lines)
    local filtered_lines = self:filter_lines(lines)
    -- only add the heading if there are lines to add
    if #filtered_lines > 0 then
        self:push_buffer_line(title)
        for _, line in ipairs(filtered_lines) do
            local line_with_bullet = "*\t" .. line
            self:push_buffer_line(line_with_bullet)
        end
        self:push_buffer_line("")
    end
end

function ResultBuilder:line_modifier(prefix, line, suffix)
    -- only add the prefix if the line is not empty and not nil
    if line ~= "" and line ~= vim.NIL and line ~= nil then
        return prefix .. line .. suffix
    else
        return ""
    end
end

function ResultBuilder:description_parser(description)
    local lines = {}
    if description == nil or description == vim.NIL then
        return lines
    end
    -- remove any newlines and carriage returns
    for line in string.gmatch(description, "[^\r\n]+") do
        table.insert(lines, line)
    end
    -- remove any html tags for each line
    for i, line in ipairs(lines) do
        lines[i] = string.gsub(line, "<[^>]+>", "")
    end
    -- Wrap lines at 80 characters
    local wrapped_lines = wrap_lines(lines, 120)
    return wrapped_lines
end

return ResultBuilder
