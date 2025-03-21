local utils = require("config.utils")

vim.api.nvim_create_user_command("OilToggleFloat", function()
    local oil = require("oil")
    oil.toggle_float(oil.get_current_dir())
end, { desc = "Oil toggle float" })

vim.api.nvim_create_user_command("ProjectSwitcher", function()
    local projects_directory = "/home/lko/egloo/"

    return require("snacks").picker({
        title = "Projects",

        finder = function()
            local items = {}

            local project_directories = vim.fn.readdir(projects_directory,
                function(entry) return vim.fn.isdirectory(projects_directory .. entry) end)
            for key, value in pairs(project_directories) do
                table.insert(items, { idx = key, text = value })
            end

            return items
        end,

        format = function(item, _)
            return { { item.text } }
        end,

        confirm = function(picker, item)
            picker:close()
            local new_directory = projects_directory .. item.text
            vim.cmd({ cmd = "cd", args = { new_directory } })
            vim.cmd({ cmd = "Explore", args = { new_directory } })
            vim.cmd({ cmd = "LspRestart", args = {} })
            print("Switched to: " .. item.text)
        end,
        preview = "none"
    })
end, { desc = "Open project picker" })

vim.api.nvim_create_user_command("FormatDisable", function()
    ---@diagnostic disable-next-line: assign-type-mismatch
    require("conform").setup({ format_on_save = false })
end, { desc = "Disable formatting" })

vim.api.nvim_create_user_command("FormatEnable", function()
    ---@diagnostic disable-next-line: assign-type-mismatch
    require("conform").setup({ format_on_save = true })
end, { desc = "Enable formatting" })

vim.api.nvim_create_user_command("Run", function()
    if vim.bo.buftype ~= "" then
        print("Cannot run: current buffer is not writable")
        return
    end

    if vim.bo.modified then
        vim.cmd("write")
    end

    if vim.bo.filetype == "python" then
        vim.cmd("FloatermNew --autoclose=0 python3 %")
    elseif vim.bo.filetype == "javascript" then
        vim.cmd("FloatermNew --autoclose=0 node %")
    elseif vim.bo.filetype == "typescript" then
        vim.cmd("FloatermNew --autoclose=0 tsc % && node %:r.js")
    elseif vim.bo.filetype == "sh" then
        vim.cmd("FloatermNew --autoclose=0 bash %")
    elseif vim.bo.filetype == "c" then
        vim.cmd("FloatermNew --autoclose=0 gcc % -o %< && ./%<")
    elseif vim.bo.filetype == "lua" then
        vim.cmd("FloatermNew --autoclose=0 lua %")
    else
        print("Filetype not supported")
    end
end, { desc = "Run file" })

vim.api.nvim_create_user_command("FontGenerator", function(details)
    local args = details.fargs
    local font_size_px = tonumber(args[1])
    local line_height_px = tonumber(args[2])
    local letter_spacing = tonumber(args[3])

    if not font_size_px then
        error("You need to provide a font size value")
        return
    end

    local lines = {}

    table.insert(lines, ".fs-" .. font_size_px .. " {")

    table.insert(lines, "\t font-size: " .. font_size_px / 16 .. "rem;")

    if line_height_px then
        table.insert(lines, "\t line-height: " .. line_height_px / font_size_px .. ";")
    end

    if letter_spacing then
        table.insert(lines, "\t letter-spacing: " .. letter_spacing / 16 .. "rem;")
    end

    table.insert(lines, "}")

    utils.write_lines(lines)
end, { desc = "Generate font size", nargs = "*" })

vim.api.nvim_create_user_command("HexToRgb", function()
    local line = vim.api.nvim_get_current_line()
    local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    local modified = false

    -- Function to convert hex to rgb
    local function hex_to_rgb(hex, with_alpha)
        if #hex == 8 and with_alpha then -- #RRGGBBAA
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            local a = tonumber(hex:sub(7, 8), 16) / 255
            return string.format("rgba(%d, %d, %d, %.2f)", r, g, b, a)
        elseif #hex == 6 then -- #RRGGBB
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            return string.format("rgb(%d, %d, %d)", r, g, b)
        elseif #hex == 3 then -- #RGB
            local r = tonumber(hex:sub(1, 1) .. hex:sub(1, 1), 16)
            local g = tonumber(hex:sub(2, 2) .. hex:sub(2, 2), 16)
            local b = tonumber(hex:sub(3, 3) .. hex:sub(3, 3), 16)
            return string.format("rgb(%d, %d, %d)", r, g, b)
        end
        return nil
    end

    -- Replace all hex colors in the line
    local new_line = line:gsub("#(%x%x%x%x%x%x%x%x)", function(hex)
        modified = true
        return hex_to_rgb(hex, true)
    end)

    new_line = new_line:gsub("#(%x%x%x%x%x%x)", function(hex)
        modified = true
        return hex_to_rgb(hex)
    end)


    -- For 3-digit hex, we need to be careful not to match parts of longer hex codes
    new_line = new_line:gsub("#(%x%x%x)([^%x])", function(hex, char)
        modified = true
        return hex_to_rgb(hex) .. char
    end)

    -- Replace the line content if changes were made
    if modified then
        vim.api.nvim_buf_set_lines(0, line_nr, line_nr + 1, false, { new_line })
    else
        print("No hex color found in current line")
    end
end, { desc = "Convert Hex color to RGB" })

-- NOTE: AUTOCMD FUNCTIONS

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
