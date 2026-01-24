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
    vscode-extensions.ms-vscode.cpptools
    vscode-extensions.vadimcn.vscode-lldb
  ];
  programs = {
    neovim = {
      plugins = [
        ## Theme
        {
          plugin = pkgs.vimPlugins.tokyonight-nvim;
          config = "vim.cmd[[colorscheme tokyonight-night]]";
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
        pkgs.vimPlugins.harpoon

        ## cmp
        {
          plugin = pkgs.vimPlugins.nvim-cmp;
          config = builtins.readFile config/setup/cmp.lua;
          type = "lua";
        }
        pkgs.vimPlugins.cmp-nvim-lsp
        pkgs.vimPlugins.cmp-buffer
        pkgs.vimPlugins.cmp-cmdline
        pkgs.vimPlugins.cmp_luasnip

        ## Tpope
        pkgs.vimPlugins.vim-surround
        pkgs.vimPlugins.vim-sleuth
        pkgs.vimPlugins.vim-repeat
        {
          plugin = fromGitHub "afd76df166ed0f223ede1071e0cfde8075cc4a24" "main" "TabbyML/vim-tabby";
          config = ''
            vim.cmd([[
              let g:tabby_keybinding_accept = '<Tab>'
            ]])
          '';
          type = "lua";
        }

        ## QoL
        pkgs.vimPlugins.lspkind-nvim
        pkgs.vimPlugins.rainbow
        pkgs.vimPlugins.nvim-web-devicons
        pkgs.vimPlugins.lazygit-nvim
        pkgs.vimPlugins.nvim-code-action-menu
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
              { "<leader>f", group = "Find (Telescope)" },
              { "<leader>t", group = "Trouble" },
              { "<leader>d", group = "Diagnostics" },
              { "<leader>l", group = "LSP" },
              { "<leader>g", group = "Git" },
              { "<leader>q", group = "Quickfix" },
              { "<leader>w", group = "Workspace" },
              { "<leader>o", group = "Oil" },
              { "<leader>n", group = "Neorg" },
              { "<leader>c", group = "Code Action" },
              { "<leader>r", group = "Rename" },
              { "<leader>h", group = "Header" },
              { "<leader>s", group = "Harpoon mark" },
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
            -- integrate with cmp
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
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
        nodePackages.typescript-language-server
        lua-language-server
        nil # Already have nil_ls configured
        pyright
        clang-tools # For clangd
        cmake-language-server
        dockerfile-language-server-nodejs
        vimPlugins.vim-vsnip # For snippets
      ];
    };
  };
}
