{ config, pkgs, ... }:

{
  # Language Server Protocol configuration for enhanced IDE integration
  # Optimized for TypeScript/JavaScript/Node.js development with Nx monorepos

  home.packages = with pkgs; [
    # TypeScript/JavaScript LSPs
    nodePackages.typescript-language-server  # Main TS/JS LSP
    nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON, ESLint LSPs

    # Additional language servers
    nodePackages.yaml-language-server  # YAML (for configs, CI/CD)
    nodePackages.bash-language-server  # Bash scripts
    marksman  # Markdown LSP

    # Linters and formatters (standalone)
    nodePackages.eslint_d  # Fast ESLint daemon
    nodePackages.prettier  # Code formatter (also in mise)

    # Development tools
    nodePackages.diagnostic-languageserver  # Generic diagnostic wrapper

    # Nix LSP
    nil  # Nix language server
    nixpkgs-fmt  # Nix formatter

    # Additional tools for monorepo development
    nodePackages.npm-check-updates  # Update package.json dependencies

    # Git configuration tools
    vale  # Prose linter for commit messages and documentation
  ];

  # Configure language servers for Neovim
  # These settings complement your LazyVim setup
  programs.neovim = {
    extraLuaConfig = ''
      -- LSP configuration for TypeScript/JavaScript development
      -- This complements your LazyVim setup in nvim/lua/plugins/

      -- Ensure LSP servers are available on PATH
      vim.env.PATH = vim.env.HOME .. "/.nix-profile/bin:" .. vim.env.PATH

      -- Additional LSP keymaps (if not already defined by LazyVim)
      local function setup_lsp_keymaps()
        vim.keymap.set('n', '<leader>li', '<cmd>LspInfo<cr>', { desc = 'LSP Info' })
        vim.keymap.set('n', '<leader>lr', '<cmd>LspRestart<cr>', { desc = 'LSP Restart' })
      end

      setup_lsp_keymaps()
    '';
  };

  # VS Code extensions for TypeScript/JavaScript development
  # (If you decide to use VS Code alongside Neovim/Zed)
  programs.vscode = {
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # TypeScript/JavaScript
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode

      # Angular (for Nx Angular projects)
      angular.ng-template

      # Useful utilities
      eamodio.gitlens
      usernamehw.errorlens

      # Nix support
      jnoortheen.nix-ide
    ];
  };

  # Zed editor LSP configuration
  # Your zed.nix already has good settings, but we ensure LSPs are available
  home.file.".config/zed/settings.json".text = builtins.toJSON {
    # LSP configuration for Zed
    lsp = {
      typescript-language-server = {
        binary = {
          path = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
          arguments = ["--stdio"];
        };
        settings = {
          typescript = {
            preferences = {
              importModuleSpecifier = "relative";
            };
            inlayHints = {
              includeInlayParameterNameHints = "all";
              includeInlayParameterNameHintsWhenArgumentMatchesName = true;
              includeInlayFunctionParameterTypeHints = true;
              includeInlayVariableTypeHints = true;
              includeInlayPropertyDeclarationTypeHints = true;
              includeInlayFunctionLikeReturnTypeHints = true;
              includeInlayEnumMemberValueHints = true;
            };
          };
        };
      };

      eslint = {
        binary = {
          path = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
          arguments = ["--stdio"];
        };
      };

      nil = {
        binary = {
          path = "${pkgs.nil}/bin/nil";
        };
      };
    };
  };

}
