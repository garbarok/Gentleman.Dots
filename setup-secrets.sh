#!/usr/bin/env bash
set -e

echo "🔐 Setting up secrets management..."

# Create sops directory if it doesn't exist
mkdir -p ~/.config/sops/age

# Generate age key if it doesn't exist
if [ ! -f ~/.config/sops/age/keys.txt ]; then
  echo "Generating age key..."
  age-keygen -o ~/.config/sops/age/keys.txt
fi

# Show public key
pubkey=$(age-keygen -y ~/.config/sops/age/keys.txt)
echo "Your age public key: $pubkey"

# Create .sops.yaml if it doesn't exist
if [ ! -f ~/Projects/Gentleman.Dots/.sops.yaml ]; then
  echo "Creating .sops.yaml configuration..."
  cat > ~/Projects/Gentleman.Dots/.sops.yaml <<EOF
# sops configuration file
# Documentation: https://github.com/getsops/sops

keys:
  - &admin $pubkey

creation_rules:
  - path_regex: secrets/secrets\\.yaml\$
    key_groups:
      - age:
          - *admin
EOF
  echo "✅ Created .sops.yaml"
fi

# Create secrets directory
mkdir -p ~/Projects/Gentleman.Dots/secrets

# Create template secrets file if it doesn't exist
if [ ! -f ~/Projects/Gentleman.Dots/secrets/secrets.yaml ]; then
  echo "Creating template secrets file..."

  # Read existing SSH keys if they exist
  ssh_id_ed25519=""
  ssh_raspberry=""

  if [ -f ~/.ssh/id_ed25519 ]; then
    ssh_id_ed25519=$(cat ~/.ssh/id_ed25519)
  fi

  if [ -f ~/.ssh/raspberry ]; then
    ssh_raspberry=$(cat ~/.ssh/raspberry)
  fi

  # Create secrets file
  cat > ~/Projects/Gentleman.Dots/secrets/secrets.yaml <<EOF
# Anthropic API key for Claude
anthropic_api_key: your_anthropic_key_here

# OpenAI API key
openai_api_key: your_openai_key_here

# GitHub personal access token
github_token: your_github_token_here

# NPM registry token
npm_token: your_npm_token_here

# SSH Keys (private keys - will be encrypted)
ssh:
  id_ed25519: |
$(echo "$ssh_id_ed25519" | sed 's/^/    /')
  raspberry: |
$(echo "$ssh_raspberry" | sed 's/^/    /')

# Environment variables (these will be sourced in shell)
env_secrets: |
  export ANTHROPIC_API_KEY=your_anthropic_key_here
  export OPENAI_API_KEY=your_openai_key_here
  export GITHUB_TOKEN=your_github_token_here
  export NPM_TOKEN=your_npm_token_here
EOF
  echo "Encrypting secrets file..."
  sops -e -i ~/Projects/Gentleman.Dots/secrets/secrets.yaml
  echo "✅ Created and encrypted secrets file"
fi

echo ""
echo "✅ Secrets setup complete!"
echo ""
echo "Next steps:"
echo "  1. Edit secrets: edit-secrets"
echo "  2. Commit encrypted files: git add .sops.yaml secrets/secrets.yaml"
echo "  3. Run: home-manager switch --flake .#darwin"
