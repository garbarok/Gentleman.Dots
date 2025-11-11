{ pkgs, ... }:
{
  home.packages = [ pkgs.mise ];

  # Configure mise settings - restored from backup
  home.file.".config/mise/config.toml".text = ''
    min_version = "2024.9.5"

    [env]
    _.path = ['{{config_root}}/node_modules/.bin']
    PROJECT_NAME = "{{ config_root | basename }}"
    BIN_PATH = "{{ config_root }}/node_modules/.bin"
    NODE_ENV = "{{ env.NODE_ENV | default(value='development') }}"

    [tools]
    bun = "latest"
    go = "latest"
    java = "zulu-11"
    node = "{{ env['NODE_VERSION'] | default(value='lts') }}"
    "npm:@angular/cli" = "latest"
    "npm:@angular/language-server" = "latest"
    "npm:@anthropic-ai/claude-code" = "latest"
    "npm:@github/copilot" = "latest"
    "npm:@microsoft/rush" = "latest"
    "npm:@nestjs/cli" = "latest"
    "npm:backlog.md" = "latest"
    "npm:eas-cli" = "latest"
    "npm:eslint" = "latest"
    "npm:nx" = "latest"
    "npm:prettier" = "latest"
    "npm:typescript" = "latest"
    ruby = "3.4.4"

    [hooks]
    postinstall = 'npx corepack enable'

    [settings]
    idiomatic_version_file_enable_tools = ["node"]
    experimental = true
    all_compile = false  # Use precompiled binaries (faster with Nix)

    [tasks.pnpm-install]
    description = 'Installs dependencies with pnpm'
    run = 'pnpm install'
    sources = ['package.json', 'pnpm-lock.yaml', 'mise.toml']
    outputs = ['node_modules/.pnpm/lock.yaml']

    [tasks.dev]
    description = 'Calls your dev script in package.json'
    run = 'node --run dev'
    depends = ['pnpm-install']

    [settings.python]
    compile = false

    [tasks.build]
    description = "Build the project"
    alias = "b"
    run = "npm run build"

    [tasks.info]
    description = "Print project information"
    run = "echo Project: $PROJECT_NAME && echo NODE_ENV: $NODE_ENV"

    # ─────────────────────────────────────────────────────────────
    # Nx Monorepo Tasks
    # ─────────────────────────────────────────────────────────────

    [tasks.nx-graph]
    description = "Open Nx dependency graph"
    alias = "graph"
    run = "pnpm nx graph"
    depends = ["pnpm-install"]

    [tasks.nx-affected]
    description = "Show affected projects"
    alias = "affected"
    run = "pnpm nx affected"
    depends = ["pnpm-install"]

    [tasks.nx-affected-build]
    description = "Build all affected projects"
    alias = "affected:build"
    run = "pnpm nx affected --target=build"
    depends = ["pnpm-install"]

    [tasks.nx-affected-test]
    description = "Test all affected projects"
    alias = "affected:test"
    run = "pnpm nx affected --target=test"
    depends = ["pnpm-install"]

    [tasks.nx-affected-lint]
    description = "Lint all affected projects"
    alias = "affected:lint"
    run = "pnpm nx affected --target=lint"
    depends = ["pnpm-install"]

    [tasks.nx-cache-clean]
    description = "Clear Nx cache"
    alias = "cache:clean"
    run = "pnpm nx reset"

    [tasks.nx-list]
    description = "List all projects in workspace"
    alias = "projects"
    run = "pnpm nx show projects"
    depends = ["pnpm-install"]

    [tasks.nx-migrate]
    description = "Migrate Nx workspace to latest version"
    alias = "migrate"
    run = "pnpm nx migrate latest && pnpm install && pnpm nx migrate --run-migrations"
    depends = ["pnpm-install"]

    # ─────────────────────────────────────────────────────────────
    # Angular/Frontend Tasks
    # ─────────────────────────────────────────────────────────────

    [tasks.ng-generate-component]
    description = "Generate Angular component (usage: mise run ng-component -- my-component)"
    alias = "ng-component"
    run = "pnpm nx generate @angular/core:component"
    depends = ["pnpm-install"]

    [tasks.ng-generate-service]
    description = "Generate Angular service (usage: mise run ng-service -- my-service)"
    alias = "ng-service"
    run = "pnpm nx generate @angular/core:service"
    depends = ["pnpm-install"]

    [tasks.ng-generate-module]
    description = "Generate Angular module (usage: mise run ng-module -- my-module)"
    alias = "ng-module"
    run = "pnpm nx generate @angular/core:module"
    depends = ["pnpm-install"]

    # ─────────────────────────────────────────────────────────────
    # Quality & Testing Tasks
    # ─────────────────────────────────────────────────────────────

    [tasks.lint]
    description = "Lint all files"
    alias = "l"
    run = "pnpm eslint . --fix"
    depends = ["pnpm-install"]

    [tasks.format]
    description = "Format all files with Prettier"
    alias = "fmt"
    run = "pnpm prettier --write ."
    depends = ["pnpm-install"]

    [tasks.typecheck]
    description = "Run TypeScript type checking"
    alias = "tc"
    run = "pnpm tsc --noEmit"
    depends = ["pnpm-install"]

    [tasks.test]
    description = "Run all tests"
    alias = "t"
    run = "pnpm test"
    depends = ["pnpm-install"]

    [tasks.test-watch]
    description = "Run tests in watch mode"
    alias = "tw"
    run = "pnpm test --watch"
    depends = ["pnpm-install"]

    [tasks.test-coverage]
    description = "Run tests with coverage"
    alias = "cov"
    run = "pnpm test --coverage"
    depends = ["pnpm-install"]

    # ─────────────────────────────────────────────────────────────
    # Dependency Management Tasks
    # ─────────────────────────────────────────────────────────────

    [tasks.deps-check]
    description = "Check for outdated dependencies"
    alias = "deps:check"
    run = "pnpm outdated"
    depends = ["pnpm-install"]

    [tasks.deps-update]
    description = "Update dependencies interactively"
    alias = "deps:update"
    run = "pnpm ncu -i"
    depends = ["pnpm-install"]

    [tasks.deps-audit]
    description = "Audit dependencies for security issues"
    alias = "audit"
    run = "pnpm audit"
    depends = ["pnpm-install"]

    [tasks.deps-dedupe]
    description = "Deduplicate dependencies"
    alias = "dedupe"
    run = "pnpm dedupe"
    depends = ["pnpm-install"]

    # ─────────────────────────────────────────────────────────────
    # Workspace Management Tasks
    # ─────────────────────────────────────────────────────────────

    [tasks.clean]
    description = "Clean build artifacts and caches"
    alias = "c"
    run = """
    rm -rf dist node_modules/.cache
    pnpm nx reset
    echo "✨ Cleaned build artifacts and caches"
    """

    [tasks.clean-all]
    description = "Clean everything including node_modules"
    alias = "ca"
    run = """
    rm -rf dist node_modules .nx
    echo "🧹 Cleaned all artifacts. Run 'pnpm install' to restore."
    """

    [tasks.workspace-info]
    description = "Display workspace information"
    alias = "info:workspace"
    run = """
    echo "📦 Workspace Information"
    echo "======================="
    echo "Project: $PROJECT_NAME"
    echo "Node Version: $(node --version)"
    echo "pnpm Version: $(pnpm --version)"
    echo "Nx Version: $(pnpm nx --version)"
    echo "TypeScript Version: $(pnpm tsc --version)"
    echo ""
    echo "Projects:"
    pnpm nx show projects
    """
    depends = ["pnpm-install"]

    # ─────────────────────────────────────────────────────────────
    # CI/CD Tasks
    # ─────────────────────────────────────────────────────────────

    [tasks.ci-check]
    description = "Run all CI checks (lint, typecheck, test, build)"
    alias = "ci"
    run = """
    echo "🔍 Running CI checks..."
    pnpm run lint && \
    pnpm tsc --noEmit && \
    pnpm test --run && \
    pnpm run build
    echo "✅ All CI checks passed!"
    """
    depends = ["pnpm-install"]

    [tasks.pre-commit]
    description = "Run pre-commit checks"
    alias = "pre"
    run = """
    pnpm lint-staged && \
    pnpm tsc --noEmit
    """
    depends = ["pnpm-install"]
  '';
}
