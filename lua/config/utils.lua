local M = {}

function M.write_lines(lines)
    local cursor_position = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor_position[1] - 1
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), cursor_line, cursor_line, false, lines)
end

function M.split_string(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function M.auto_call(variable)
    if type(variable) == "function" then return variable() end
    return variable
end

function M.get_visual_selection()
    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    return lines
end

return M
