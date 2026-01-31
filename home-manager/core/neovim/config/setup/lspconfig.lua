local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- C/C++
require'lspconfig'.clangd.setup{capabilities=capabilities}

-- Rust (use rustaceanvim for full setup, or uncomment below for basic)
-- require'lspconfig'.rust_analyzer.setup{capabilities=capabilities}

-- Build tools
require'lspconfig'.cmake.setup{capabilities=capabilities}

-- Docker
require'lspconfig'.dockerls.setup{capabilities=capabilities}

-- Nix
require'lspconfig'.nixd.setup{
  capabilities=capabilities,
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
    },
  },
}

-- Protobuf
require'lspconfig'.bufls.setup{capabilities=capabilities}

-- Ansible
require'lspconfig'.ansiblels.setup{}

-- Python
require'lspconfig'.pyright.setup{
  capabilities=capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off",
      }
    }
  }
}

-- Vim
require'lspconfig'.vimls.setup{}

-- TypeScript/JavaScript
require'lspconfig'.ts_ls.setup{
  capabilities=capabilities,
}

-- Lua (for neovim config editing)
require'lspconfig'.lua_ls.setup{
  capabilities=capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Helper for buffer-local mappings with descriptions
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
    vim.keymap.set('n', '<leader>ca', '<cmd>CodeActionMenu<cr>', opts('Code action'))
    vim.keymap.set('n', '<leader>fm', function()
      vim.lsp.buf.format { async = true }
    end, opts('Format buffer'))
  end,
})
