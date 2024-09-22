vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', 'gh', vim.diagnostic.open_float, { desc = 'Open diagnostic float window' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', 'cr', 'ctr')
vim.keymap.set('n', '<leader>cn', '<cmd>cnext<CR>') -- next quickfix
vim.keymap.set('n', '<leader>cp', '<cmd>cprevious<CR>') -- previous quickfix
vim.keymap.set('n', '<leader>uf', '<cmd>UploadToFTP<CR>', { desc = 'Upload to FTP', silent = true }) -- previous quickfix

vim.keymap.set('n', '<C-w>r', function()
  vim.cmd 'normal! hl' -- to make sure to close the popup
  vim.cmd 'normal K' -- open it
  vim.cmd 'normal K' -- go inside of it
  vim.defer_fn(function()
    vim.cmd 'normal! G$h'
    vim.cmd 'normal gx'
    vim.cmd 'normal q'
  end, 50)
end, { desc = 'Open MDN Docs' })

vim.keymap.set('n', '<C-CR>', function()
  local command = ''
  --
  if vim.bo.filetype == 'python' then
    command = 'python3'
  elseif vim.bo.filetype == 'sh' then
    vim.cmd 'FloatermNew --autoclose=0 bash %'
    return
  elseif vim.bo.filetype == 'c' then
    vim.cmd 'FloatermNew --autoclose=0 gcc % -o %< && ./%<'
    return
  else
    print 'Filetype not supported'
    return
  end

  vim.api.nvim_command 'w'
  vim.api.nvim_command('!' .. command .. ' %')
end, { desc = 'Run current file' })
