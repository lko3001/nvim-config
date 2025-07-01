vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.undofile = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20,o:hor50"

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-b>", vim.cmd.OilToggleFloat, { desc = "Open file tree" })
vim.keymap.set("n", "<Esc>", vim.cmd.nohlsearch, { desc = "Clear highlight" })
vim.keymap.set("n", "<C-CR>", vim.cmd.Run)
vim.keymap.set('t', '<Esc><Esc>', vim.cmd.FloatermToggle, { desc = 'Toggle Flaterminal' })
vim.keymap.set('n', '<leader>t', vim.cmd.FloatermToggle, { desc = 'Toggle Flaterminal' })
vim.keymap.set('n', '<leader>sp', vim.cmd.ProjectSwitcher, { desc = 'Switch Projects' })
vim.keymap.set('n', '<leader>cc', vim.cmd.HexToRgb, { desc = 'Convert hex to rgb' })
vim.keymap.set("n", "<leader>cn", function()
    vim.cmd.cnext()
    vim.cmd.normal("zz")
end)
vim.keymap.set("n", "<leader>cp", function()
    vim.cmd.cprevious()
    vim.cmd.normal("zz")
end)

vim.keymap.set(
    "n",
    "gh",
    function() vim.diagnostic.open_float({ border = "rounded" }) end,
    { desc = "Open diagnostic float window" }
)
vim.keymap.set(
    "n",
    "K",
    function() vim.lsp.buf.hover({ border = "rounded" }) end,
    { desc = "Open diagnostic float window" }
)
