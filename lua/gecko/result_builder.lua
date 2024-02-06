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
        if line ~= "" and line ~= vim.NIL then
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

function ResultBuilder:line_modifier(prefix, line)
    -- only add the prefix if the line is not empty and not nil
    if line ~= "" and line ~= vim.NIL then
        return prefix .. line
    else
        return line
    end
end

function ResultBuilder:output_window()
    local lines = self.buffer_lines
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    return win, buf
end

return ResultBuilder