{ config, pkgs, lib, ... }:

{
  # SSH configuration managed by Home Manager
  # Private keys are stored in sops-encrypted secrets

  programs.ssh = {
    enable = true;

    # SSH client configuration
    extraConfig = ''
      # Added by OrbStack: 'orb' SSH host for Linux machines
      Include ~/.orbstack/ssh/config
    '';

    # SSH host configurations
    matchBlocks = {
      # Personal Raspberry Pi
      "garbarok" = {
        hostname = "192.168.1.45";
        user = "garbarok";
        identityFile = "~/.ssh/raspberry";
        extraOptions = {
          StrictHostKeyChecking = "accept-new";
        };
      };

      # Jenkins build server
      "jenkins16" = {
        hostname = "cuebuild16.stibo.corp";
        user = "jenkins";
        extraOptions = {
          StrictHostKeyChecking = "accept-new";
          UpdateHostKeys = "yes";
        };
      };

      # CUE branches server (through Jenkins jump host)
      "cue-branches" = {
        hostname = "ece-cue-branches.rnd.cue.cloud";
        user = "hudson";
        proxyJump = "jenkins16";
        extraOptions = {
          StrictHostKeyChecking = "accept-new";
          UpdateHostKeys = "yes";
        };
      };

      # GitHub (common configuration)
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";  # macOS keychain integration
        };
      };

      # Default settings for all hosts
      "*" = {
        extraOptions = {
          # Security
          HashKnownHosts = "yes";

          # Performance
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h:%p";
          ControlPersist = "600";

          # Keepalive
          ServerAliveInterval = "60";
          ServerAliveCountMax = "3";
        };
      };
    };
  };

  # Create SSH socket directory
  home.file.".ssh/sockets/.keep".text = "";

  # SSH keys managed by sops-nix
  # These are decrypted at activation time
  sops.secrets = {
    # Main SSH key (for GitHub, etc.)
    "ssh/id_ed25519" = {
      path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      mode = "0600";
    };

    # Raspberry Pi key
    "ssh/raspberry" = {
      path = "${config.home.homeDirectory}/.ssh/raspberry";
      mode = "0600";
    };
  };

  # Public keys can be managed directly (not sensitive)
  home.file.".ssh/id_ed25519.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBhHI4XFJWS7+PES5+rGH8EE9xc+ovz+nnkgON00u0Q5 osg@stibodx.com
  '';

  home.file.".ssh/raspberry.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJV5zYOnu5XketzNVfcqE5qmWJKJA1EB/4J1UO8OmkbE rp4@oscargallegoruiz.com
  '';

  # Git SSH configuration (for commit signing)
  programs.git.settings = {
    gpg = {
      format = "ssh";
    };
    "gpg \"ssh\"" = {
      # Use SSH key for commit signing
      # Uncomment and set your public key path:
      # allowedSignersFile = "~/.ssh/allowed_signers";
    };
    commit = {
      # Uncomment to sign commits with SSH key:
      # gpgsign = true;
    };
  };

  # SSH agent configuration for macOS
  home.activation.setupSSHAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Add SSH keys to macOS keychain (if not already added)
    if [ "$(uname)" = "Darwin" ]; then
      $DRY_RUN_CMD /usr/bin/ssh-add --apple-load-keychain 2>/dev/null || true
    fi
  '';
}
