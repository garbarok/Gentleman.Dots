# Gentleman.Dots Improvements

## Overview

This document describes recent improvements to the Gentleman.Dots configuration, focusing on portability, productivity, and TypeScript/JavaScript development workflows.

---

## 🎯 New Features

### 1. Language Server Protocol (LSP) Configuration

**File:** [lsp.nix](lsp.nix)

Comprehensive LSP setup for enhanced IDE integration with TypeScript, JavaScript, and Node.js development.

#### Installed Language Servers

- **typescript-language-server** - Main TS/JS LSP with IntelliSense
- **vscode-langservers-extracted** - HTML, CSS, JSON, ESLint LSPs
- **yaml-language-server** - YAML support (configs, CI/CD)
- **bash-language-server** - Bash script support
- **marksman** - Markdown LSP
- **nil** - Nix language server
- **eslint_d** - Fast ESLint daemon
- **prettier** - Code formatter

#### IDE Integration

**Zed Editor:**
- Configured with TypeScript LSP and inlay hints
- ESLint integration for on-the-fly linting
- Nix support for editing dotfiles

**Neovim:**
- LazyVim-compatible configuration
- LSP keymaps: `<leader>li` (LSP Info), `<leader>lr` (LSP Restart)

**VS Code:**
- Extensions for ESLint, Prettier, Angular
- GitLens and ErrorLens for better development experience

---

### 2. Secrets Management with sops-nix

**File:** [secrets.nix](secrets.nix)

Secure, encrypted management of API keys and sensitive configuration using [sops-nix](https://github.com/Mic92/sops-nix).

#### Features

- **Age-based encryption** - Modern, secure encryption
- **Git-safe secrets** - Encrypted files can be committed
- **Automatic decryption** - Secrets available on activation
- **Shell integration** - Environment variables automatically loaded

#### Setup Instructions

```bash
# 1. Initialize secrets infrastructure
setup-secrets

# 2. Edit your secrets
edit-secrets

# 3. Apply configuration
nixswitch
```

#### Managed Secrets

- `anthropic_api_key` - Claude API key
- `openai_api_key` - OpenAI API key
- `github_token` - GitHub personal access token
- `npm_token` - NPM registry token
- `env_secrets` - Environment variables file

#### Helper Commands

| Command | Description |
|---------|-------------|
| `setup-secrets` | Initialize secrets infrastructure |
| `edit-secrets` | Edit encrypted secrets file |
| `show-secrets` | Display decrypted secrets (debugging) |
| `rotate-age-key` | Generate new encryption key |

#### Security Best Practices

- ✅ `.sops.yaml` contains only public keys (safe to commit)
- ✅ `secrets/secrets.yaml` is encrypted (safe to commit)
- ❌ Never commit `.config/sops/age/keys.txt` (private key)
- ❌ Add `secrets/*.txt` and `*.key` to `.gitignore`

---

### 3. Development Shells

**File:** [flake.nix](flake.nix) (lines 164-416)

Project-specific Nix development environments with pinned dependencies and automatic setup.

#### Available Shells

##### Default Shell
```bash
nix develop           # Or use alias: nix-dev
```
General development with Node.js, TypeScript, Git, and Nix tools.

##### Nx Monorepo Shell
```bash
nix develop .#nx-monorepo    # Or: nix-nx
```
Optimized for Nx workspaces with:
- Latest Node.js, pnpm, Bun
- TypeScript, ESLint, Prettier
- All language servers (TS, HTML, CSS, YAML)
- Git tools (git-filter-repo, lazygit)
- Nx environment variables (`NX_DAEMON=true`)
- Secrets automatically loaded

##### TypeScript Library Shell
```bash
nix develop .#ts-lib         # Or: nix-ts
```
Lightweight environment for TypeScript library development.

##### Node.js API Shell
```bash
nix develop .#node-api       # Or: nix-api
```
Backend development with PostgreSQL and Redis support.

##### Frontend Shell
```bash
nix develop .#frontend       # Or: nix-fe
```
Angular, React, Vue development with all necessary CLIs.

##### DevOps Shell
```bash
nix develop .#devops         # Or: nix-devops
```
Container tools (Docker), CI/CD, Infrastructure as Code (Terraform, Ansible).

#### Shell Aliases

| Alias | Full Command | Description |
|-------|--------------|-------------|
| `nix-dev` | `nix develop .#default` | Default shell |
| `nix-nx` | `nix develop .#nx-monorepo` | Nx workspace |
| `nix-ts` | `nix develop .#ts-lib` | TypeScript library |
| `nix-api` | `nix develop .#node-api` | Node.js API |
| `nix-fe` | `nix develop .#frontend` | Frontend dev |
| `nix-devops` | `nix develop .#devops` | DevOps tools |

---

### 4. Enhanced Nx Workflow with Mise Tasks

**File:** [mise.nix](mise.nix)

Comprehensive mise task configuration for Nx monorepo development with short aliases.

#### Task Categories

##### Nx Monorepo Tasks

| Task | Alias | Description |
|------|-------|-------------|
| `mise run nx-graph` | `mgraph` | Open dependency graph |
| `mise run nx-affected` | `maffected` | Show affected projects |
| `mise run nx-affected-build` | `affected:build` | Build affected |
| `mise run nx-affected-test` | `affected:test` | Test affected |
| `mise run nx-affected-lint` | `affected:lint` | Lint affected |
| `mise run nx-cache-clean` | `cache:clean` | Clear Nx cache |
| `mise run nx-list` | `projects` | List all projects |
| `mise run nx-migrate` | `migrate` | Migrate to latest Nx |

##### Angular/Frontend Tasks

| Task | Alias | Description |
|------|-------|-------------|
| `mise run ng-component` | `ng-component` | Generate component |
| `mise run ng-service` | `ng-service` | Generate service |
| `mise run ng-module` | `ng-module` | Generate module |

##### Quality & Testing Tasks

| Task | Alias | Description |
|------|-------|-------------|
| `mise run lint` | `mlint` | Lint with auto-fix |
| `mise run format` | `mfmt` | Format with Prettier |
| `mise run typecheck` | `mtc` | TypeScript check |
| `mise run test` | `mtest` | Run all tests |
| `mise run test-watch` | `tw` | Tests in watch mode |
| `mise run test-coverage` | `cov` | Tests with coverage |

##### Dependency Management

| Task | Alias | Description |
|------|-------|-------------|
| `mise run deps-check` | `deps:check` | Check outdated deps |
| `mise run deps-update` | `deps:update` | Interactive update |
| `mise run deps-audit` | `audit` | Security audit |
| `mise run deps-dedupe` | `dedupe` | Deduplicate deps |

##### Workspace Management

| Task | Alias | Description |
|------|-------|-------------|
| `mise run clean` | `mclean` | Clean artifacts |
| `mise run clean-all` | `ca` | Clean everything |
| `mise run workspace-info` | `info:workspace` | Show info |

##### CI/CD Tasks

| Task | Alias | Description |
|------|-------|-------------|
| `mise run ci-check` | `mci` | All CI checks |
| `mise run pre-commit` | `pre` | Pre-commit checks |

#### Fish Aliases for Mise

| Alias | Command | Description |
|-------|---------|-------------|
| `mr` | `mise run` | Run any mise task |
| `mt` | `mise tasks` | List all tasks |
| `mgraph` | `mise run graph` | Nx dependency graph |
| `maffected` | `mise run affected` | Affected projects |
| `mlint` | `mise run lint` | Run linter |
| `mfmt` | `mise run fmt` | Format code |
| `mtc` | `mise run typecheck` | Type check |
| `mtest` | `mise run test` | Run tests |
| `mci` | `mise run ci` | CI checks |
| `mclean` | `mise run clean` | Clean artifacts |

---

## 📋 Complete Command Reference

### Nix Management

```bash
nixup         # Update flake and switch
nixswitch     # Switch to current config
nix-dev       # Enter default dev shell
nix-nx        # Enter Nx monorepo shell
```

### Nx Workflows

```bash
# Graph and affected analysis
mgraph                # Visual dependency graph
maffected             # See what changed
mise run affected:build   # Build only affected
mise run affected:test    # Test only affected

# Project operations
nxb myapp             # Build specific project
nxt myapp             # Test specific project
nxs myapp             # Serve application
```

### Development

```bash
# Code quality
mlint                 # Lint with auto-fix
mfmt                  # Format all files
mtc                   # Type check
mtest                 # Run tests

# Dependencies
mise run deps:check   # Check outdated
mise run deps:update  # Interactive update
mise run audit        # Security audit

# CI/CD
mci                   # Run all CI checks
mise run pre          # Pre-commit checks
```

### Secrets Management

```bash
setup-secrets         # First-time setup
edit-secrets          # Edit encrypted secrets
show-secrets          # View decrypted (debug)
rotate-age-key        # New encryption key
```

### Updates

```bash
allup                 # Update everything
nixup                 # Update Nix packages
miseup                # Update mise tools
```

---

## 🚀 Getting Started

### Initial Setup

1. **Clone and apply configuration:**
   ```bash
   cd ~/Projects/Gentleman.Dots
   nixup
   ```

2. **Setup secrets (optional but recommended):**
   ```bash
   setup-secrets
   edit-secrets
   # Add your API keys
   nixswitch
   ```

3. **Verify installation:**
   ```bash
   mt                    # List available tasks
   node --version        # Check Node.js
   pnpm --version        # Check pnpm
   ```

### Daily Workflow

#### Starting a New Nx Project

```bash
# Enter Nx development shell
nix-nx

# Create workspace (or navigate to existing)
pnpm create nx-workspace myorg

# Install dependencies
pnpm install

# Generate app
pnpm nx g @nx/angular:app myapp

# Development
pnpm nx serve myapp
```

#### Working on Existing Project

```bash
# Update dependencies
pnpm install

# Check what's affected by your changes
maffected

# Run CI checks locally
mci

# Build and test affected projects
mise run affected:build
mise run affected:test
```

#### Code Quality Workflow

```bash
# Format code
mfmt

# Lint with auto-fix
mlint

# Type check
mtc

# Run tests
mtest
```

---

## 📊 Benefits

### Portability Improvements

- ✅ **Declarative secrets** - No manual API key setup
- ✅ **Reproducible dev environments** - Dev shells with pinned versions
- ✅ **Language server consistency** - Same LSP config everywhere
- ✅ **Task automation** - Mise tasks work on any machine

### Productivity Gains

- ⚡ **Faster onboarding** - `nix-nx` gives complete environment
- ⚡ **Shorter commands** - `mgraph` vs `pnpm nx graph`
- ⚡ **Task discovery** - `mt` shows all available tasks
- ⚡ **Nx-optimized** - Affected builds, caching, dependency tracking

### Developer Experience

- 🎯 **Better IDE integration** - LSPs provide IntelliSense everywhere
- 🎯 **Consistent tooling** - Same versions across projects
- 🎯 **Secure secrets** - Encrypted, version-controlled API keys
- 🎯 **Project isolation** - Dev shells prevent dependency conflicts

---

## 🔄 Migration Guide

### From Old Setup

If you're updating from a previous Gentleman.Dots configuration:

1. **Backup current setup:**
   ```bash
   cd ~/Projects/Gentleman.Dots
   git stash
   ```

2. **Pull latest changes:**
   ```bash
   git pull origin main
   ```

3. **Update flake:**
   ```bash
   nix flake update
   ```

4. **Switch to new config:**
   ```bash
   home-manager switch --flake .#darwin
   ```

5. **Setup secrets (if using):**
   ```bash
   setup-secrets
   ```

6. **Test new features:**
   ```bash
   mt               # List mise tasks
   nix-nx           # Try Nx shell
   edit-secrets     # Configure API keys
   ```

---

## 📝 Configuration Files

| File | Purpose |
|------|---------|
| [flake.nix](flake.nix) | Main Nix configuration with dev shells |
| [lsp.nix](lsp.nix) | Language server configuration |
| [secrets.nix](secrets.nix) | Secrets management with sops-nix |
| [mise.nix](mise.nix) | Mise tasks for Nx workflows |
| [fish.nix](fish.nix) | Fish shell with new aliases |
| `.sops.yaml` | Sops configuration (auto-generated) |
| `secrets/secrets.yaml` | Encrypted secrets (auto-generated) |

---

## 🐛 Troubleshooting

### LSP not working in editor

```bash
# Ensure LSPs are installed
which typescript-language-server
which eslint_d

# Restart LSP
# In Neovim: <leader>lr
# In Zed: Cmd+Shift+P -> "LSP: Restart"
```

### Secrets not loading

```bash
# Check age key exists
ls ~/.config/sops/age/keys.txt

# Verify secrets file
show-secrets

# Re-apply configuration
nixswitch
```

### Dev shell not working

```bash
# Update flake
cd ~/Projects/Gentleman.Dots
nix flake update

# Try with verbose output
nix develop .#nx-monorepo --verbose

# Check supported systems
nix flake show
```

### Mise tasks not found

```bash
# Ensure mise is installed
which mise

# Check if config exists
cat ~/.config/mise/config.toml

# List available tasks
mise tasks
```

---

## 🎓 Learn More

### Resources

- [Nix Flakes](https://nixos.wiki/wiki/Flakes) - Nix flakes documentation
- [Home Manager](https://github.com/nix-community/home-manager) - User environment management
- [sops-nix](https://github.com/Mic92/sops-nix) - Secrets management
- [Mise](https://mise.jdx.dev/) - Development environment manager
- [Nx](https://nx.dev/) - Monorepo tool

### Next Steps

Consider these additional improvements:

1. **Cross-platform support** - Add Linux configurations
2. **Parameterized username** - Remove hardcoded "ogs"
3. **Devcontainer integration** - Add `.devcontainer/` support
4. **Binary caching** - Set up personal Nix cache
5. **CI/CD templates** - Add GitHub Actions workflows

---

## 📞 Support

For issues or questions:

1. Check [IMPROVEMENTS.md](IMPROVEMENTS.md) (this file)
2. Review [flake.nix](flake.nix) comments
3. Run `mt` to see available mise tasks
4. Check individual module files (lsp.nix, secrets.nix, etc.)

Happy coding! 🎩
