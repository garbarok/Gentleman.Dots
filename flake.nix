{
  description = "Gentleman: Single config for all systems in one go";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";  # Home Manager repository
      inputs.nixpkgs.follows = "nixpkgs";  # Follow nixpkgs input
    };
    flake-utils.url = "github:numtide/flake-utils";  # Flake utilities

    # Secrets management with sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, flake-utils, sops-nix, ... }:
    let
      # Support macOS systems only
      supportedSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      
      # Function to create home configuration for a specific system
      mkHomeConfiguration = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (final: prev: {
                fish = prev.fish.overrideAttrs (oldAttrs: {
                  doCheck = false;
                });
              })
            ];
          };
          
          unstablePkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          
          # Pass extraSpecialArgs to make unstablePkgs and other inputs available in modules
          extraSpecialArgs = {
            inherit unstablePkgs;
            inherit (sops-nix) homeManagerModules;
          };
          
          modules = [
            # Secrets management (must be first for other modules to use)
            sops-nix.homeManagerModules.sops
            ./secrets.nix  # Secrets configuration with sops-nix
            ./ssh.nix  # SSH configuration with encrypted keys

            # Terminal and shell
            ./nushell.nix  # Nushell configuration
            ./ghostty.nix  # Ghostty configuration
            ./zed.nix  # Zed configuration
            ./television.nix  # Television configuration
            ./wezterm.nix  # WezTerm configuration
            ./zellij.nix  # Zellij configuration (active)
            # ./tmux.nix  # Tmux configuration (disabled - using Zellij)
            ./fish.nix  # Fish shell configuration
            ./starship.nix  # Starship prompt configuration

            # Editors and development
            ./nvim.nix  # Neovim configuration
            ./lsp.nix  # Language Server Protocol configuration
            # ./zsh.nix  # Zsh configuration (disabled - using fish)
            # ./mise.nix  # Mise version manager configuration (removed)
            ./oil-scripts.nix  # Oil.nvim scripts configuration

            # AI assistants
            ./opencode.nix  # OpenCode AI assistant configuration
            ./claude.nix  # Claude Code CLI configuration
            {
              # Personal data
              home.username = "ogs";  # Replace with your username
              home.homeDirectory = "/Users/ogs/";  # macOS home directory
              home.stateVersion = "24.11";  # State version

              # Disable Home Manager's automatic macOS application and font linking
              # This prevents the buildEnv error with /Applications and /share/fonts
              # Fonts are manually installed via home.file instead
              disabledModules = [ "targets/darwin/linkapps.nix" "targets/darwin/fonts.nix" ];

              # Base packages that should be available everywhere
              home.packages = with pkgs; [
                # ─── Terminals and utilities ───
                zellij
                # tmux  # Switched to Zellij
                fish
                # zsh  # Disabled - using fish as primary shell
                nushell

                # ─── Editors and IDEs ───
                # vscode - managed by programs.vscode in lsp.nix

                # ─── Development tools ───
                volta
                carapace
                zoxide
                atuin
                jq
                bash
                starship
                fzf
                nodejs
                nodePackages.pnpm  # Fast package manager
                nodePackages."@angular/cli"  # Angular CLI
                bun
                cargo
                cargo-update  # Tool to update cargo packages
                go
                nil
                uv  # Modern Python package manager
                python3
                unstablePkgs.nixd
                unstablePkgs.neovim
                tree-sitter
                presenterm


                # ─── Compilers and system utilities ───
                gcc
                libiconv  # Required for cargo-update and other Rust packages
                fd
                ripgrep
                coreutils
                unzip
                bat
                lazygit
                git-filter-repo  # Git tool for monorepo management
                gh  # GitHub CLI
                yazi
                television
              ];

              # Install fonts via home.file instead of fonts.packages
              # to avoid buildEnv errors on macOS
              home.file.".local/share/fonts/NerdFonts".source = "${pkgs.nerd-fonts.iosevka-term}/share/fonts";

              # Enable programs explicitly (critical for binaries to appear)
              # All program enables are centralized here
              programs.neovim.enable = false;  # Using unstablePkgs.neovim instead
              programs.fish.enable = true;
              programs.nushell.enable = true;
              programs.starship.enable = true;
              programs.zsh.enable = false;  # Disabled - using fish as primary shell
              programs.git.enable = true;
              programs.gh.enable = true;  # GitHub CLI
              programs.home-manager.enable = true;
              # Note: tmux is configured via home.file in tmux.nix, not programs.tmux

              # Set XDG_CONFIG_HOME to ensure apps use ~/.config
              home.sessionVariables = {
                XDG_CONFIG_HOME = "$HOME/.config";
              };

              # Allow unfree packages
              nixpkgs.config.allowUnfree = true;

              # Manually manage .zshenv to avoid recursive source bug from programs.zsh
              home.file.".zshenv" = {
                force = true;
                text = ''
                  # Nix
                  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
                  fi
                  # End Nix

                  # Home Manager
                  if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
                    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
                  fi

                  # Add home-manager packages to PATH
                  export PATH="$HOME/.local/state/nix/profiles/home-manager/home-path/bin:$PATH"
                  # End Home Manager
                '';
              };
            }
          ];
        };
    in
    {
      # Home Manager configurations for each system
      homeConfigurations = {
        # macOS system configurations
        "x86_64-darwin" = mkHomeConfiguration "x86_64-darwin";
        "aarch64-darwin" = mkHomeConfiguration "aarch64-darwin";

        # Default alias
        "darwin" = mkHomeConfiguration "aarch64-darwin";
      };

      # Development shells for project-specific environments
      # Usage: nix develop .#<shell-name>
      devShells = builtins.listToAttrs (map (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          name = system;
          value = {
            # Default development shell with all tools
            default = pkgs.mkShell {
              name = "gentleman-dev";
              buildInputs = with pkgs; [
                # Essential development tools
                nodejs
                nodePackages.pnpm
                nodePackages.typescript
                nodePackages.typescript-language-server
                nodePackages.eslint_d
                nodePackages.prettier
                git
                gh
                lazygit

                # Shell and utilities
                fish
                starship
                fzf
                ripgrep
                fd
                bat
                jq

                # Nix tools
                nil
                nixpkgs-fmt
              ];

              shellHook = ''
                echo "🎩 Gentleman.Dots development environment"
                echo "Available tools: node, pnpm, typescript, eslint, prettier"
                echo ""
                exec fish
              '';
            };

            # Nx monorepo development shell
            nx-monorepo = pkgs.mkShell {
              name = "nx-workspace";
              buildInputs = with pkgs; [
                # Node.js ecosystem
                nodejs
                nodePackages.pnpm
                nodePackages.npm-check-updates
                bun

                # Nx and Angular CLI (from global packages)
                nodePackages.typescript
                nodePackages.eslint_d
                nodePackages.prettier

                # Language servers for better IDE integration
                nodePackages.typescript-language-server
                nodePackages.vscode-langservers-extracted
                nodePackages.yaml-language-server

                # Git tools for monorepo management
                git
                git-filter-repo
                gh
                lazygit

                # Utilities
                jq
                ripgrep
                fd
                bat
              ];

              shellHook = ''
                echo "🎯 Nx Monorepo Development Environment"
                echo ""
                echo "Quick commands:"
                echo "  pnpm install          - Install dependencies"
                echo "  pnpm nx graph         - View dependency graph"
                echo "  pnpm nx affected      - Check affected projects"
                echo "  pnpm nx build <app>   - Build a project"
                echo "  pnpm nx test <app>    - Test a project"
                echo ""
                echo "Installed versions:"
                echo "  Node: $(node --version)"
                echo "  pnpm: $(pnpm --version)"
                echo "  TypeScript: $(tsc --version)"
                echo ""

                # Set up Nx environment variables
                export NX_DAEMON=true
                export NX_CACHE_DIRECTORY="$HOME/.cache/nx"

                # Source secrets if available
                if [ -f "$HOME/.config/secrets/env" ]; then
                  source "$HOME/.config/secrets/env"
                fi

                exec fish
              '';
            };

            # TypeScript library development
            ts-lib = pkgs.mkShell {
              name = "typescript-library";
              buildInputs = with pkgs; [
                nodejs
                nodePackages.pnpm
                nodePackages.typescript
                nodePackages.typescript-language-server
                nodePackages.eslint_d
                nodePackages.prettier
                nodePackages.npm-check-updates

                # Testing tools
                git
                gh
              ];

              shellHook = ''
                echo "📚 TypeScript Library Development"
                echo ""
                echo "Setup commands:"
                echo "  pnpm init             - Initialize package.json"
                echo "  pnpm add -D typescript @types/node"
                echo "  pnpm tsc --init       - Create tsconfig.json"
                echo ""
                exec fish
              '';
            };

            # Node.js API development
            node-api = pkgs.mkShell {
              name = "nodejs-api";
              buildInputs = with pkgs; [
                nodejs
                nodePackages.pnpm
                nodePackages.typescript
                nodePackages.typescript-language-server
                nodePackages.eslint_d
                nodePackages.prettier

                # Database tools
                postgresql
                redis

                # API testing
                curl
                jq

                git
                gh
              ];

              shellHook = ''
                echo "🚀 Node.js API Development"
                echo ""
                echo "Common frameworks:"
                echo "  pnpm add express fastify nestjs"
                echo "  pnpm add -D @types/node @types/express"
                echo ""
                echo "Database access:"
                echo "  PostgreSQL: localhost:5432"
                echo "  Redis: localhost:6379"
                echo ""
                exec fish
              '';
            };

            # Frontend development (Angular/React/Vue)
            frontend = pkgs.mkShell {
              name = "frontend-dev";
              buildInputs = with pkgs; [
                nodejs
                nodePackages.pnpm
                nodePackages."@angular/cli"
                bun

                # Language servers
                nodePackages.typescript-language-server
                nodePackages.vscode-langservers-extracted

                # Tools
                nodePackages.prettier
                nodePackages.eslint_d

                git
                gh
              ];

              shellHook = ''
                echo "🎨 Frontend Development Environment"
                echo ""
                echo "Available CLIs:"
                echo "  ng new <app>          - Create Angular app"
                echo "  pnpm create vite      - Create Vite app (React/Vue/Svelte)"
                echo "  pnpm create next-app  - Create Next.js app"
                echo ""
                exec fish
              '';
            };

            # DevOps and infrastructure
            devops = pkgs.mkShell {
              name = "devops";
              buildInputs = with pkgs; [
                # Container tools
                docker
                docker-compose

                # CI/CD
                gh
                git

                # Infrastructure as Code
                terraform
                ansible

                # Cloud CLIs (if needed)
                # awscli2
                # google-cloud-sdk
                # azure-cli

                # Utilities
                jq
                yq
                kubectl
              ];

              shellHook = ''
                echo "⚙️  DevOps Environment"
                echo ""
                echo "Available tools:"
                echo "  docker, docker-compose"
                echo "  terraform, ansible"
                echo "  kubectl, gh"
                echo ""
                exec fish
              '';
            };
          };
        }
      ) supportedSystems);
    };
}
