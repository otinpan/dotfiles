-- lsp.lua
-- Target: "williamboman/mason.nvim"
local util = require("utils")
-- Key bindings
util.map("n", "gr", "<cmd>Telescope lsp_references<CR>")
util.map("n", "gd", "<cmd>Telescope lsp_definitions<CR>")
util.map("n", "gc", "<cmd>Telescope lsp_declarations<CR>")
util.map("n", "gi", "<cmd>Telescope lsp_implementations<CR>")
util.map("n", "gy", "<cmd>Telescope lsp_type_definitions<CR>")
util.map("n", "gD", "<cmd>Telescope diagnostics<CR>")
util.map("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
util.map("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
util.map("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
util.map("n", "gc", "<cmd>lua vim.lsp.buf.code_action()<CR>")

-- LSP manager
require("mason").setup({
  -- The directory in which to install packages.
  install_root_dir = vim.fn.stdpath("data") .. "mason",

  -- Where Mason should put its bin location in your PATH. Can be one of:
  -- - "prepend" (default, Mason's bin location is put first in PATH)
  -- - "append" (Mason's bin location is put at the end of PATH)
  -- - "skip" (doesn't modify PATH)
  ---@type '"prepend"' | '"append"' | '"skip"'
  PATH = "append",

  -- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
  -- debugging issues with package installations.
  log_level = vim.log.levels.INFO,

  -- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
  -- packages that are requested to be installed will be put in a queue.
  max_concurrent_installers = 4,

  -- [Advanced setting]
  -- The registries to source packages from. Accepts multiple entries. Should a package with the same name exist in
  -- multiple registries, the registry listed first will be used.
  registries = {
    "github:mason-org/mason-registry",
  },

  -- The provider implementations to use for resolving supplementary package metadata (e.g., all available versions).
  -- Accepts multiple entries, where later entries will be used as fallback should prior providers fail.
  -- Builtin providers are:
  --   - mason.providers.registry-api  - uses the https://api.mason-registry.dev API
  --   - mason.providers.client        - uses only client-side tooling to resolve metadata
  providers = {
    "mason.providers.registry-api",
    "mason.providers.client",
  },

  github = {
    -- The template URL to use when downloading assets from GitHub.
    -- The placeholders are the following (in order):
    -- 1. The repository (e.g. "rust-lang/rust-analyzer")
    -- 2. The release version (e.g. "v0.3.0")
    -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
    download_url_template = "https://github.com/%s/releases/download/%s/%s",
  },

  pip = {
    -- Whether to upgrade pip to the latest version in the virtual environment before installing packages.
    upgrade_pip = false,

    -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
    -- and is not recommended.
    --
    -- Example: { "--proxy", "https://proxyserver" }
    install_args = {},
  },

  ui = {
    -- Whether to automatically check for new versions when opening the :Mason window.
    check_outdated_packages_on_open = true,

    -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
    border = "none",

    -- Width of the window. Accepts:
    -- - Integer greater than 1 for fixed width.
    -- - Float in the range of 0-1 for a percentage of screen width.
    width = 0.8,

    -- Height of the window. Accepts:
    -- - Integer greater than 1 for fixed height.
    -- - Float in the range of 0-1 for a percentage of screen height.
    height = 0.9,

    icons = {

      -- The list icon to use for installed packages.
      package_installed = "✓",
      -- The list icon to use for packages that are installing, or queued for installation.
      package_pending = "➜",
      -- The list icon to use for packages that are not installed.
      package_uninstalled = "◍",
    },

    keymaps = {
      -- Keymap to expand a package
      toggle_package_expand = "<CR>",
      -- Keymap to install the package under the current cursor position
      install_package = "i",
      -- Keymap to reinstall/update the package under the current cursor position
      update_package = "u",
      -- Keymap to check for new version for the package under the current cursor position
      check_package_version = "c",
      -- Keymap to update all installed packages
      update_all_packages = "U",
      -- Keymap to check which installed packages are outdated
      check_outdated_packages = "C",
      -- Keymap to uninstall a package
      uninstall_package = "X",
      -- Keymap to cancel a package installation
      cancel_installation = "<C-c>",
      -- Keymap to apply language filter
      apply_language_filter = "<C-f>",
    },
  },
})

vim.filetype.add {
  extension = {
    inc = 'c'
  }
}

local servers = {
  clangd = {
    offset_encoding = 'utf-8'
  },
  tsserver = {},
  rust_analyzer = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  pylsp = {
    pylsp = {
      plugins = {
        pycodestyle = {
          enabled = true,
          maxLineLength = 100,
        },
        mccabe = { enabled = false },
        pyflakes = { enabled = false },
      }
    }
  }
}
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local function on_attach(client, bufnr)
  if client.server_capabilities and client.server_capabilities.semanticTokensProvider then
    pcall(vim.lsp.semantic_tokens.start, bufnr, client.id)
  end
end
require("mason-lspconfig").setup {
  ensure_installed = vim.tbl_keys(servers),
  -- Avoid vim.lsp.enable() (requires Nvim 0.11+)
  automatic_enable = false,
}

local lspconfig = require("lspconfig")

local mason_lspconfig = require("mason-lspconfig")
if mason_lspconfig.setup_handlers then
  mason_lspconfig.setup_handlers({
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = servers[server_name],
      })
    end,
  })
else
  -- Fallback for older mason-lspconfig
  for server_name, _ in pairs(servers) do
    lspconfig[server_name].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    })
  end
end

-- LSP handlers
vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })
