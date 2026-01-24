-- map leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Helper for setting keymaps with descriptions
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- lazygit
map('n', '<leader>lg', '<cmd>LazyGit<cr>', 'LazyGit')

-- lsp trouble
map('n', '<leader>tt', '<cmd>Trouble diagnostics toggle<cr>', 'Toggle document diagnostics')
map('n', '<leader>tw', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', 'Toggle buffer diagnostics')
map('n', '<leader>tq', '<cmd>Trouble quickfix toggle<cr>', 'Toggle quickfix')
map('n', '<leader>td', '<cmd>Trouble lsp_definitions toggle<cr>', 'Toggle LSP definitions')
map('n', '<leader>tr', '<cmd>Trouble lsp_references toggle<cr>', 'Toggle LSP references')

-- telescope
map('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", 'Find files')
map('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", 'Live grep')
map('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", 'Find buffers')
map('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", 'Help tags')
map('n', '<leader>fd', "<cmd>lua require('telescope.builtin').diagnostics()<cr>", 'Find diagnostics')
map('n', '<leader>fi', "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>", 'Find implementations')
map('n', '<leader>fr', "<cmd>lua require('telescope.builtin').lsp_references()<cr>", 'Find references')
map('n', '<leader>fs', "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", 'Document symbols')

-- Quickfix
map('n', '<leader>qn', '<cmd>:cn<CR>', 'Next quickfix')
map('n', '<leader>qp', '<cmd>:cp<CR>', 'Previous quickfix')

-- Harpoon
map('n', '<leader>ha', '<cmd>lua require("harpoon.mark").add_file()<cr>', 'Add file to harpoon')
map('n', '<C-e>', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', 'Harpoon menu')
map('n', '<C-h>', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>', 'Harpoon file 1')
map('n', '<C-j>', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>', 'Harpoon file 2')
map('n', '<C-k>', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>', 'Harpoon file 3')
map('n', '<C-l>', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>', 'Harpoon file 4')

-- Clang
map('n', '<leader>he', '<cmd>ClangdSwitchSourceHeader<cr>', 'Switch header/source')

-- Oil
map('n', '<leader>oo', '<cmd>Oil<cr>', 'Open Oil file explorer')
