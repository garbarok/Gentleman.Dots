# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**Gentleman.Dots** is a declarative macOS development environment using Nix Flakes and Home Manager. This is NOT a traditional software project - it's a dotfiles configuration repository that manages system-wide tool configurations, shells, editors, terminals, and development tools.

## Essential Commands

### Building and Applying Configuration

```bash
# Apply configuration changes (from project root)
home-manager switch --flake .#darwin

# Or use the Fish alias (requires Fish shell)
nixup  # Updates flake.lock and applies configuration

# Quick switch without flake update
nixswitch  # Just applies current configuration

# Validate Nix syntax
nix flake check

# Update dependencies
nix flake update
```

### Development Shells

The flake provides specialized development environments:

```bash
# Default development shell
nix develop

# Nx monorepo environment
nix develop .#aarch64-darwin.nx-monorepo

# TypeScript library development
nix develop .#aarch64-darwin.ts-lib

# Node.js API development
nix develop .#aarch64-darwin.node-api

# Frontend development (Angular/React/Vue)
nix develop .#aarch64-darwin.frontend

# DevOps and infrastructure
nix develop .#aarch64-darwin.devops
```

### Managing Secrets

```bash
# Initial secrets setup
setup-secrets

# Edit encrypted secrets
edit-secrets

# View secrets (debugging)
show-secrets

# Rotate age encryption key
rotate-age-key
```

## Architecture

### Core Configuration Pattern

The repository follows a **modular Nix configuration** pattern:

1. **flake.nix**: Main entry point - defines system configurations and development shells
2. **Individual .nix modules**: Each tool/shell has its own module (e.g., `fish.nix`, `nvim.nix`, `ghostty.nix`)
3. **Configuration directories**: Tool-specific configs in subdirectories (e.g., `nvim/`, `ghostty/`, `zed/`)

### Key Architectural Decisions

**macOS-Specific Workarounds:**
- `disabledModules = [ "targets/darwin/linkapps.nix" "targets/darwin/fonts.nix" ]` - Disables broken Home Manager modules on macOS
- Fonts installed via `home.file` instead of `fonts.packages` to avoid buildEnv errors
- Manual application linking instead of automatic macOS app linking

**Overlay System:**
- Fish shell build tests disabled via overlay: `fish.overrideAttrs (oldAttrs: { doCheck = false; })`
- Prevents build failures while maintaining functionality

**Dual Package Sources:**
- Stable packages from `nixpkgs` (main channel)
- Unstable packages from `nixpkgs-unstable` for bleeding-edge tools (Neovim, Nixd)

### Module Organization

Each `.nix` file follows this pattern:
```nix
{ pkgs, lib, ... }:
{
  # Package installations
  home.packages = [ ... ];

  # Program-specific configuration
  programs.toolname = { ... };

  # File deployment
  home.file."path/to/config" = { ... };

  # Activation scripts (if needed)
  home.activation.scriptName = lib.hm.dag.entryAfter ["linkGeneration"] ''
    # Shell commands to run on activation
  '';
}
```

### Critical Files

- **flake.nix**: System configuration, package lists, development shells
- **secrets.nix**: sops-nix integration for encrypted secrets management
- **ssh.nix**: SSH configuration with encrypted keys
- **fish.nix**: Fish shell with 400+ completions and custom aliases
- **nvim.nix**: Neovim deployment (actual config in `nvim/` directory)
- **oil-scripts.nix**: Custom file navigation scripts for Neovim

## Important Patterns and Conventions

### File Deployment

Home Manager copies configs during activation:
```nix
home.activation.copyGhostty = lib.hm.dag.entryAfter ["writeBoundary"] ''
  cp -r ${toString ./ghostty}/* "$HOME/.config/ghostty/"
  chmod -R u+w "$HOME/.config/ghostty"
'';
```

### Secrets Management

Uses **sops-nix** with **age** encryption:
- Encrypted secrets in `secrets/secrets.yaml`
- Age private key at `~/.config/sops/age/keys.txt` (NEVER commit)
- Decrypted secrets deployed to `~/.config/anthropic/api_key`, etc.
- Environment variables loaded from `~/.config/secrets/env`

### Platform Detection

```nix
pkgs.stdenv.isDarwin  # Check if running on macOS
```

### Nix Configuration Style

- **2-space indentation**
- **Kebab-case for filenames** (`nushell.nix`, not `nushell_config.nix`)
- **Use `lib.mkIf` for conditionals**
- **Prefer overlays over package overrides when possible**

## Known Issues and Fixes

### Font Installation Error (Resolved)

**Problem**: `buildEnv error: Can't use string ("/share/fonts") as an ARRAY ref`

**Solution**: Disabled `targets/darwin/fonts.nix` module and installed fonts manually:
```nix
disabledModules = [ "targets/darwin/linkapps.nix" "targets/darwin/fonts.nix" ];
home.file.".local/share/fonts/NerdFonts".source = "${pkgs.nerd-fonts.iosevka-term}/share/fonts";
```

### Fish Shell Build Failures

**Problem**: Fish tests fail during Nix build on some systems

**Solution**: Override with `doCheck = false` in flake overlays:
```nix
overlays = [
  (final: prev: {
    fish = prev.fish.overrideAttrs (oldAttrs: {
      doCheck = false;
    });
  })
];
```

### VSCode Conflicts

VSCode should NOT be installed via Nix due to macOS application linking issues. Install manually and comment out in `flake.nix`:
```nix
# vscode - install manually outside of Nix
```

## Debugging Tips

### Build Errors

```bash
# View full build log for a failed derivation
nix log /nix/store/xxx-package.drv

# Check what packages are included
nix eval .#homeConfigurations.darwin.config.home.packages --apply 'map (x: x.name)'
```

### Configuration Issues

```bash
# List all home-manager generations
home-manager generations

# Rollback to previous generation
home-manager generations | head -n 2 | tail -n 1
/nix/store/xxx-home-manager-generation/activate

# Check what files will be deployed
nix build .#homeConfigurations.darwin.activationPackage --dry-run
```

## AI Tools Configuration

Multiple AI assistants are configured but **only enable ONE at a time** in `~/.config/nvim/lua/plugins/disabled.lua`:

- Claude Code (enabled by default)
- Avante.nvim
- CopilotChat.nvim
- OpenCode.nvim
- CodeCompanion.nvim
- Gemini.nvim

## Common Customization Patterns

### Adding a New Package

```nix
# In flake.nix, add to home.packages
home.packages = with pkgs; [
  # ... existing packages
  new-package-name
];
```

### Adding a New Tool Configuration

1. Create `toolname.nix` in repository root
2. Add configuration module
3. Import in `flake.nix` modules list:
```nix
modules = [
  # ... existing modules
  ./toolname.nix
];
```

### Adding Custom Aliases (Fish Shell)

Edit `fish.nix` interactiveShellInit section:
```fish
alias myalias='command --flags'
```

## Shell Integration

Fish shell automatically loads:
- **Starship** prompt
- **Zoxide** for smart `cd`
- **Atuin** for command history
- **FZF** for fuzzy finding
- **Carapace** for completions
- **Tmux** on terminal launch (unless in ZED_TERMINAL)

Environment variables and secrets sourced from `~/.config/secrets/env`.

## Update Workflow

```bash
# Update all tools (Fish function)
allup  # Updates Homebrew, Nix packages, and Mise-managed tools

# Individual updates
nixup      # Update and switch Nix configuration
miseup     # Update Mise-managed tools
cargoup    # Update Cargo packages
```

## Important File Locations

| Tool | Config Location |
|------|----------------|
| Fish | `~/.config/fish/` |
| Nushell | `~/Library/Application Support/nushell/` |
| Neovim | `~/.config/nvim/` |
| Ghostty | `~/.config/ghostty/` |
| Zed | `~/.config/zed/` |
| Tmux | `~/.config/tmux/` |
| Secrets | `~/.config/secrets/env` |
| SSH Keys | `~/.ssh/` (managed via sops-nix) |

## When Making Changes

1. Edit the relevant `.nix` file(s)
2. Run `home-manager switch --flake .#darwin` to apply
3. Test the changes
4. Commit to git (encrypted secrets are safe to commit)
5. Never commit:
   - `~/.config/sops/age/keys.txt`
   - Unencrypted secret files
   - `.key` or `.txt` files in `secrets/`
