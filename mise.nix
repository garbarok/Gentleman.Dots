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
    run = '''
      echo "Project: $PROJECT_NAME"
      echo "NODE_ENV: $NODE_ENV"
    '''
  '';
}
