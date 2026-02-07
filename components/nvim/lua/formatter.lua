local status_lint, nvim_lint = pcall(require, "lint")
local status_conform, conform = pcall(require, "conform")
local status_registry, mason_registry = pcall(require, "mason-registry")
if not status_lint or not status_conform or not status_registry then
  return
end

-- Function to get all installed tools by Mason
local function get_mason_tools()
  local tools = {}
  for _, tool in ipairs(mason_registry.get_installed_packages()) do
    local name = tool.spec.name
    local categories = tool.spec.categories
    for _, category in ipairs(categories) do
      if not tools[category] then
        tools[category] = {}
      end
      table.insert(tools[category], name)
    end
  end
  return tools
end

-- Get installed tools
local mason_tools = get_mason_tools()

-- Ensure cpplint is available for C/C++ linting.
do
  local name = "cpplint"
  local ok, pkg = pcall(mason_registry.get_package, name)
  if ok and not pkg:is_installed() then
    pkg:install()
  end
end

-- Set up nvim-lint
nvim_lint.linters_by_ft = {}

for _, linter in ipairs(mason_tools["linter"] or {}) do
  local linter_filetypes = nvim_lint.linters[linter].filetypes
  if linter_filetypes then
    for _, ft in ipairs(linter_filetypes) do
      if not nvim_lint.linters_by_ft[ft] then
        nvim_lint.linters_by_ft[ft] = {}
      end
      table.insert(nvim_lint.linters_by_ft[ft], linter)
    end
  end
end

-- Fallback: make sure cpplint runs for C/C++ even if registry categories differ.
if nvim_lint.linters.cpplint then
  nvim_lint.linters_by_ft.c = nvim_lint.linters_by_ft.c or {}
  table.insert(nvim_lint.linters_by_ft.c, "cpplint")
  nvim_lint.linters_by_ft.cpp = nvim_lint.linters_by_ft.cpp or {}
  table.insert(nvim_lint.linters_by_ft.cpp, "cpplint")
end

-- Set up conform.nvim

local formatters_by_ft = {}
for _, formatter in ipairs(mason_tools["formatter"] or {}) do
  local formatter_filetypes = conform.formatters[formatter].filetypes
  if formatter_filetypes then
    for _, ft in ipairs(formatter_filetypes) do
      if not formatters_by_ft[ft] then
        formatters_by_ft[ft] = {}
      end
      table.insert(formatters_by_ft[ft], formatter)
    end
  end
end


conform.setup({
  formatters_by_ft = formatters_by_ft
})

-- Define keymaps
vim.keymap.set('n', 'gf', function()
  conform.format({
    async = true,
    lsp_fallback = true,
    bufnr = vim.api.nvim_get_current_buf(),
  })
end, { noremap = true, silent = true, desc = "Format current buffer" })

vim.keymap.set('n', 'gl', function()
  require("lint").try_lint()
end, { noremap = true, silent = true, desc = "Lint current buffer" })

-- Set up autoformatting and auto-linting on save
-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--   callback = function()
--     conform.format({ async = true, lsp_fallback = true })
--     lint()
--   end,
-- })
--
-- Optional: Set up format on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*",
--   callback = function(args)
--     conform.format({ bufnr = args.buf })
--   end,
-- })
