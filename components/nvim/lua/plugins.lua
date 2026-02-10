local util = require("utils")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-lua/plenary.nvim" }, -- Common utilities

  -- Colorschemes
  { "cocopon/iceberg.vim" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          nvimtree = true,
          treesitter = true,
          gitsigns = true,
          which_key = true,
          telescope = true,
        },
      })
    end,
  },

  {
    "goolord/alpha-nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local ok, alpha = pcall(require, "alpha")
      if not ok then
        return
      end
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        "  _   _   _   _   _   _   _   _   _  ",
        " / \\ / \\ / \\ / \\ / \\ / \\ / \\ / \\ / \\ ",
        "( N | e | o | v | i | m | : | V | S )",
        " \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ ",
        "   |  craft.  focus.  iterate.  |   ",
      }
      dashboard.section.header.opts.hl = "Type"
      dashboard.section.buttons.val = {
        dashboard.button("e", "New file", "<cmd>ene <BAR> startinsert <CR>"),
        dashboard.button("f", "Find file", "<cmd>Telescope find_files<CR>"),
        dashboard.button("r", "Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "Live grep", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("p", "Projects", "<cmd>Telescope projects<CR>"),
        dashboard.button("c", "Config", "<cmd>edit ~/.config/nvim/init.lua<CR>"),
        dashboard.button("q", "Quit", "<cmd>qa<CR>"),
      }
      dashboard.section.buttons.opts = {
        spacing = 1,
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "Keyword"
        button.opts.hl_shortcut = "Identifier"
      end
      dashboard.section.footer.val = {
        "Ready when you are.",
      }
      dashboard.section.footer.opts.hl = "Comment"
      dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 1 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      }
      alpha.setup(dashboard.config)
    end,
  },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          section_separators = "",
          component_separators = "",
        },
      })
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      util.safe_require("nvim-autopairs", {})
    end,
  },
  {
    "akinsho/bufferline.nvim",
    config = function()
      util.safe_require("bufferline", {})
    end,
  },

  -- Completion Plugins
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "onsails/lspkind-nvim" },

  -- Snippets
  { "hrsh7th/vim-vsnip" },

  -- Keymap helper
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({})
    end,
  },

  {
    "chentoast/marks.nvim",
    config = function()
      require("marks").setup({})
    end,
  },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Linter & Formatter
  { "mfussenegger/nvim-lint" },
  { "stevearc/conform.nvim" },

  -- Fuzz Finder
  { "nvim-telescope/telescope.nvim" },
  { "nvim-telescope/telescope-file-browser.nvim" },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      local ok, treesitter = pcall(require, "nvim-treesitter.configs")
      if ok then
        treesitter.setup({
          highlight = {
            enabled = true,
            disable = {
              "lua",
              "toml",
              "rust",
            },
          },
          indent = {
            enabled = true,
          },
        })
        vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufNew", "BufNewFile", "BufWinEnter" }, {
          group = vim.api.nvim_create_augroup("TS_FOLD_WORKAROUND", {}),
          callback = function()
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
          end,
        })
      end
    end,
  },

  -- Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        view = {
          width = 30,
          side = "left",
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
          vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
          vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("CD"))
          vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts("Up"))
          api.events.subscribe(api.events.Event.TreeOpen, function()
            api.tree.find_file({
              open = true,
              focus = true,
            })
          end)
        end,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        nested = true,
        callback = function()
          if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
            vim.cmd("quit")
          end
        end,
      })
    end,
    init = function()
      util.map("n", "<Leader>e", ":NvimTreeToggle<CR>", { desc = "Open nvim-tree panel on left side" })
    end,
  },

  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup()
    end,
    init = function()
      util.map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end,
  },

  -- Git
  {
    "akinsho/git-conflict.nvim",
    config = function()
      util.safe_require("git-conflict", {})
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      util.safe_require("gitsigns")
      vim.cmd([[cab gs Gitsigns]])
    end,
  },

  -- Navigation
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function()
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-cross-window)")
    end,
  },

  -- Others
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      util.safe_require("nvim-web-devicons", { default = true, strict = true })
    end,
  },
  {
    "notjedi/nvim-rooter.lua",
    config = function()
      util.safe_require("nvim-rooter", {})
    end,
  },
  {
    "simeji/winresizer",
    config = function()
      util.safe_require("winresizer", {})
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = {
          border = "rounded",
        },
      })
    end,
    init = function()
      util.map("n", "<Leader>t", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
    end,
  },
})
