# Cómo Funciona la Encriptación de Secrets

## ¿Qué es la "contraseña"?

**No es una contraseña tradicional**. El sistema usa **criptografía de clave pública/privada** con la herramienta `age`:

- **Clave privada** (la "contraseña"): `~/.config/sops/age/keys.txt`
- **Clave pública**: Se extrae de la privada y se guarda en `.sops.yaml` (segura para git)

## Cómo Funciona

```
┌─────────────────────────────────────────┐
│  1. Generas un par de claves age        │
│     (público + privada)                  │
└──────────────────┬──────────────────────┘
                   │
                   v
┌─────────────────────────────────────────┐
│  2. La clave PÚBLICA va a .sops.yaml    │
│     (segura para commitear a git)       │
└──────────────────┬──────────────────────┘
                   │
                   v
┌─────────────────────────────────────────┐
│  3. sops encripta secrets.yaml con      │
│     la clave pública                     │
└──────────────────┬──────────────────────┘
                   │
                   v
┌─────────────────────────────────────────┐
│  4. Solo quien tenga la clave PRIVADA   │
│     puede desencriptar                   │
└─────────────────────────────────────────┘
```

## Tu Clave Privada

### Ubicación
```bash
~/.config/sops/age/keys.txt
```

### Ver tu clave privada
```bash
cat ~/.config/sops/age/keys.txt
```

Verás algo como:
```
# created: 2024-01-15T10:30:00Z
# public key: age1k7eu04pef5m6s54d320uewzjjp39u3ut7qj9yu4x88ejqrdwgcdqexzv4s
AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Ver solo la clave pública
```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

## Migrar a Otro Ordenador

### Opción 1: Copiar la Clave Privada (Mismo Usuario)

**Ventaja**: Más simple, funciona inmediatamente
**Desventaja**: Si pierdes la clave, pierdes acceso a todos tus secrets

```bash
# En el ordenador VIEJO
# 1. Hacer backup de la clave privada
cp ~/.config/sops/age/keys.txt ~/age-key-backup.txt

# 2. Copiar a USB, email personal, o password manager
# ⚠️ NUNCA la subas a git o servicios públicos

# En el ordenador NUEVO
# 1. Crear directorio
mkdir -p ~/.config/sops/age

# 2. Copiar la clave privada
# (desde USB, email, password manager, etc.)
cat > ~/.config/sops/age/keys.txt <<EOF
# pegar contenido de la clave privada aquí
EOF

# 3. Permisos correctos
chmod 600 ~/.config/sops/age/keys.txt

# 4. Clonar dotfiles y aplicar
git clone https://github.com/tu-usuario/Gentleman.Dots.git ~/Projects/Gentleman.Dots
cd ~/Projects/Gentleman.Dots
home-manager switch --flake .#darwin

# ✅ Tus secrets ya están disponibles y desencriptados
show-secrets  # Funciona inmediatamente
```

### Opción 2: Generar Nueva Clave (Múltiples Usuarios)

**Ventaja**: Cada máquina tiene su propia clave, más seguro
**Desventaja**: Requiere re-encriptar secrets con ambas claves

```bash
# En el ordenador NUEVO
# 1. Generar nueva clave age
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# 2. Copiar la clave pública que se muestra
age-keygen -y ~/.config/sops/age/keys.txt
# Resultado: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# En el ordenador VIEJO
# 1. Editar .sops.yaml y agregar la nueva clave pública
cd ~/Projects/Gentleman.Dots
edit .sops.yaml

# Agregar en la sección keys:
# keys:
#   - &admin age1k7eu04pef5m6s54d320uewzjjp39u3ut7qj9yu4x88ejqrdwgcdqexzv4s  # Vieja
#   - &laptop age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  # Nueva

# Y en creation_rules:
# creation_rules:
#   - path_regex: secrets/secrets\.yaml$
#     key_groups:
#       - age:
#           - *admin
#           - *laptop

# 2. Re-encriptar el archivo de secrets con ambas claves
sops updatekeys secrets/secrets.yaml

# 3. Commitear y pushear
git add .sops.yaml secrets/secrets.yaml
git commit -m "feat: add laptop age key"
git push

# En el ordenador NUEVO
# 1. Pull cambios
cd ~/Projects/Gentleman.Dots
git pull

# 2. Aplicar configuración
home-manager switch --flake .#darwin

# ✅ Ahora ambas máquinas pueden desencriptar
show-secrets  # Funciona en ambas máquinas
```

## Seguridad

### ✅ Seguro para Git
- `.sops.yaml` - Solo claves públicas
- `secrets/secrets.yaml` - Encriptado con age
- [ssh.nix](ssh.nix) - Configuración sin secretos

### ❌ NUNCA Commitear
- `~/.config/sops/age/keys.txt` - Clave privada
- `secrets/*.key` - Claves sin encriptar
- `secrets/decrypted/*` - Backups desencriptados

### 🔒 Dónde Guardar la Clave Privada

**Recomendaciones**:
1. **Password Manager** (1Password, Bitwarden): Como "Secure Note"
2. **USB Encriptado**: Físicamente seguro
3. **Backup Encriptado**: En iCloud/Dropbox dentro de archivo .zip con contraseña
4. **Papel**: Para recovery extremo (guardar en lugar seguro físico)

**Evitar**:
- Email no encriptado
- Servicios de notas no encriptados (Notion, Google Docs)
- Disco duro sin encriptar
- Screenshots

## Comandos Útiles

```bash
# Ver secrets desencriptados
show-secrets

# Editar secrets (abre editor, auto-encripta al salir)
edit-secrets

# Ver tu clave pública
age-keygen -y ~/.config/sops/age/keys.txt

# Ver las claves públicas autorizadas
cat ~/Projects/Gentleman.Dots/.sops.yaml

# Generar nueva clave (backup la vieja primero!)
rotate-age-key

# Verificar que sops puede desencriptar
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops -d ~/Projects/Gentleman.Dots/secrets/secrets.yaml
```

## Troubleshooting

### Error: "no identity matched any of the recipients"

**Problema**: sops no encuentra tu clave privada

**Solución**:
```bash
# 1. Verificar que existe
ls -la ~/.config/sops/age/keys.txt

# 2. Verificar permisos (debe ser 600)
chmod 600 ~/.config/sops/age/keys.txt

# 3. Verificar que tu clave pública está en .sops.yaml
age-keygen -y ~/.config/sops/age/keys.txt
cat ~/Projects/Gentleman.Dots/.sops.yaml
# Las claves deben coincidir

# 4. Si no coinciden, necesitas la clave privada original
# o re-encriptar con tu nueva clave (perderás acceso a secrets actuales)
```

### Perdí mi Clave Privada

**Si tienes backup**: Restaura desde backup (ver Opción 1 arriba)

**Si NO tienes backup**:
```bash
# 1. Generar nueva clave
age-keygen -o ~/.config/sops/age/keys.txt

# 2. Actualizar .sops.yaml con la nueva clave pública
age-keygen -y ~/.config/sops/age/keys.txt  # Copiar resultado
# Editar .sops.yaml y reemplazar clave pública

# 3. Crear NUEVO archivo de secrets (el viejo es irrecuperable)
# Tendrás que volver a introducir todas las API keys, SSH keys, etc.
edit-secrets
```

⚠️ **Por eso es crítico hacer backup de la clave privada**

### Rotar Clave Age (por seguridad)

```bash
# 1. Backup de clave actual
cp ~/.config/sops/age/keys.txt ~/age-key-OLD-$(date +%Y%m%d).txt

# 2. Backup de secrets desencriptados (para re-encriptar después)
show-secrets > ~/secrets-backup.yaml

# 3. Generar nueva clave
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt  # Copiar clave pública

# 4. Actualizar .sops.yaml con nueva clave pública
# Editar .sops.yaml y reemplazar la clave

# 5. Re-encriptar secrets
# Opción A: Editar manualmente
edit-secrets  # Copiar contenido de ~/secrets-backup.yaml

# Opción B: Re-encriptar archivo existente
cp ~/secrets-backup.yaml ~/Projects/Gentleman.Dots/secrets/secrets.yaml
sops -e -i ~/Projects/Gentleman.Dots/secrets/secrets.yaml

# 6. Verificar
show-secrets

# 7. Destruir backups no encriptados
shred -u ~/secrets-backup.yaml  # Linux
rm -P ~/secrets-backup.yaml     # macOS
```

## Próximos Pasos

1. **Hacer backup de tu clave privada AHORA**:
   ```bash
   cp ~/.config/sops/age/keys.txt ~/Desktop/age-key-backup-$(date +%Y%m%d).txt
   # Guardarlo en password manager o USB encriptado
   ```

2. **Añadir tus secrets reales**:
   ```bash
   edit-secrets
   # Reemplazar PLACEHOLDER con tus API keys reales
   ```

3. **Aplicar cambios**:
   ```bash
   nixswitch
   # Tus secrets se desencriptan automáticamente a ~/.config/*/
   ```

4. **Verificar que funciona**:
   ```bash
   # Ver variables de entorno
   echo $ANTHROPIC_API_KEY

   # SSH debe funcionar con claves desencriptadas
   ssh garbarok
   ```

## Referencias

- [age - Encryption Tool](https://github.com/FiloSottile/age)
- [sops - Secrets OPerationS](https://github.com/getsops/sops)
- [sops-nix - Nix Integration](https://github.com/Mic92/sops-nix)
