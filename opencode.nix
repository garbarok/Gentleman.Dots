{ pkgs, lib, ... }:

{
  # Install GitHub CLI and tools for Copilot authentication and OpenCode installation
  home.packages = [
    pkgs.gh
    pkgs.curl
    pkgs.gawk
    pkgs.gnutar
    pkgs.gzip
    pkgs.coreutils
    pkgs.unzip
  ];

  # Setup GitHub CLI
  programs.gh = {
    settings = {
      version = "1";
    };
  };

  # Add OpenCode to PATH for all shells
  home.sessionPath = [
    "$HOME/.opencode/bin"
  ];

  # Create OpenCode installation script for manual use
  home.file."bin/install-opencode" = {
    text = ''
      #!/usr/bin/env bash
      set -e

      OPENCODE_DIR="$HOME/.opencode"
      OPENCODE_BIN="$OPENCODE_DIR/bin/opencode"

      # Create required cache directories
      mkdir -p "$HOME/.cache/nvim/opencode"

      # Set PATH to include all required tools
      export PATH="${pkgs.unzip}/bin:${pkgs.curl}/bin:${pkgs.gawk}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:${pkgs.coreutils}/bin:${pkgs.gh}/bin:$PATH"

      # Check if OpenCode is already installed and working
      if [ -f "$OPENCODE_BIN" ] && "$OPENCODE_BIN" --version &>/dev/null; then
        INSTALLED_VERSION=$("$OPENCODE_BIN" --version 2>/dev/null | head -n1 || echo "unknown")
        echo "✅ OpenCode already installed: $INSTALLED_VERSION"
        read -p "Do you want to reinstall/update? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
          echo "Skipping OpenCode installation"
        else
          echo "🚀 Reinstalling OpenCode..."
          curl -fsSL https://opencode.ai/install | bash 
          if [ -f "$OPENCODE_BIN" ]; then
            INSTALLED_VERSION=$("$OPENCODE_BIN" --version 2>/dev/null | head -n1 || echo "unknown")
            echo "✅ OpenCode v$INSTALLED_VERSION installed successfully!"
          else
            echo "❌ OpenCode installation failed"
            exit 1
          fi
        fi
      else
        echo "🚀 Installing latest OpenCode..."
        curl -fsSL https://opencode.ai/install | bash 
        if [ -f "$OPENCODE_BIN" ]; then
          INSTALLED_VERSION=$("$OPENCODE_BIN" --version 2>/dev/null | head -n1 || echo "unknown")
          echo "✅ OpenCode v$INSTALLED_VERSION installed successfully!"
        else
          echo "❌ OpenCode installation failed"
          exit 1
        fi
      fi

      # Install GitHub Copilot extension if not present
      if ! gh extension list | grep -q "github/gh-copilot"; then
        echo "📦 Installing GitHub Copilot extension..."
        gh extension install github/gh-copilot
        echo "✅ GitHub Copilot extension installed!"
      else
        echo "✅ GitHub Copilot extension already installed"
      fi
      echo ""
      echo "🎉 OpenCode setup complete!"
      echo "Usage: opencode | opencode-config | gh auth status"
    '';
    executable = true;
  };

  # Auto-install OpenCode on home-manager activation
  home.activation.installOpenCode = lib.hm.dag.entryAfter ["linkGeneration"] ''
    echo "🔧 Setting up OpenCode..."

    OPENCODE_DIR="$HOME/.opencode"
    OPENCODE_BIN="$OPENCODE_DIR/bin/opencode"

    # Create required cache directories
    mkdir -p "$HOME/.cache/nvim/opencode"

    # Set PATH to include all required tools
    export PATH="${pkgs.unzip}/bin:${pkgs.curl}/bin:${pkgs.gawk}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:${pkgs.coreutils}/bin:${pkgs.gh}/bin:$PATH"

    # Check if OpenCode is already installed and working
    if [ -f "$OPENCODE_BIN" ] && "$OPENCODE_BIN" --version &>/dev/null; then
      INSTALLED_VERSION=$("$OPENCODE_BIN" --version 2>/dev/null | head -n1 || echo "unknown")
      echo "✅ OpenCode already installed: $INSTALLED_VERSION"
    else
      echo "🚀 Installing latest OpenCode..."
      curl -fsSL https://opencode.ai/install | bash 

      if [ -f "$OPENCODE_BIN" ]; then
        INSTALLED_VERSION=$("$OPENCODE_BIN" --version 2>/dev/null | head -n1 || echo "unknown")
        echo "✅ OpenCode v$INSTALLED_VERSION installed successfully!"
      else
        echo "❌ OpenCode installation failed"
      fi
    fi

    # Install GitHub Copilot extension if not present
    if ! gh extension list | grep -q "github/gh-copilot"; then
      echo "📦 Installing GitHub Copilot extension..."
      gh extension install github/gh-copilot || echo "⚠️  Extension install failed (might already be installed)"
      echo "✅ GitHub Copilot extension setup complete!"
    else
      echo "✅ GitHub Copilot extension already installed"
    fi
    echo ""
    echo "🎉 OpenCode setup complete!"
    echo "Usage: opencode | opencode-config | gh auth status"
  '';

  # Create OpenCode configuration file
  home.file.".config/opencode/opencode.json" = {
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      theme = "system";
      model = "github-copilot/claude-sonnet-4.5";
      autoupdate = true;
      agent = {
        code-reviewer = {
          description = "Reviews code for best practices and potential issues as the Gentleman";
          prompt = "Este GPT es un clon del usuario, un arquitecto líder frontend especializado en Angular y React, con experiencia en arquitectura limpia, arquitectura hexagonal y separación de lógica en aplicaciones escalables. Tiene un enfoque técnico pero práctico, con explicaciones claras y aplicables, siempre con ejemplos útiles para desarrolladores con conocimientos intermedios y avanzados.\n\nHabla con un tono profesional pero cercano, relajado y con un toque de humor inteligente. Evita formalidades excesivas y usa un lenguaje directo, técnico cuando es necesario, pero accesible. Su estilo es argentino, sin caer en clichés, y utiliza expresiones como 'buenas acá estamos' o 'dale que va' según el contexto.\n\nSus principales áreas de conocimiento incluyen:\n- Desarrollo frontend con Angular, React y gestión de estado avanzada (Redux, Signals, State Managers propios como Gentleman State Manager y GPX-Store).\n- Arquitectura de software con enfoque en Clean Architecture, Hexagonal Architecure y Scream Architecture.\n- Implementación de buenas prácticas en TypeScript, testing unitario y end-to-end.\n- Loco por la modularización, atomic design y el patrón contenedor presentacional \n- Herramientas de productividad como LazyVim, Tmux, Zellij, OBS y Stream Deck.\n- Mentoría y enseñanza de conceptos avanzados de forma clara y efectiva.\n- Liderazgo de comunidades y creación de contenido en YouTube, Twitch y Discord.\n\nA la hora de explicar un concepto técnico:\n1. Explica el problema que el usuario enfrenta.\n2. Propone una solución clara y directa, con ejemplos si aplica.\n3. Menciona herramientas o recursos que pueden ayudar.\n\nSi el tema es complejo, usa analogías prácticas, especialmente relacionadas con construcción y arquitectura. Si menciona una herramienta o concepto, explica su utilidad y cómo aplicarlo sin redundancias.\n\nAdemás, tiene experiencia en charlas técnicas y generación de contenido. Puede hablar sobre la importancia de la introspección, có...";
          model = "github-copilot/claude-sonnet-4";
          tools = {
            write = true;
            edit = true;
          };
        };
      };
    };
  };

  # Add aliases for all configured shells
  programs.fish.shellAliases.opencode-config = "nvim ~/.config/opencode/opencode.json";
  programs.zsh.shellAliases.opencode-config = "nvim ~/.config/opencode/opencode.json";
  programs.nushell.shellAliases.opencode-config = "nvim ~/.config/opencode/opencode.json";
}
