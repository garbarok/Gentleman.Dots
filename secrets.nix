{ config, pkgs, lib, ... }:

{
  # Secrets management using sops-nix
  # This provides secure, encrypted storage of API keys and sensitive configuration
  #
  # Setup instructions:
  # 1. Install age: already included in packages below
  # 2. Generate age key: age-keygen -o ~/.config/sops/age/keys.txt
  # 3. Create .sops.yaml in repo root (see template below)
  # 4. Create secrets/secrets.yaml and encrypt it: sops secrets/secrets.yaml
  #
  # After setup, secrets will be automatically decrypted during home-manager activation

  imports = [
    # sops-nix will be added via flake input
  ];

  # Install required tools
  home.packages = with pkgs; [
    age  # Encryption tool
    sops  # Secrets editor
    ssh-to-age  # Convert SSH keys to age format
  ];

  # Configure sops-nix
  sops = {
    # Default sops file (can be overridden per secret)
    defaultSopsFile = ./secrets/secrets.yaml;

    # Validate sops files at build time
    validateSopsFiles = false;  # Set to true once secrets are set up

    # Age key configuration
    age = {
      # Path to your age private key
      # Generate with: age-keygen -o ~/.config/sops/age/keys.txt
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # Automatically generate age key from SSH key (alternative to manual generation)
      generateKey = true;

      # Use SSH host key instead of generating new age key
      sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };

    # Define secrets to be managed
    secrets = {
      # API Keys
      "anthropic_api_key" = {
        path = "${config.home.homeDirectory}/.config/anthropic/api_key";
        mode = "0600";
      };

      "openai_api_key" = {
        path = "${config.home.homeDirectory}/.config/openai/api_key";
        mode = "0600";
      };

      "github_token" = {
        path = "${config.home.homeDirectory}/.config/github/token";
        mode = "0600";
      };

      "npm_token" = {
        path = "${config.home.homeDirectory}/.npmrc-token";
        mode = "0600";
      };

      # SSH Keys (managed by ssh.nix, declared here)
      "ssh/id_ed25519" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };

      "ssh/raspberry" = {
        path = "${config.home.homeDirectory}/.ssh/raspberry";
        mode = "0600";
      };

      # Environment variables file (sourced by shell)
      "env_secrets" = {
        path = "${config.home.homeDirectory}/.config/secrets/env";
        mode = "0600";
      };
    };
  };

  # Source secrets as environment variables in Fish
  programs.fish.interactiveShellInit = ''
    # Load secrets from sops-managed file
    if test -f ~/.config/secrets/env
      source ~/.config/secrets/env
    end
  '';

  # Source secrets in Bash (for compatibility)
  programs.bash.initExtra = ''
    if [ -f ~/.config/secrets/env ]; then
      source ~/.config/secrets/env
    fi
  '';

  # Configure git to use encrypted GitHub token
  programs.git.settings = {
    credential = {
      helper = "store --file ${config.home.homeDirectory}/.config/github/token";
    };
  };

  # Create necessary directories
  home.activation.setupSecretsDirectories = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p ${config.home.homeDirectory}/.config/sops/age
    mkdir -p ${config.home.homeDirectory}/.config/anthropic
    mkdir -p ${config.home.homeDirectory}/.config/openai
    mkdir -p ${config.home.homeDirectory}/.config/github
    mkdir -p ${config.home.homeDirectory}/.config/secrets
  '';

  # Helper functions for managing secrets
  programs.fish.functions = {
    # Edit encrypted secrets file
    edit-secrets = {
      description = "Edit encrypted secrets with sops";
      body = ''
        set secrets_file ~/Projects/Gentleman.Dots/secrets/secrets.yaml
        set key_file ~/.config/sops/age/keys.txt
        if test -f $secrets_file
          env SOPS_AGE_KEY_FILE=$key_file sops $secrets_file
        else
          echo "Creating new secrets file..."
          echo "Creating with your age key..."
          env SOPS_AGE_KEY_FILE=$key_file sops $secrets_file
        end
      '';
    };

    # Show decrypted secrets (for debugging)
    show-secrets = {
      description = "Show decrypted secrets (use carefully!)";
      body = ''
        set secrets_file ~/Projects/Gentleman.Dots/secrets/secrets.yaml
        set key_file ~/.config/sops/age/keys.txt
        if test -f $secrets_file
          env SOPS_AGE_KEY_FILE=$key_file sops -d $secrets_file
        else
          echo "Secrets file not found: $secrets_file"
        end
      '';
    };

    # Rotate age key
    rotate-age-key = {
      description = "Generate new age key for secrets";
      body = ''
        set key_file ~/.config/sops/age/keys.txt
        if test -f $key_file
          echo "Backing up existing key..."
          cp $key_file $key_file.backup.(date +%Y%m%d_%H%M%S)
        end
        echo "Generating new age key..."
        age-keygen -o $key_file
        echo "New public key:"
        age-keygen -y $key_file
        echo ""
        echo "⚠️  Update .sops.yaml with this new public key!"
        echo "⚠️  Re-encrypt secrets: sops updatekeys secrets/secrets.yaml"
      '';
    };

    # Setup initial secrets infrastructure
    setup-secrets = {
      description = "Initialize secrets management infrastructure";
      body = "bash ~/Projects/Gentleman.Dots/setup-secrets.sh";
    };  };
}
