return {
  { 'mikesmithgh/gruvsquirrel.nvim' },
  { 'fcpg/vim-fahrenheit' },
  { 'folke/tokyonight.nvim' },
  { 'rebelot/kanagawa.nvim' },
  {
    'ribru17/bamboo.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('bamboo').setup {}
      require('bamboo').load()

      local util = require 'bamboo.util'
      local bamboo_colors = require 'bamboo.colors'
      local darker_bg = util.darken(bamboo_colors.bg0, 0.250)
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = darker_bg })
    end,
  },
  {
    'sainnhe/gruvbox-material',
    config = function()
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_foreground = 'original'
      vim.g.gruvbox_material_background = 'hard'
      -- vim.cmd.colorscheme 'gruvbox-material'
    end,
  },
}
