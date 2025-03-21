local M = {}

function M.write_lines(lines)
    local cursor_position = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor_position[1] - 1
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), cursor_line, cursor_line, false, lines)
end

return M
