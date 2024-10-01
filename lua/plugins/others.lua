return {
  {
    'Exafunction/codeium.vim',
    enabled = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    enabled = true,
    config = function()
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').add {
        { '<leader>c', group = 'ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      }
    end,
  },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    'chipsenkbeil/distant.nvim',
    branch = 'v0.3',
    config = function()
      require('distant'):setup()
    end,
  },
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup {}
    end,
  },
  {
    'vimwiki/vimwiki',
    init = function()
      vim.g.vimwiki_list = { {
        path = '~/vimwiki/',
        syntax = 'markdown',
        ext = 'md',
      } }
    end,
  },
  {
    'barrett-ruth/live-server.nvim',
    build = 'npm i -g live-server',
    cmd = { 'LiveServerStart', 'LiveServerStop' },
    config = true,
  },
  { 'typicode/bg.nvim', lazy = false },
  { 'lumiliet/vim-twig', lazy = false },
  { 'voldikss/vim-floaterm' },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
  {
    'amadeus/vim-convert-color-to',
  },
}
