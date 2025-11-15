# Guía de tmux para Novatos

## ¿Qué es tmux?

**tmux** (Terminal Multiplexer) te permite:
- Tener **múltiples terminales** en una sola ventana
- **Dividir la pantalla** en paneles (panes)
- **Sesiones persistentes** que sobreviven si cierras la terminal
- **Navegación rápida** entre paneles y ventanas

Tu configuración está integrada con **Ghostty** y **Neovim** para navegación fluida.

---

## Tu Configuración Actual

### Prefix Key (Tecla Principal)
- **Por defecto tmux**: `Ctrl+b`
- **Tu configuración**: `Ctrl+a` (más ergonómico)

Todas las combinaciones empiezan con `Ctrl+a` seguido de otra tecla.

---

## Atajos Esenciales (Nivel Básico)

### 🎯 Dividir Pantalla (Splits)

| Acción | Atajo | Ghostty Directo |
|--------|-------|----------------|
| **Dividir vertical** (lado a lado) | `Ctrl+a` luego `v` | `Alt+v` |
| **Dividir horizontal** (arriba/abajo) | `Ctrl+a` luego `s` | `Alt+d` |

**Nota**: Los atajos de Ghostty (`Alt+v` / `Alt+d`) funcionan **sin necesidad de prefix**.

### 🧭 Navegar Entre Paneles

| Acción | Ghostty | tmux + Neovim |
|--------|---------|---------------|
| **Ir arriba** | `Alt+k` | `Ctrl+k` (funciona en tmux y nvim) |
| **Ir abajo** | `Alt+j` | `Ctrl+j` |
| **Ir izquierda** | `Alt+h` | `Ctrl+h` |
| **Ir derecha** | `Alt+l` | `Ctrl+l` |

**Plugin instalado**: `vim-tmux-navigator` - Navega entre Neovim y tmux sin pensar.

### 📏 Redimensionar Paneles

| Acción | Atajo |
|--------|-------|
| **Expandir arriba** | `Ctrl+Shift+j` |
| **Expandir abajo** | `Ctrl+Shift+k` |
| **Expandir izquierda** | `Ctrl+Shift+h` |
| **Expandir derecha** | `Ctrl+Shift+l` |

### 🗑️ Cerrar Panel/Ventana

| Acción | Atajo |
|--------|-------|
| **Cerrar panel actual** | `exit` o `Ctrl+d` |
| **Desconectar sesión (detach)** | `Ctrl+a` luego `d` |
| **Cerrar ventana** | `Ctrl+a` luego `&` |
| **Matar TODAS las sesiones menos la actual** | `Ctrl+a` luego `K` (mayúscula) |

---

## Atajos Nivel Intermedio

### 🪟 Ventanas (Windows)

Las ventanas son como pestañas del navegador.

| Acción | Atajo |
|--------|-------|
| **Nueva ventana** | `Ctrl+a` luego `c` |
| **Siguiente ventana** | `Ctrl+a` luego `n` |
| **Ventana anterior** | `Ctrl+a` luego `p` |
| **Ir a ventana #** | `Ctrl+a` luego `0-9` |
| **Renombrar ventana** | `Ctrl+a` luego `,` |
| **Listar todas las ventanas** | `Ctrl+a` luego `w` |

### 📋 Modo Copia (Copy Mode)

Puedes copiar texto con el teclado (modo Vim):

| Acción | Atajo |
|--------|-------|
| **Entrar modo copia** | `Ctrl+a` luego `[` |
| **Mover cursor** | `h j k l` (como Vim) |
| **Empezar selección** | `v` |
| **Copiar selección** | `y` (copia al clipboard) |
| **Salir modo copia** | `q` o `Esc` |
| **Pegar** | `Ctrl+a` luego `]` |

**Plugin instalado**: `tmux-yank` - Copia automáticamente al portapapeles del sistema.

### 🔍 Buscar en Panel

| Acción | Atajo |
|--------|-------|
| **Buscar hacia arriba** | `Ctrl+a` luego `[` luego `/` |
| **Siguiente resultado** | `n` |
| **Resultado anterior** | `N` |

---

## Atajos Avanzados

### 💾 Sesiones (Sessions)

Las sesiones permiten guardar tu workspace completo.

| Acción | Comando | Atajo |
|--------|---------|-------|
| **Crear sesión nueva** | `tmux new -s nombre` | - |
| **Listar sesiones** | `tmux ls` | `Ctrl+a` luego `s` |
| **Desconectar (detach)** | - | `Ctrl+a` luego `d` |
| **Reconectar** | `tmux attach -t nombre` | - |
| **Matar sesión** | `tmux kill-session -t nombre` | - |
| **Cambiar sesión** | - | `Ctrl+a` luego `s` |

**Plugin instalado**: `tmux-resurrect` - Guarda tus sesiones incluso después de reiniciar.

#### Guardar/Restaurar Sesiones con tmux-resurrect

| Acción | Atajo |
|--------|-------|
| **Guardar sesión actual** | `Ctrl+a` luego `Ctrl+s` |
| **Restaurar última sesión guardada** | `Ctrl+a` luego `Ctrl+r` |

### 🎭 Ventana Flotante (Scratch Session)

Tu configuración tiene una **sesión flotante** tipo dropdown terminal.

| Acción | Atajo |
|--------|-------|
| **Abrir/cerrar ventana flotante** | `Alt+g` (sin prefix!) |

Esta ventana flotante:
- Se llama `scratch`
- Se mantiene entre aperturas
- Perfecto para comandos rápidos sin perder contexto

### ❓ Ayuda Interactiva (Which-Key)

**Plugin instalado**: `tmux-which-key`

| Acción | Atajo |
|--------|-------|
| **Ver todos los atajos disponibles** | `Ctrl+a` luego `?` |

Esto muestra una lista interactiva de TODOS los comandos tmux disponibles.

---

## Características Especiales de Tu Config

### 🐭 Mouse Habilitado
Puedes usar el mouse para:
- **Clic en panel** para enfocarlo
- **Arrastrar borde** para redimensionar
- **Scroll** para subir/bajar en el historial
- **Clic en ventana** (status bar) para cambiar

### 🎨 Tema Kanagawa
Tu status bar tiene:
- **Estado de Git** del directorio actual
- **Uso de CPU**
- **Uso de RAM**
- **Posición arriba** (más ergonómico)

### 📁 Splits Inteligentes
Cuando creas un nuevo panel, se abre en el **mismo directorio** del panel actual.

---

## Flujo de Trabajo Recomendado

### Setup Básico para Proyectos

```bash
# 1. Crear sesión para el proyecto
tmux new -s mi-proyecto

# 2. Renombrar ventana principal
# Ctrl+a , luego escribir "editor"

# 3. Dividir pantalla (editor + terminal)
# Alt+v (divide vertical)

# 4. En el panel derecho, dividir horizontal para tests
# Alt+d

# Ahora tienes:
# ┌─────────────┬─────────┐
# │             │ Shell   │
# │   Editor    ├─────────┤
# │   (nvim)    │ Tests   │
# └─────────────┴─────────┘
```

### Workflow con Nx Monorepo

```bash
# Terminal principal
tmux new -s nx-project

# Panel 1: Editor
nvim

# Panel 2: Dev server (Alt+v para dividir)
pnpm nx serve my-app

# Panel 3: Tests en watch mode (Alt+d para dividir abajo)
pnpm nx test my-lib --watch

# Navega entre ellos con Alt+h/j/k/l
```

### Proyecto con Múltiples Servicios

```bash
# Ventana 1: Frontend
# Ctrl+a c (nueva ventana)
cd frontend
pnpm dev

# Ventana 2: Backend
# Ctrl+a c (nueva ventana)
cd backend
npm start

# Ventana 3: Editor
# Ctrl+a c (nueva ventana)
nvim

# Cambiar entre ventanas: Ctrl+a 0/1/2/3
```

---

## Comandos CLI Útiles

```bash
# Ver todas las sesiones
tmux ls

# Crear sesión nombrada
tmux new -s proyecto

# Reconectar a sesión
tmux attach -t proyecto
# O abreviado:
tmux a -t proyecto

# Matar sesión
tmux kill-session -t proyecto

# Matar TODAS las sesiones
tmux kill-server

# Recargar configuración (después de editar tmux.conf)
tmux source ~/.config/tmux/tmux.conf
# O dentro de tmux:
# Ctrl+a luego :source ~/.config/tmux/tmux.conf
```

---

## Integración con Fish Shell

Tu fish shell está configurado para **iniciar tmux automáticamente**:

```fish
# En fish.nix (línea 37):
if not set -q TMUX; and not set -q ZED_TERMINAL
    tmux
end
```

Esto significa:
- ✅ Si no estás en tmux → Se inicia automáticamente
- ✅ Si abres desde Zed → No inicia tmux (evita nested sessions)

### Desactivar Auto-Start (Si Quieres)

Si no quieres que tmux se inicie automáticamente:

```bash
# Editar fish.nix y comentar las líneas 37-39
nixswitch
```

---

## Troubleshooting

### Error: "sessions should be nested with care"

Estás intentando iniciar tmux dentro de tmux.

```bash
# Ver si ya estás en tmux
echo $TMUX

# Salir de tmux actual
exit
# O desconectar sin cerrar:
# Ctrl+a d
```

### Colores se ven mal

```bash
# Verificar TERM
echo $TERM
# Debería ser: tmux-256color

# Si no, agregar a fish.nix:
set -gx TERM tmux-256color
```

### Plugins no cargan

```bash
# Instalar plugins manualmente
# Dentro de tmux:
# Ctrl+a I (mayúscula i)

# O reinstalar TPM
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Reiniciar tmux
```

### Navegación Neovim ↔ tmux no funciona

```bash
# Verificar que el plugin está instalado en Neovim
# Abrir nvim y ejecutar:
:Lazy

# Buscar: vim-tmux-navigator
# Debería estar instalado

# Si no, el plugin se instala automáticamente con nixswitch
```

---

## Cheatsheet Rápido (Imprimir/Guardar)

```
┌────────────────────────────────────────────────────────────┐
│                    TMUX CHEATSHEET                         │
│                  Prefix: Ctrl+a                            │
├────────────────────────────────────────────────────────────┤
│ SPLITS                                                     │
│   Alt+v         Dividir vertical (sin prefix)              │
│   Alt+d         Dividir horizontal (sin prefix)            │
│   Ctrl+a v      Dividir vertical (con prefix)              │
│   Ctrl+a s      Dividir horizontal (con prefix)            │
│   Alt+h/j/k/l   Navegar entre paneles                      │
│   Alt+g         Ventana flotante (scratch)                 │
├────────────────────────────────────────────────────────────┤
│ VENTANAS                                                   │
│   Ctrl+a c      Nueva ventana                              │
│   Ctrl+a n      Siguiente ventana                          │
│   Ctrl+a p      Ventana anterior                           │
│   Ctrl+a 0-9    Ir a ventana #                             │
│   Ctrl+a ,      Renombrar ventana                          │
│   Ctrl+a w      Listar ventanas                            │
├────────────────────────────────────────────────────────────┤
│ SESIONES                                                   │
│   Ctrl+a d      Desconectar (detach) ⭐                     │
│   Ctrl+a s      Listar/cambiar sesión                      │
│   Ctrl+a K      Matar todas las sesiones excepto actual    │
│   Ctrl+a Ctrl+s Guardar sesión (resurrect)                 │
│   Ctrl+a Ctrl+r Restaurar sesión                           │
├────────────────────────────────────────────────────────────┤
│ REDIMENSIONAR                                              │
│   Ctrl+Shift+h  Expandir izquierda                         │
│   Ctrl+Shift+j  Expandir arriba                            │
│   Ctrl+Shift+k  Expandir abajo                             │
│   Ctrl+Shift+l  Expandir derecha                           │
├────────────────────────────────────────────────────────────┤
│ MODO COPIA                                                 │
│   Ctrl+a [      Entrar modo copia                          │
│   v             Iniciar selección                          │
│   y             Copiar (yank)                              │
│   q / Esc       Salir modo copia                           │
│   Ctrl+a ]      Pegar                                      │
├────────────────────────────────────────────────────────────┤
│ AYUDA                                                      │
│   Ctrl+a ?      Ver todos los atajos (which-key)           │
└────────────────────────────────────────────────────────────┘
```

---

## Recursos Adicionales

- **tmux libro**: [The Tao of tmux](https://leanpub.com/the-tao-of-tmux/read)
- **Config oficial**: [~/.config/tmux/tmux.conf](file:///Users/ogs/.config/tmux/tmux.conf)
- **Plugins instalados**:
  - [tpm](https://github.com/tmux-plugins/tpm) - Plugin manager
  - [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) - Defaults sensatos
  - [tmux-yank](https://github.com/tmux-plugins/tmux-yank) - Copia mejorada
  - [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) - Navegación con Vim
  - [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) - Guardar/restaurar sesiones
  - [tmux-which-key](https://github.com/alexwforsythe/tmux-which-key) - Ayuda interactiva
  - [tmux-kanagawa](https://github.com/Nybkox/tmux-kanagawa) - Tema

---

## Práctica Recomendada (5 minutos)

1. **Abre tmux**:
   ```bash
   tmux new -s practica
   ```

2. **Divide la pantalla**:
   - `Alt+v` (vertical)
   - `Alt+d` (horizontal en el panel derecho)

3. **Navega entre paneles**:
   - `Alt+h/j/k/l` (prueba moverte entre los 3 paneles)

4. **Redimensiona**:
   - `Ctrl+Shift+l` (expandir panel izquierdo)

5. **Crea una ventana nueva**:
   - `Ctrl+a c`
   - Escribe `echo "Ventana 2"`
   - `Ctrl+a n` (volver a ventana 1)

6. **Prueba ventana flotante**:
   - `Alt+g` (abrir)
   - `Alt+g` (cerrar)

7. **Desconecta y reconecta**:
   - `Ctrl+a d` (desconectar)
   - `tmux attach -t practica` (reconectar)

8. **Limpia**:
   - `exit` en cada panel hasta cerrar tmux

¡Listo! En 5 minutos ya sabes lo básico. 🎉

---

## Siguiente Nivel

Una vez domines lo básico, aprende:
- **Scripting tmux** (automatizar layouts)
- **Tmuxinator** (configuraciones de proyectos)
- **Tmux en remoto** (SSH + tmux para sesiones persistentes)
- **Layouts personalizados** (`Ctrl+a Alt+1-5`)

¿Necesitas ayuda con algo específico de tmux? ¡Pregúntame!
