-- Diagnostic display. Custom sign glyphs are defined in config/options.lua
-- (vim.fn.sign_define); `signs = true` here tells diagnostics to use them.
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  float = { border = "single" },
})
vim.o.updatetime = 250

-- Show diagnostics in a (non-focus-stealing) float on hover.
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("DiagnosticHoverFloat", { clear = true }),
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})
