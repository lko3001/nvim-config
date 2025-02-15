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

vim.api.nvim_create_user_command('Lazygit', function()
  vim.cmd 'FloatermNew --autoclose=0 --height=0.9 --width=0.9 lazygit'
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

vim.api.nvim_create_user_command('Run', function()
  -- Check if buffer is writable
  if vim.bo.buftype ~= '' then
    print 'Cannot run: current buffer is not writable'
    return
  end

  -- Save the file first if modified
  if vim.bo.modified then
    vim.cmd 'write'
  end

  if vim.bo.filetype == 'python' then
    vim.cmd 'FloatermNew --autoclose=0 python3 %'
  elseif vim.bo.filetype == 'javascript' then
    vim.cmd 'FloatermNew --autoclose=0 node %'
  elseif vim.bo.filetype == 'typescript' then
    vim.cmd 'FloatermNew --autoclose=0 tsc % && node %:r.js'
  elseif vim.bo.filetype == 'sh' then
    vim.cmd 'FloatermNew --autoclose=0 bash %'
  elseif vim.bo.filetype == 'c' then
    vim.cmd 'FloatermNew --autoclose=0 gcc % -o %< && ./%<'
  elseif vim.bo.filetype == 'pug' then
    vim.cmd 'silent !pug %'
  else
    print 'Filetype not supported'
  end
end, {})

vim.api.nvim_create_user_command('MDNDocs', function()
  vim.cmd 'normal! hl' -- to make sure to close the popup
  vim.cmd 'normal K' -- open it
  vim.cmd 'normal K' -- go inside of it
  vim.defer_fn(function()
    vim.cmd 'normal! G$h'
    vim.cmd 'normal gx'
    vim.cmd 'normal q'
  end, 50)
end, { desc = 'Open MDN Docs' })

function GenerateFontSizeSnippet(first_number, second_number, third_number)
  -- Start building the output string
  local output = '.fs-' .. first_number .. '\n'
  output = output .. '/* ' .. first_number .. ' ' .. second_number .. ' */\n'
  output = output .. 'font-size: ' .. first_number .. 'rem;\n'
  output = output .. 'line-height: ' .. (second_number / first_number) .. ';\n'

  -- Check if the third parameter is provided
  if third_number then
    output = output .. 'letter-spacing: ' .. third_number .. ';\n'
  end

  -- Print the output in Neovim's command line
  print(output)
end

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.hbs',
  command = 'set filetype=html',
})
