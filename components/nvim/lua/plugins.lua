local util = require("utils")
-- Automatically install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = vim.fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer, close and reopen Neovim...")
  vim.cmd.packadd("packer.nvim")
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return error()
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

-- Install your plugins here
packer.startup(function()
  use({ "wbthomason/packer.nvim" })
  use({ "nvim-lua/plenary.nvim" }) -- Common utilities

  -- Colorschemes
  use({ "cocopon/iceberg.vim" }) -- Color scheme
  use({
    "Mofiqul/vscode.nvim",
    config = function()
      require("vscode").setup({
        style = "dark",
        transparent = false,
        italic_comments = true,
        disable_nvimtree_bg = true,
      })
    end
  })

  -- Status Line
  use({
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "vscode",
          section_separators = "",
          component_separators = "",
        }
      })
    end
  }) -- Statusline
  use({
    "windwp/nvim-autopairs",
    run = util.safe_require("nvim-autopairs", {})
  }) -- Autopairs, integrates with both cmp and treesitter
  use({
    "akinsho/bufferline.nvim",
    run = util.safe_require("bufferline", {})
  })

  -- Completion Plugins
  use({ "hrsh7th/nvim-cmp" })   -- The completion plugin
  use({ "hrsh7th/cmp-buffer" }) -- buffer completions
  use({ "hrsh7th/cmp-path" })   -- path completions
  use({ "hrsh7th/cmp-nvim-lsp" })
  use({ "onsails/lspkind-nvim" })

  -- Snippets
  use({ "hrsh7th/vim-vsnip" }) --snippet engine

  -- Keymap helper
  use({
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({})
    end
  })

  -- LSP
  use({ "neovim/nvim-lspconfig" })             -- enable LSP
  use({ 
    "williamboman/mason.nvim" 
  })           -- simple to use language server installer
  use({ 
    "williamboman/mason-lspconfig.nvim"
  }) -- bridge between mason and nvim-lspconfig
  -- use{ "glepnir/lspsaga.nvim", run = require("lspsaga").setup() } -- LSP UIs

  -- Linter & Formatter
  use({ "mfussenegger/nvim-lint" }) -- for linters
  use({ "stevearc/conform.nvim" })  -- for formatters

  -- Fuzz Finder
  use({ "nvim-telescope/telescope.nvim" })
  use({ "nvim-telescope/telescope-file-browser.nvim" })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    config = function()
      local ok, treesitter = pcall(require, "nvim-treesitter.configs")
      if ok then
        treesitter.setup({
          highlight = {
            enabled = true,
            disable = {
              'lua',
              'toml',
              'rust',
            }
          },
          indent = {
            enabled = true,
          }
        })
        -- see https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufAdd', 'BufNew', 'BufNewFile', 'BufWinEnter' }, {
          group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
          callback = function()
            vim.opt.foldmethod = 'expr'
            vim.opt.foldexpr   = 'nvim_treesitter#foldexpr()'
          end
        })
      end
    end,
    -- run = require('nvim-treesitter.install').update({ with_sync = true })
  })

  -- Explorer
  use({
    "nvim-tree/nvim-tree.lua",
    requires = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require("nvim-tree").setup({
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        view = {
          width = 30,
          side = 'left',
        },
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')
          local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- keymaps can go here
          vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
          vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
          vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))
          vim.keymap.set('n', 'u', api.tree.change_root_to_parent, opts('Up'))
          -- This is the important part for your question
          api.events.subscribe(api.events.Event.TreeOpen, function()
            api.tree.find_file({
              open = true,
              focus = true,
            })
          end)
        end,
      })
    end,
    run = util.map("n", "<Leader>e", ":NvimTreeToggle<CR>", { desc = "Open nvim-tree panel on left side" })
  })
  -- Autoclose command
  vim.api.nvim_create_autocmd("BufEnter", {
    nested = true,
    callback = function()
      if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
        vim.cmd "quit"
      end
    end
  })

  use({
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup()
    end,
    run = util.map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  })
  -- Git
  use({
    "akinsho/git-conflict.nvim",
    tag = "*",
    config = util.safe_require("git-conflict", {}),
  })
  use({
    "lewis6991/gitsigns.nvim",
    config = util.safe_require("gitsigns"),
    run = vim.cmd([[cab gs Gitsigns]])
  })

  -- Navigation
  use({
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function()
      -- require("leap").create_default_mappings()
      vim.keymap.set({ "n", "x", "o" }, "s",  "<Plug>(leap-forward)")
      vim.keymap.set({ "n", "x", "o" }, "S",  "<Plug>(leap-backward)")
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-cross-window)")
    end
  })

  -- Others
  use({ "nvim-tree/nvim-web-devicons", config = util.safe_require("nvim-web-devicons", { default = true, strict = true }) })
  use({ "notjedi/nvim-rooter.lua", run = util.safe_require("nvim-rooter", {}) })
  use({ "simeji/winresizer", config = util.safe_require("winresizer", {}) })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
