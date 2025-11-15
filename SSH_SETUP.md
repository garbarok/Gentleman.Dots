# Configuración SSH con Nix + sops

## Qué hace esto

Tu configuración SSH ahora está gestionada por Nix:

- ✅ **Archivo config**: Hosts definidos en [ssh.nix](ssh.nix)
- ✅ **Claves públicas**: Gestionadas por Nix (seguro commitear)
- ✅ **Claves privadas**: Encriptadas con sops en `secrets/secrets.yaml`

## Configuración Inicial

### 1. Aplicar la configuración Nix

```bash
cd ~/Projects/Gentleman.Dots
home-manager switch --flake .#darwin
```

Esto activa el módulo SSH pero aún no encripta las claves.

### 2. Configurar secrets con tus claves SSH

```bash
# Esto copia automáticamente tus claves SSH actuales
setup-secrets
```

El comando hace:
1. Genera clave age para encriptar
2. Crea `.sops.yaml` con tu clave pública
3. **Copia tus claves SSH privadas** de `~/.ssh/` al archivo de secrets
4. Encripta todo

### 3. Aplicar de nuevo para usar claves encriptadas

```bash
home-manager switch --flake .#darwin
```

Ahora tus claves SSH vienen del archivo encriptado.

## Cómo funciona

### Estructura de secrets/secrets.yaml

```yaml
# API keys...
anthropic_api_key: sk-ant-api03-xxxxx
github_token: ghp_xxxxx

# SSH Keys (privadas)
ssh:
  id_ed25519: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    tu_clave_privada_aqui
    -----END OPENSSH PRIVATE KEY-----

  raspberry: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    otra_clave_privada
    -----END OPENSSH PRIVATE KEY-----

# Environment variables...
```

### Qué va a git

✅ **Seguro commitear:**
- [ssh.nix](ssh.nix) - Configuración SSH (hosts, usuarios)
- `.ssh/id_ed25519.pub` - Claves públicas
- `.ssh/raspberry.pub` - Claves públicas
- `secrets/secrets.yaml` - **Encriptado**, seguro
- `.sops.yaml` - Solo claves públicas

❌ **NUNCA commitear:**
- `~/.config/sops/age/keys.txt` - Tu clave de desencriptación
- `~/.ssh/id_ed25519` - Ya está encriptado en secrets
- `~/.ssh/raspberry` - Ya está encriptado en secrets

## Hosts SSH Configurados

Según tu [ssh.nix](ssh.nix:22-52):

### garbarok (Raspberry Pi)
```bash
ssh garbarok
# Conecta a: 192.168.1.45
# Usuario: garbarok
# Clave: ~/.ssh/raspberry
```

### jenkins16
```bash
ssh jenkins16
# Conecta a: cuebuild16.stibo.corp
# Usuario: jenkins
```

### cue-branches (vía ProxyJump)
```bash
ssh cue-branches
# Conecta a: ece-cue-branches.rnd.cue.cloud
# Usuario: hudson
# Salta por: jenkins16
```

### github.com
```bash
git clone git@github.com:usuario/repo.git
# Usa: ~/.ssh/id_ed25519
# Integrado con macOS Keychain
```

## Agregar un nuevo host SSH

### Método 1: Editar ssh.nix (recomendado)

Edita [ssh.nix](ssh.nix) y agrega:

```nix
"mi-servidor" = {
  hostname = "192.168.1.100";
  user = "admin";
  identityFile = "~/.ssh/id_ed25519";
  extraOptions = {
    Port = "2222";
    StrictHostKeyChecking = "accept-new";
  };
};
```

Aplica:
```bash
nixswitch
```

### Método 2: SSH tradicional

Puedes seguir editando `~/.ssh/config` manualmente. Nix no lo sobrescribe, solo agrega configuración.

## Agregar una nueva clave SSH privada

Si generas una nueva clave SSH:

```bash
# 1. Generar la clave
ssh-keygen -t ed25519 -f ~/.ssh/mi_nueva_clave

# 2. Agregar a secrets
edit-secrets

# Agregar en la sección ssh:
# ssh:
#   mi_nueva_clave: |
#     -----BEGIN OPENSSH PRIVATE KEY-----
#     contenido de la clave privada
#     -----END OPENSSH PRIVATE KEY-----

# 3. Actualizar ssh.nix para declarar el secret
# Editar ssh.nix y agregar en sops.secrets:
"ssh/mi_nueva_clave" = {
  path = "${config.home.homeDirectory}/.ssh/mi_nueva_clave";
  mode = "0600";
};

# 4. Aplicar
nixswitch
```

## Características Avanzadas

### Control de conexiones persistentes

Configurado en [ssh.nix](ssh.nix:51-71):

```bash
# Las conexiones SSH se mantienen 10 minutos
# Nuevas conexiones reusan el socket
ls ~/.ssh/sockets/
# usuario@servidor:22
```

### Keepalive automático

```bash
# Ping cada 60 segundos para mantener conexión viva
# Útil para servidores con firewall agresivo
```

### Integración con macOS Keychain

```bash
# Las claves se cargan automáticamente en el keychain
# No necesitas escribir la contraseña cada vez
ssh-add -l  # Ver claves cargadas
```

## Troubleshooting

### Error: "Permission denied (publickey)"

```bash
# Verificar que la clave privada existe y tiene permisos correctos
ls -la ~/.ssh/id_ed25519
# Debe ser: -rw------- (600)

# Verificar que el secret está configurado
cat ~/.config/sops/age/keys.txt

# Re-aplicar configuración
nixswitch
```

### Error: "no such identity"

La clave privada no está en el lugar correcto.

```bash
# Ver dónde busca SSH
ssh -v garbarok

# Verificar paths en ssh.nix
grep IdentityFile ~/Projects/Gentleman.Dots/ssh.nix
```

### Clave no se carga en el agente

```bash
# Verificar servicio SSH agent (macOS)
ssh-add -l

# Cargar manualmente
ssh-add ~/.ssh/id_ed25519

# Agregar permanentemente (macOS)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Editar secrets sin setup-secrets

```bash
# Ver secrets encriptados
cat ~/Projects/Gentleman.Dots/secrets/secrets.yaml

# Editar (desencripta temporalmente)
edit-secrets

# Ver desencriptado (debug)
show-secrets
```

## Migración a otra máquina

### Opción A: Copiar clave age (mismo usuario)

```bash
# En máquina nueva
scp maquina-vieja:~/.config/sops/age/keys.txt ~/.config/sops/age/keys.txt

# Clonar dotfiles
git clone tu-repo Gentleman.Dots
cd Gentleman.Dots

# Aplicar
home-manager switch --flake .#darwin

# Tus claves SSH ya están disponibles
ssh garbarok  # Funciona inmediatamente
```

### Opción B: Nueva clave age (usuarios diferentes)

```bash
# 1. Generar nueva clave en máquina nueva
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt  # Copiar clave pública

# 2. En máquina vieja, agregar nueva clave a .sops.yaml
# y re-encriptar:
sops updatekeys secrets/secrets.yaml
git commit -am "Add new machine key"
git push

# 3. En máquina nueva, pull y aplicar
git pull
home-manager switch --flake .#darwin
```

## Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `ssh-add -l` | Ver claves cargadas en agente |
| `ssh -v host` | Conexión con debug verbose |
| `ssh-keygen -y -f ~/.ssh/id_ed25519` | Ver clave pública de una privada |
| `edit-secrets` | Editar secrets (incluye claves SSH) |
| `nixswitch` | Aplicar cambios de ssh.nix |

## Backup Manual

Aunque las claves están en secrets encriptado, puedes hacer backup:

```bash
# Backup de clave age (crítico)
cp ~/.config/sops/age/keys.txt ~/Documents/age-key-backup.txt

# Guardar en lugar seguro (USB, password manager, etc.)
```

⚠️ **Sin esta clave no podrás desencriptar tus secrets**

## Próximos Pasos

1. ✅ Ejecuta `setup-secrets` para encriptar tus claves SSH
2. ✅ Verifica que funciona: `ssh garbarok`
3. ✅ Commitea los cambios:
   ```bash
   git add .sops.yaml secrets/secrets.yaml ssh.nix
   git commit -m "feat: add SSH configuration with encrypted keys"
   ```
4. ✅ (Opcional) Haz backup de `~/.config/sops/age/keys.txt`

¿Necesitas ayuda? Revisa [SECRETS_SETUP.md](SECRETS_SETUP.md) para más detalles sobre sops.
