-- blink.cmp: fast, batteries-included completion.
-- Replaces nvim-cmp + cmp-nvim-lsp + cmp-buffer + cmp-cmdline + cmp_luasnip + lspkind.
--
-- Snippet expand/jump (<C-k>/<C-j>) and choice (<C-l>) are owned by luasnip
-- (see luasnip.lua), so we deliberately do NOT bind them here. Doc-scroll lives
-- on <C-f>/<C-b> to stay clear of those. Everything else mirrors the old cmp keys.

require('blink.cmp').setup({
  keymap = {
    preset = 'none',
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'hide', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
  },

  -- Use luasnip as the snippet engine (keeps all the custom snippets working).
  snippets = { preset = 'luasnip' },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    menu = {
      border = 'single',
      draw = { treesitter = { 'lsp' } },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = { border = 'single' },
    },
    -- Inline preview of the selected item (the old cmp `ghost_text`).
    ghost_text = { enabled = true },
    -- Insert () after functions on accept (replaces the old cmp+autopairs hook).
    accept = { auto_brackets = { enabled = true } },
  },

  signature = {
    enabled = true,
    window = { border = 'single' },
  },

  -- Native cmdline completion for ':' and '/' (replaces cmp.setup.cmdline).
  cmdline = {
    enabled = true,
    keymap = { preset = 'cmdline' },
    completion = { menu = { auto_show = true } },
  },

  fuzzy = {
    implementation = 'prefer_rust_with_warning',
  },
})
