{ config, pkgs, ... }:
{
  home.file.".config/starship.toml".source = ./starship.toml;
}
