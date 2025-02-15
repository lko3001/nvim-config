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
vim.keymap.set("n", "<leader>cn", vim.cmd.cnext)
vim.keymap.set("n", "<leader>cp", vim.cmd.cprevious)
vim.keymap.set("n", "<C-CR>", vim.cmd.Run)

-- NOTE: FUNCTIONS

vim.api.nvim_create_user_command("OilToggleFloat", function()
  local oil = require("oil")
  oil.toggle_float(oil.get_current_dir())
end, { desc = "Oil toggle float" })

vim.api.nvim_create_user_command("FormatDisable", function()
  require("conform").setup({ format_on_save = false })
end, { desc = "Disable formatting" })

vim.api.nvim_create_user_command("FormatEnable", function()
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

  table.insert(lines, ".fs-" .. font_size_px .. "{")

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
  html = { "prettierd", stop_after_first = true },
  css = { "prettierd", stop_after_first = true },
  javascript = { "prettierd", stop_after_first = true },
  typescript = { "prettierd", stop_after_first = true },
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
  tailwindcss = {},
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
      },
    },
  },
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
                mocha = u.lighten(colors.surface0, 0.30, colors.base),
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
      "nvim-telescope/telescope.nvim",
      event = "VimEnter",
      branch = "0.1.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          build = "make",
          cond = function()
            return vim.fn.executable("make") == 1
          end,
        },
        { "nvim-telescope/telescope-ui-select.nvim" },
        { "nvim-tree/nvim-web-devicons",            enabled = vim.g.have_nerd_font },
      },
      config = function()
        require("telescope").setup({
          defaults = {
            file_ignore_patterns = { "node_modules", "vendor", "dist", "build" },
          },
          extensions = {
            ["ui-select"] = {
              require("telescope.themes").get_dropdown(),
            },
          },
        })

        pcall(require("telescope").load_extension, "fzf")
        pcall(require("telescope").load_extension, "ui-select")

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
        vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
        vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
        vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "[S]earch [F]iles" })
        vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
        vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
        vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
        vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
        vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
        vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
        vim.keymap.set("n", "<leader>sn", function()
          builtin.find_files({ cwd = vim.fn.stdpath("config") })
        end, { desc = "[S]earch [N]eovim files" })
        vim.keymap.set("n", "<leader>sv", function()
          builtin.find_files({
            cwd = vim.fn.expand("$HOME/vimwiki"),
            prompt_title = "VimWiki Files",
          })
        end, { desc = "[S]earch [V]imWiki" })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      main = "nvim-treesitter.configs",
      opts = {
        ensure_installed = {},
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "ruby" },
        },
        indent = { enable = true, disable = { "ruby" } },
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
            map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
            map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
            map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
            map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
            map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
            map(
              "<leader>ws",
              require("telescope.builtin").lsp_dynamic_workspace_symbols,
              "[W]orkspace [S]ymbols"
            )
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

            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
              map("<leader>th", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
              end, "[T]oggle Inlay [H]ints")
            end
          end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities =
            vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        local servers = lsp_servers
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {})
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        require("mason-lspconfig").setup({
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
          completion = { completeopt = "menu,menuone,noinsert" },
          mapping = cmp.mapping.preset.insert({
            ["<C-j>"] = cmp.mapping.select_next_item(),
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<tab>"] = cmp.mapping.confirm({ select = true }),
            ["<C-x>"] = cmp.mapping.close({ select = true }),
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
            { name = "lazydev", group_index = 0 },
            { name = "nvim_lsp" },
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
  },
  install = {},
  checker = { enabled = true },
})

vim.cmd.colorscheme("catppuccin")
