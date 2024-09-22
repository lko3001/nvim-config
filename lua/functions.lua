vim.api.nvim_create_user_command('Layout', function()
  vim.api.nvim_command 'Neotree'
  vim.api.nvim_command 'wincmd l'
  vim.api.nvim_command 'split'
  vim.api.nvim_command 'wincmd J'
  vim.api.nvim_command 'terminal'
  vim.api.nvim_command 'wincmd k'
  vim.api.nvim_command 'wincmd l'
  vim.api.nvim_command 'resize +20'
end, {})

vim.api.nvim_create_user_command('UploadToFTP', function()
  -- Get the current file path from Neovim
  local filename = vim.fn.expand '%' -- Gets the relative path of the current file

  -- Construct the curl command with the correct path
  local cmd = string.format('!curl -T "%s" "ftp://user:pass@host/public_html/app/%s"', filename, filename)

  -- Execute the curl command
  vim.api.nvim_command(cmd)
end, {})

vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})
vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
