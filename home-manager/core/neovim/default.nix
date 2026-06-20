{
  pkgs,
  lib,
  ...
}: let
  fromGitHub = rev: ref: repo:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = ref;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        ref = ref;
        rev = rev;
      };
    };
in {
  home.packages = with pkgs; [
    vscode-extensions.vadimcn.vscode-lldb
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    vscode-extensions.ms-vscode.cpptools
  ];
  programs = {
    neovim = {
      plugins = [
        ## Theme - Tokyo Night ("night"), to match the fixed Tokyo Night desktop
        ## (kitty/alacritty/GTK/Qt/console are all #1a1b26 "night").
        {
          plugin = pkgs.vimPlugins.tokyonight-nvim;
          config = ''
            require("tokyonight").setup({
              style = "night",
            })
            vim.cmd.colorscheme("tokyonight")
          '';
          type = "lua";
        }

        ## Treesitter
        {
          plugin = pkgs.vimPlugins.nvim-treesitter;
          config = builtins.readFile config/setup/treesitter.lua;
          type = "lua";
        }
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        pkgs.vimPlugins.nvim-treesitter-textobjects
        {
          plugin = pkgs.vimPlugins.nvim-lspconfig;
          config = builtins.readFile config/setup/lspconfig.lua;
          type = "lua";
        }

        pkgs.vimPlugins.plenary-nvim

        ## Telescope
        {
          plugin = pkgs.vimPlugins.telescope-nvim;
          config = builtins.readFile config/setup/telescope.lua;
          type = "lua";
        }
        pkgs.vimPlugins.telescope-fzf-native-nvim
        {
          plugin = pkgs.vimPlugins.harpoon2;
          config = "require('harpoon'):setup()";
          type = "lua";
        }

        ## Completion - blink.cmp (replaces nvim-cmp + cmp-* sources + lspkind)
        {
          plugin = pkgs.vimPlugins.blink-cmp;
          config = builtins.readFile config/setup/blink.lua;
          type = "lua";
        }
        pkgs.vimPlugins.friendly-snippets

        ## Tpope
        pkgs.vimPlugins.vim-surround
        pkgs.vimPlugins.vim-sleuth
        pkgs.vimPlugins.vim-repeat

        ## QoL
        pkgs.vimPlugins.nvim-web-devicons
        pkgs.vimPlugins.lazygit-nvim
        {
          plugin = pkgs.vimPlugins.rainbow-delimiters-nvim;
          config = "require('rainbow-delimiters.setup').setup({})";
          type = "lua";
        }
        ## AI - Claude Code IDE integration (agentic; drives your existing claude CLI/auth)
        {
          plugin = pkgs.vimPlugins.claudecode-nvim;
          config = ''
            require("claudecode").setup({
              terminal = { provider = "native" }, -- built-in terminal, no snacks.nvim
            })
            local map = vim.keymap.set
            map("n", "<leader>ac", "<cmd>ClaudeCode<cr>",          { desc = "Toggle Claude Code" })
            map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>",     { desc = "Focus Claude" })
            map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",     { desc = "Add current buffer to Claude" })
            map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>",      { desc = "Send selection to Claude" })
            map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",{ desc = "Accept Claude diff" })
            map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",  { desc = "Reject Claude diff" })

            -- Keyboard window nav that also works from INSIDE the Claude terminal.
            -- In terminal mode we leave terminal-mode first (<C-\><C-n>, Claude keeps
            -- running), then move. Alt-l onto a terminal starts typing immediately.
            -- Avoided <C-w>/<C-h> on purpose: Claude's TUI uses them (delete-word / BS).
            map("t", "<M-h>", [[<C-\><C-n><C-w>h]], { desc = "Term -> window left" })
            map("t", "<M-l>", [[<C-\><C-n><C-w>l]], { desc = "Term -> window right" })
            map("n", "<M-h>", "<C-w>h", { desc = "Window left" })
            map("n", "<M-l>", function()
              vim.cmd.wincmd("l")
              if vim.bo.buftype == "terminal" then vim.cmd.startinsert() end
            end, { desc = "Window right (enter terminal)" })
          '';
          type = "lua";
        }
        {
          plugin = fromGitHub "6218a401824c5733ac50b264991b62d064e85ab2" "main" "m-demare/hlargs.nvim";
          config = "require('hlargs').setup()";
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.oil-nvim;
          config = "require('oil').setup()";
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.fidget-nvim;
          config = "require('fidget').setup{}";
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.trouble-nvim;
          config = "require('trouble').setup {}";
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.luasnip;
          config = builtins.readFile config/setup/luasnip.lua;
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.comment-nvim;
          config = "require('Comment').setup()";
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.gitsigns-nvim;
          config = "require('gitsigns').setup()";
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.lualine-nvim;
          config = ''
            require('lualine').setup {
                options = {
                    theme = 'tokyonight',
                }
            }
          '';
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.noice-nvim;
          config = ''
            require("noice").setup({
              lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                  ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                  ["vim.lsp.util.stylize_markdown"] = true,
                  ["cmp.entry.get_documentation"] = true,
                },
              },
              -- you can enable a preset for easier configuration
              presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false, -- add a border to hover docs and signature help
              },
            })
          '';
          type = "lua";
        }

        ## which-key for discoverability
        {
          plugin = pkgs.vimPlugins.which-key-nvim;
          config = ''
            local wk = require("which-key")
            wk.setup({
              plugins = {
                marks = true,
                registers = true,
                spelling = { enabled = false },
              },
              win = {
                border = "single",
              },
            })
            wk.add({
              { "<leader>a", group = "AI / Claude" },
              { "<leader>f", group = "Find (Telescope)" },
              { "<leader>t", group = "Trouble" },
              { "<leader>d", group = "Diagnostics" },
              { "<leader>l", group = "LSP" },
              { "<leader>g", group = "Git" },
              { "<leader>q", group = "Quickfix" },
              { "<leader>w", group = "Workspace" },
              { "<leader>o", group = "Oil" },
              { "<leader>p", group = "Param swap" },
              { "<leader>c", group = "Code Action" },
              { "<leader>r", group = "Rename" },
              { "<leader>h", group = "Harpoon / Header" },
            })
          '';
          type = "lua";
        }

        ## Additional QoL plugins
        {
          plugin = pkgs.vimPlugins.indent-blankline-nvim;
          config = ''
            require("ibl").setup({
              indent = { char = "│" },
              scope = { enabled = true },
            })
          '';
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.nvim-autopairs;
          config = ''
            require("nvim-autopairs").setup({
              check_ts = true,
            })
            -- Completion-accept bracket insertion is handled by blink.cmp's
            -- completion.accept.auto_brackets (see config/setup/blink.lua).
          '';
          type = "lua";
        }
        {
          plugin = pkgs.vimPlugins.toggleterm-nvim;
          config = ''
            require("toggleterm").setup({
              open_mapping = [[<C-\>]],
              direction = "float",
              float_opts = {
                border = "curved",
              },
            })
          '';
          type = "lua";
        }

        ## Debugging
#        pkgs.vimPlugins.nvim-dap-ui
#        pkgs.vimPlugins.nvim-dap-virtual-text
#        {
#          plugin = pkgs.vimPlugins.nvim-dap;
#          config = builtins.readFile config/setup/dap.lua;
#          type = "lua";
#        }
      ];

      initLua = ''
        ${builtins.readFile config/mappings.lua}
        ${builtins.readFile config/options.lua}
        ${builtins.readFile config/setup/diagnostic.lua}
      '';
      enable = true;
      viAlias = true;
      vimAlias = true;

      extraPackages = with pkgs; [
        # LSP servers
        typescript-language-server
        lua-language-server
        nixd
        pyright
        clang-tools # For clangd
        cmake-language-server
        dockerfile-language-server
      ];
    };
  };
}
