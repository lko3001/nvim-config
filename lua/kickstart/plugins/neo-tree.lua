-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = { { '<C-b>', ':Neotree toggle last<CR>', desc = 'NeoTree reveal' } },
  opts = {
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      window = {
        width = 30,
        mappings = {
          ['<C-b>'] = 'close_window',
        },
      },
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
  -- buffers = { follow_current_file = { enable = true } },
}
