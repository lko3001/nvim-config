vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', 'gh', vim.diagnostic.open_float, { desc = 'Open diagnostic float window' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<leader>t', '<cmd>FloatermToggle<CR>', { desc = 'Toggle Flaterminal' })
vim.keymap.set('n', '<leader>t', '<cmd>FloatermToggle<CR>', { desc = 'Toggle Flaterminal' })
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<leader>cn', '<cmd>cnext<CR>')
vim.keymap.set('n', '<leader>cp', '<cmd>cprevious<CR>')
vim.keymap.set('n', '<leader>uf', '<cmd>UploadToFTP<CR>', { desc = 'Upload to FTP', silent = true })
vim.keymap.set('n', '<C-CR>', '<cmd>Run<CR>', { desc = 'Run file' })
vim.keymap.set('n', '<C-w>r', '<cmd>MDNDocs<CR>', { desc = 'Open MDN Docs' })
vim.keymap.set('n', '<leader>cc', '<cmd>ConvertColorTo rgba<CR>', { desc = 'Convert Color' })
