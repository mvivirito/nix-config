-- LSP setup using Neovim's native vim.lsp.config / vim.lsp.enable API (0.11+).
--
-- The old `require('lspconfig').<server>.setup{}` "framework" is deprecated and
-- prints a multi-line warning + traceback at startup (that was the source of the
-- "press ENTER to continue" prompt). nvim-lspconfig still ships the per-server
-- defaults (cmd, root_markers, filetypes) under its `lsp/` runtime dir, so we
-- only need to layer our overrides + completion capabilities on top.

local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Apply blink's completion capabilities to every server.
vim.lsp.config('*', {
  capabilities = capabilities,
})

-- Per-server overrides (merged over nvim-lspconfig's shipped defaults).
vim.lsp.config('nixd', {
  settings = {
    nixd = {
      nixpkgs = { expr = "import <nixpkgs> { }" },
    },
  },
})

vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = { typeCheckingMode = "off" },
    },
  },
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

-- Enable only the servers we actually ship binaries for (extraPackages).
-- Dropped: buf_ls, ansiblels, vimls (no binary was installed -> dead configs).
vim.lsp.enable({
  'clangd',
  'cmake',
  'dockerls',
  'nixd',
  'pyright',
  'ts_ls',
  'lua_ls',
})

-- Global diagnostic keymaps (modern vim.diagnostic.jump API, replaces the
-- deprecated goto_prev/goto_next).
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
vim.keymap.set('n', '<leader>dn', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Previous diagnostic' })
vim.keymap.set('n', '<leader>dp', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

-- Buffer-local keymaps, set once a server attaches.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    local function opts(desc)
      return { buffer = ev.buf, desc = desc }
    end

    -- Navigation
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts('Go to declaration'))
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts('Go to definition'))
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts('Go to implementation'))
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts('Go to references'))
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts('Type definition'))

    -- Documentation
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts('Hover documentation'))
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts('Signature help'))

    -- Workspace
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts('Add workspace folder'))
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts('Remove workspace folder'))
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts('List workspace folders'))

    -- Refactoring
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts('Rename symbol'))
    -- nvim-code-action-menu was archived; 0.11's built-in code_action UI replaces it.
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts('Code action'))
    vim.keymap.set('n', '<leader>fm', function()
      vim.lsp.buf.format { async = true }
    end, opts('Format buffer'))
  end,
})
