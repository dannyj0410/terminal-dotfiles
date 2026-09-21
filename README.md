# Terminal Dotfiles

A modern, high-performance terminal development environment designed for **Windows + WSL2**, with cross-platform terminal tools, shell customization, and terminal multiplexing.

## Project Structure

```text
terminal-dotfiles-main/
├── claude/
│   └── settings.json
├── config/
│   ├── fish/
│   │   ├── conf.d/
│   │   │   └── dev.fish
│   │   ├── config.fish
│   │   └── fish_plugins
│   ├── starship.toml
│   └── zellij/
│       ├── config.kdl
│       └── layouts/
│           ├── dev.kdl
│           ├── mono.kdl
│           └── work.kdl
└── windows/
    ├── .wezterm.lua
    └── .wslconfig
```

## Tools & Configurations

### Windows & WSL2

This environment is tailored for Windows users running **WSL2**.

- **WezTerm** (`windows/.wezterm.lua`)  
  Configuration for the GPU-accelerated WezTerm terminal emulator.

- **WSL2** (`windows/.wslconfig`)  
  Defines resource allocations for the WSL2 virtual machine.

Current resource settings:

| Resource | Value |
| --- | --- |
| Memory | `16GB` |
| Processors | `8` |
| Swap | `4GB` |
| Localhost Forwarding | `true` |

### Shell Environment

- **Fish Shell** (`config/fish/`)  
  Contains the primary shell configuration, developer-specific environment settings, and managed shell plugins:
  - `config.fish` — main Fish configuration
  - `conf.d/dev.fish` — developer-specific environment configuration
  - `fish_plugins` — managed Fish plugin list

- **Starship** (`config/starship.toml`)  
  Configuration for the Starship cross-shell prompt, providing a consistent prompt experience across environments.

### Terminal Multiplexing

- **Zellij** (`config/zellij/`)  
  Contains the core multiplexer configuration in `config.kdl`.

- **Zellij Layouts** (`config/zellij/layouts/`)  
  Includes custom workspace layouts for:
  - `dev.kdl` — development workflows
  - `mono.kdl` — monolithic or focused tasks
  - `work.kdl` — general work sessions

### AI Assistant

- **Claude** (`claude/settings.json`)  
  Stores application-specific settings for Claude desktop or CLI integration.

## Setup

To deploy these dotfiles to a new system, map or symlink each configuration to its expected location.

### 1. Linux / WSL2 Configuration

Link the contents of the `config/` directory into your local `~/.config/` directory.

For example:

```bash
ln -s /path/to/terminal-dotfiles-main/config/fish ~/.config/fish
ln -s /path/to/terminal-dotfiles-main/config/starship.toml ~/.config/starship.toml
ln -s /path/to/terminal-dotfiles-main/config/zellij ~/.config/zellij
```

Adjust the source path to match the location of the repository on your system.

### 2. Windows Configuration

Copy or symlink the files from `windows/` into your Windows user profile:

```text
C:\Users\<YourUsername>\
```

The files are:

```text
windows/.wezterm.lua
windows/.wslconfig
```

### 3. Claude Configuration

Move or copy:

```text
claude/settings.json
```

to the appropriate local configuration directory used by your Claude desktop application or CLI setup.

## Notes

This repository is intended to keep terminal, shell, multiplexer, WSL2, and related development configuration version-controlled and portable across machines.

Review machine-specific paths, resource limits, and application-specific configuration locations before deploying to a new system.
