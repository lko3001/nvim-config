local utils = require("config.utils")

-- NOTE: MAPPINGS

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
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

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-b>", vim.cmd.OilToggleFloat, { desc = "Open file tree" })
vim.keymap.set("n", "<Esc>", vim.cmd.nohlsearch, { desc = "Clear highlight" })
vim.keymap.set("n", "gh", vim.diagnostic.open_float, { desc = "Open diagnostic float window" })
vim.keymap.set("n", "<C-CR>", vim.cmd.Run)
vim.keymap.set('t', '<leader>t', vim.cmd.FloatermToggle, { desc = 'Toggle Flaterminal' })
vim.keymap.set('n', '<leader>t', vim.cmd.FloatermToggle, { desc = 'Toggle Flaterminal' })
vim.keymap.set('n', '<leader>sp', vim.cmd.ProjectSwitcher, { desc = 'Switch Projects' })
vim.keymap.set("n", "<leader>cn", function()
  vim.cmd.cnext()
  vim.cmd.normal("zz")
end)
vim.keymap.set("n", "<leader>cp", function()
  vim.cmd.cprevious()
  vim.cmd.normal("zz")
end)

-- NOTE: FUNCTIONS

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
      print("Switched to: " .. item.text)
    end,
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
    table.insert(lines, "\t letter-spacing: " .. letter_spacing / 16 .. "em;")
  end

  table.insert(lines, "}")

  utils.write_lines(lines)
end, { desc = "Generate font size", nargs = "*" })

-- NOTE: AUTOCMD FUNCTIONS

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- NOTE: IDE CONFIGURATION

local formatters = {
  lua = { "stylua", stop_after_first = true },
  html = { "superhtml", stop_after_first = true },
  css = { "prettierd", stop_after_first = true },
  javascript = { "prettierd", stop_after_first = true },
  typescript = { "prettierd", stop_after_first = true },
  json = { "prettierd", stop_after_first = true },
}

local custom_surrounds = {
  ["p"] = {
    add = { "<?php echo ", " ?>" },
    find = "<%?php echo .- %?>",
    delete = "^(<%?php echo)().-(%?>)()$",
  },
  ["g"] = {
    add = { 'get_field("', '")' },
    find = 'get_field%(".-"%)',
    delete = '^(get_field%(")().-("%))()$',
  },
}

local lsp_servers = {
  ts_ls = {},
  cssls = {},
  html = {},
  superhtml = {},
  emmet_language_server = {
    filetypes = {
      'html',
      'typescriptreact',
      'javascriptreact',
      'javascript',
      'php',
      'typescript',
      'javascript.jsx',
      'typescript.tsx',
      'css',
      'scss',
      'astro',
    },
  },
  intelephense = {
    root_dir = function()
      return vim.fn.getcwd()
    end,
    settings = {
      init_options = {
        clearCache = true
      },
      intelephense = {
        init_options = {
          clearCache = true
        },
        stubs = {
          'apache',
          'bcmath',
          'bz2',
          'calendar',
          'com_dotnet',
          'Core',
          'ctype',
          'curl',
          'date',
          'dba',
          'dom',
          'enchant',
          'exif',
          'FFI',
          'fileinfo',
          'filter',
          'fpm',
          'ftp',
          'gd',
          'gettext',
          'gmp',
          'hash',
          'iconv',
          'imap',
          'intl',
          'json',
          'ldap',
          'libxml',
          'mbstring',
          'meta',
          'mysqli',
          'oci8',
          'odbc',
          'openssl',
          'pcntl',
          'pcre',
          'PDO',
          'pdo_ibm',
          'pdo_mysql',
          'pdo_pgsql',
          'pdo_sqlite',
          'pgsql',
          'Phar',
          'posix',
          'pspell',
          'readline',
          'Reflection',
          'session',
          'shmop',
          'SimpleXML',
          'snmp',
          'soap',
          'sockets',
          'sodium',
          'SPL',
          'sqlite3',
          'standard',
          'superglobals',
          'sysvmsg',
          'sysvsem',
          'sysvshm',
          'tidy',
          'tokenizer',
          'xml',
          'xmlreader',
          'xmlrpc',
          'xmlwriter',
          'xsl',
          'Zend OPcache',
          'zip',
          'zlib',
          'wordpress',
          "woocommerce",
          "acf-pro",
          "wordpress-globals",
          "wp-cli",
          vim.fn.expand('~/.config/composer/vendor/php-stubs/acf-pro-stubs/'),
          vim.fn.expand('~/.config/composer/vendor/php-stubs/woocommerce-stubs/'),
          vim.fn.expand('~/.config/composer/vendor/php-stubs/wordpress-stubs/'),
        },
      },
    },
  },
  lua_ls = {},
}

-- NOTE: PLUGINS

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

---@diagnostic disable-next-line: missing-fields
require("lazy").setup({
  spec = {
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      opts = {
        color_overrides = {
          mocha = {
            base = "#000000",
            mantle = "#000000",
            crust = "#000000",
          },
        },
        custom_highlights = function(colors)
          local u = require("catppuccin.utils.colors")
          return {
            CursorLine = {
              bg = u.vary_color({
                mocha = u.lighten(colors.surface0, 0.64, colors.base),
              }, u.darken(colors.surface0, 0.64, colors.base)),
            },
          }
        end,
      },
    },
    {
      "stevearc/oil.nvim",
      opts = {
        default_file_explorer = false,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = true,
        },
        keymaps = {
          ["<BS>"] = { "actions.parent", mode = "n" },
        },
      },
      dependencies = { "nvim-tree/nvim-web-devicons" },
      lazy = false,
    },
    {
      "folke/snacks.nvim",
      opts = {
        picker = {
          exclude = { 'node_modules', 'vendor', 'build', 'dist' },
          formatters = {
            file = {
              truncate = 10000
            }
          },
        }
      },
      keys = {
        { "<leader>sh", function() Snacks.picker.help() end,                                          desc = "[S]earch [H]elp" },
        { "<leader>sk", function() Snacks.picker.keymaps() end,                                       desc = "[S]earch [K]eymaps" },
        { "<leader>sf", function() Snacks.picker.files() end,                                         desc = "[S]earch [F]iles" },
        { "<leader>sw", function() Snacks.picker.grep_word() end,                                     desc = "[S]earch current [W]ord" },
        { "<leader>sg", function() Snacks.picker.grep() end,                                          desc = "[S]earch by [G]rep" },
        { "<leader>sd", function() Snacks.picker.diagnostics() end,                                   desc = "[S]earch [D]iagnostics" },
        { "<leader>sr", function() Snacks.picker.resume() end,                                        desc = "[S]earch [R]esume" },
        { "<leader>s.", function() Snacks.picker.recent() end,                                        desc = '[S]earch Recent Files ("." for repeat)' },
        ---@diagnostic disable-next-line: assign-type-mismatch
        { "<leader>sn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,       desc = '[S]earch [N]eovim files' },
        { "<leader>sv", function() Snacks.picker.files({ cwd = vim.fn.expand("$HOME/vimwiki") }) end, desc = 'VimWiki Files' },
        { "gd",         function() Snacks.picker.lsp_definitions() end,                               desc = "[G]oto [D]efinition" },
        { "gr",         function() Snacks.picker.lsp_references() end,                                desc = "[G]oto [R]eferences" },
        { "gI",         function() Snacks.picker.lsp_implementations() end,                           desc = "[G]oto [I]mplementation" },
        { "<leader>D",  function() Snacks.picker.lsp_type_definitions() end,                          desc = "Type [D]efinition" },
        { "<leader>ds", function() Snacks.picker.lsp_symbols() end,                                   desc = "[D]ocument [S]ymbols" },
        { "<leader>ws", function() Snacks.picker.lsp_workspace_symbols() end,                         desc = "[W]orkspace [S]ymbols" },
      }
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      main = "nvim-treesitter.configs",
      opts = {
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "ruby" },
        },
        indent = { enable = false, disable = { "ruby" } },
      },
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        { 'j-hui/fidget.nvim',       opts = {} },
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/nvim-cmp",
      },
      config = function()
        vim.diagnostic.config({
          update_in_insert = true,
        })

        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
          callback = function(event)
            local map = function(keys, func, desc, mode)
              mode = mode or "n"
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
            end
            map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
            map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
            map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if
                client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
            then
              local highlight_augroup =
                  vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
              vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
              })

              vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                callback = function(event2)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds({
                    group = "kickstart-lsp-highlight",
                    buffer = event2.buf,
                  })
                end,
              })
            end
          end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        local servers = lsp_servers
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {})
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        require("mason-lspconfig").setup({
          ensure_installed = {},
          automatic_installation = false,
          handlers = {
            function(server_name)
              local server = servers[server_name] or {}
              server.capabilities =
                  vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
              require("lspconfig")[server_name].setup(server)
            end,
          },
        })
      end,
    },
    {
      "stevearc/conform.nvim",
      opts = {
        formatters_by_ft = formatters,
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      },
    },
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        {
          "L3MON4D3/LuaSnip",
          build = (function()
            if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
              return
            end
            return "make install_jsregexp"
          end)(),
          dependencies = {
            {
              "rafamadriz/friendly-snippets",
              config = function()
                require("luasnip.loaders.from_vscode").lazy_load({
                  paths = { vim.fn.stdpath("config") .. "/snippets" },
                })
              end,
            },
          },
        },
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-path",
      },
      config = function()
        -- See `:help cmp`
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        luasnip.config.setup({})

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          ---@diagnostic disable-next-line: missing-fields
          performance = {
            fetching_timeout = 1,
          },
          completion = { completeopt = "menu,menuone,noinsert" },
          mapping = cmp.mapping.preset.insert({
            ["<C-j>"] = cmp.mapping.select_next_item(),
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<tab>"] = cmp.mapping.confirm({ select = true }),
            ["<C-x>"] = cmp.mapping.close(),
            ["<C-Space>"] = cmp.mapping.complete({}),
            ["<C-l>"] = cmp.mapping(function()
              if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              end
            end, { "i", "s" }),
            ["<C-h>"] = cmp.mapping(function()
              if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              end
            end, { "i", "s" }),
            ["<C-e>"] = cmp.mapping(function()
              if luasnip.choice_active() then
                luasnip.change_choice(1)
              end
            end, { "i", "s" }),
          }),
          sources = {
            { name = "lazydev",                group_index = 0 },
            { name = "nvim_lsp" },
            { name = 'nvim_lsp_signature_help' },
            { name = "luasnip" },
            { name = "path" },
          },
        })
      end,
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      dependencies = { "hrsh7th/nvim-cmp" },
      config = function()
        require("nvim-autopairs").setup({})
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end,
    },
    {
      "barrett-ruth/live-server.nvim",
      build = "npm i -g live-server",
      cmd = { "LiveServerStart", "LiveServerStop" },
      config = true,
    },
    {
      "kylechui/nvim-surround",
      version = "*",
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({
          surrounds = custom_surrounds,
        })
      end,
    },
    {
      "vimwiki/vimwiki",
      init = function()
        vim.g.vimwiki_list = { {
          path = "~/vimwiki/",
          syntax = "markdown",
          ext = "md",
        } }
      end,
    },
    {
      "folke/todo-comments.nvim",
      event = "VimEnter",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = { signs = false },
    },
    { 'voldikss/vim-floaterm' },
    {
      'nvim-lualine/lualine.nvim',
      opts = {
        sections = {
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { 'filesize', 'fileformat', 'filetype' },
        }
      },
      dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    {
      'lukas-reineke/indent-blankline.nvim',
      main = 'ibl',
      opts = {},
    },
    {
      "folke/flash.nvim",
      event = "VeryLazy",
      opts = function()
        vim.api.nvim_set_hl(0, 'FlashLabel', { fg = "#ffff00" })
        return {
          modes = {
            char = {
              enabled = false,
            }
          }
        }
      end,
      keys = {
        { "\\",     mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
        { "<C-\\>", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      },
    },
    { "itchyny/vim-qfedit" },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
      opts = function()
        vim.treesitter.language.register('markdown', 'vimwiki')
        return {
          file_types = { "markdown", "vimwiki" },
          render_modes = true,
          latex = { enabled = false },
        }
      end,
    },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  install = {},
  checker = { enabled = false },
})

vim.cmd.colorscheme("catppuccin")
