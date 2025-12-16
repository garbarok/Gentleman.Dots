{ pkgs, ... }:
{
  # Install mise package
  home.packages = [ pkgs.mise ];

  # NOTE: Mise config is now managed manually at ~/.config/mise/config.toml
  # Nix will no longer overwrite your mise configuration.
  #
  # You can manage mise directly using commands like:
  #   mise use -g npm:package-name
  #   mise install
  #   mise settings set <key> <value>
  #
  # For reference, the previous Nix-managed configuration included:
  # - Global tools: bun, go, java, node, ruby
  # - NPM tools: @angular/cli, @anthropic-ai/claude-code, @nestjs/cli, nx, prettier, typescript, etc.
  # - Custom mise tasks for: pnpm-install, dev, build, nx-*, ng-*, lint, format, test, etc.
  #
  # If you want to restore Nix management, the full config is available in git history:
  #   git log -p -- mise.nix
}
