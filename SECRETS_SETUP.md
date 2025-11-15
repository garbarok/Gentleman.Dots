# Configuración de Secretos con sops-nix

## Instalación Rápida

```bash
# 1. Aplicar la configuración (instala sops y age)
cd ~/Projects/Gentleman.Dots
home-manager switch --flake .#darwin

# 2. Configurar secretos automáticamente
setup-secrets

# 3. Editar tus secretos
edit-secrets
```

## Configuración Manual Detallada

### Paso 1: Generar clave age

```bash
# Crear directorio
mkdir -p ~/.config/sops/age

# Generar clave privada
age-keygen -o ~/.config/sops/age/keys.txt

# Ver tu clave pública (la necesitarás)
age-keygen -y ~/.config/sops/age/keys.txt
```

**Salida ejemplo:**
```
age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
```

### Paso 2: Crear .sops.yaml

Crea este archivo en la raíz de Gentleman.Dots:

```yaml
# .sops.yaml
keys:
  - &admin age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p  # TU clave pública

creation_rules:
  - path_regex: secrets/secrets\.yaml$
    key_groups:
      - age:
          - *admin
```

**⚠️ Reemplaza la clave con la tuya del paso 1**

### Paso 3: Crear archivo de secretos

```bash
# Crear directorio
mkdir -p ~/Projects/Gentleman.Dots/secrets

# Crear archivo sin encriptar (temporal)
cat > ~/Projects/Gentleman.Dots/secrets/secrets.yaml << 'EOF'
# Anthropic API key para Claude
anthropic_api_key: sk-ant-api03-xxxxx

# OpenAI API key (si usas ChatGPT/Copilot)
openai_api_key: sk-xxxxx

# GitHub personal access token
github_token: ghp_xxxxx

# NPM registry token
npm_token: npm_xxxxx

# Variables de entorno (se cargan en la shell)
env_secrets: |
  export ANTHROPIC_API_KEY=sk-ant-api03-xxxxx
  export OPENAI_API_KEY=sk-xxxxx
  export GITHUB_TOKEN=ghp_xxxxx
  export NPM_TOKEN=npm_xxxxx
EOF
```

### Paso 4: Encriptar el archivo

```bash
cd ~/Projects/Gentleman.Dots

# Encriptar en el lugar
sops -e -i secrets/secrets.yaml

# Ahora está encriptado y seguro para git
```

**Después de encriptar, el archivo se ve así:**
```yaml
anthropic_api_key: ENC[AES256_GCM,data:XwE=,iv:xxx,tag:xxx,type:str]
openai_api_key: ENC[AES256_GCM,data:YzQ=,iv:xxx,tag:xxx,type:str]
# ... resto encriptado
```

### Paso 5: Aplicar configuración

```bash
# Home Manager desencriptará los secretos automáticamente
home-manager switch --flake .#darwin
```

Los secretos desencriptados estarán en:
- `~/.config/anthropic/api_key`
- `~/.config/openai/api_key`
- `~/.config/github/token`
- `~/.npmrc-token`
- `~/.config/secrets/env` (variables de entorno)

## Uso Diario

### Editar secretos

```bash
# sops abre el archivo desencriptado en tu editor
edit-secrets

# O manualmente:
sops ~/Projects/Gentleman.Dots/secrets/secrets.yaml
```

sops desencripta temporalmente, te permite editar, y re-encripta al guardar.

### Ver secretos (debugging)

```bash
# Ver contenido desencriptado
show-secrets

# O manualmente:
sops -d ~/Projects/Gentleman.Dots/secrets/secrets.yaml
```

### Usar secretos en tu shell

Las variables se cargan automáticamente en Fish:

```bash
# Verificar que están cargadas
echo $ANTHROPIC_API_KEY
echo $GITHUB_TOKEN
```

## Seguridad

### ✅ SEGURO para git (commitear)
- `.sops.yaml` (solo claves públicas)
- `secrets/secrets.yaml` (encriptado)

### ❌ NUNCA commitear
- `~/.config/sops/age/keys.txt` (clave privada)
- `secrets/secrets.yaml` antes de encriptar
- Cualquier archivo `.key` o `.txt` en `secrets/`

Ya está en tu `.gitignore`:
```gitignore
# Secrets management
.config/sops/age/keys.txt
secrets/*.key
secrets/*.txt
secrets/decrypted/
```

## Trabajo en Equipo

### Agregar otro desarrollador

1. El nuevo dev genera su clave:
```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

2. Agregas su clave pública a `.sops.yaml`:
```yaml
keys:
  - &admin_ogs age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
  - &admin_otro age1abc123...otra_clave_publica

creation_rules:
  - path_regex: secrets/secrets\.yaml$
    key_groups:
      - age:
          - *admin_ogs
          - *admin_otro  # Ahora ambos pueden desencriptar
```

3. Re-encriptar con las nuevas claves:
```bash
sops updatekeys secrets/secrets.yaml
```

### Múltiples máquinas (mismo usuario)

#### Opción A: Copiar clave privada
```bash
# En máquina nueva
scp maquina-vieja:~/.config/sops/age/keys.txt ~/.config/sops/age/keys.txt
```

#### Opción B: Nueva clave por máquina
```bash
# Generar nueva clave en máquina nueva
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt  # Copiar clave pública

# Agregar a .sops.yaml y re-encriptar
sops updatekeys secrets/secrets.yaml
```

## Rotar claves

Si tu clave privada se compromete:

```bash
# 1. Generar nueva clave
rotate-age-key

# 2. Actualizar .sops.yaml con la nueva clave pública

# 3. Re-encriptar secretos
cd ~/Projects/Gentleman.Dots
sops updatekeys secrets/secrets.yaml

# 4. Aplicar cambios
nixswitch
```

## Troubleshooting

### Error: "no key found"

```bash
# Verificar que existe la clave privada
ls -la ~/.config/sops/age/keys.txt

# Verificar que .sops.yaml tiene tu clave pública correcta
cat .sops.yaml

# Regenerar si es necesario
setup-secrets
```

### Error: "failed to decrypt"

```bash
# La clave privada no corresponde con el archivo encriptado
# Opciones:
# 1. Re-encriptar con tu clave actual
sops updatekeys secrets/secrets.yaml

# 2. O pedir el archivo desencriptado a un compañero y re-encriptarlo
```

### Variables de entorno no se cargan

```bash
# Verificar que el archivo existe
ls -la ~/.config/secrets/env

# Verificar contenido
cat ~/.config/secrets/env

# Cargar manualmente (debug)
source ~/.config/secrets/env

# Recargar fish
exec fish
```

## Ejemplo Completo de Flujo

```bash
# Setup inicial (una sola vez)
cd ~/Projects/Gentleman.Dots
home-manager switch --flake .#darwin
setup-secrets

# Editar secretos (primera vez)
edit-secrets
# Editor se abre, agregar:
#   anthropic_api_key: sk-ant-api03-tu_clave_real_aqui
#   github_token: ghp_tu_token_aqui
# Guardar y cerrar

# Aplicar
nixswitch

# Verificar
echo $ANTHROPIC_API_KEY  # Debe mostrar tu clave
claude --version          # Claude CLI debe funcionar

# Git workflow
git add .sops.yaml secrets/secrets.yaml
git commit -m "chore: add encrypted secrets"
git push

# En otra máquina
git clone tu-repo
cd Gentleman.Dots
# Copiar tu clave privada o generar nueva (ver arriba)
home-manager switch --flake .#darwin
# Tus secretos están disponibles automáticamente
```

## Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `setup-secrets` | Setup inicial completo |
| `edit-secrets` | Editar secretos encriptados |
| `show-secrets` | Ver secretos desencriptados |
| `rotate-age-key` | Generar nueva clave |
| `sops updatekeys secrets/secrets.yaml` | Re-encriptar con nuevas claves |

## Próximos Pasos

Una vez configurado:

1. ✅ Edita tus secretos con `edit-secrets`
2. ✅ Verifica que las variables se cargan: `echo $ANTHROPIC_API_KEY`
3. ✅ Commitea los archivos encriptados a git
4. ✅ Usa Claude CLI: `claude "hello"`
5. ✅ Los secretos estarán disponibles en todos tus proyectos

¿Necesitas más ayuda? Ejecuta `setup-secrets` y te guiará por el proceso.
