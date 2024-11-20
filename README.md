# Development Environments

This repository contains Nix shell configurations for various development environments.

# Why Nix Shell?
Nix shell provides reproducible development environments that solve common development challenges:

- Consistency: Every environment instance gets identical dependencies and tools
- Isolation: Projects don't interfere with system packages or each other
- Versioning: Precise control over tool versions and dependencies
- Declarative: Environment defined in code, eliminating "works on my machine"
- Speed: Cached builds and downloads mean fast environment setup

## Available Environments

### Python Development (`python.nix`)

A Python development environment with virtualenv management and common development tools.

#### Features
- Configurable Python version
- Automatic virtualenv setup
- Pre-installed: black, pytest, pip
- Requirements.txt handling
- Custom ZSH prompt showing environment name

#### Usage
```bash
nix-shell python.nix

# With specific Python version:
nix-shell python.nix --arg pythonVersion '"3.11"'
```

### Rust Development (`rust.nix`)

A Rust development environment with standard tooling and build dependencies.

#### Features
- Standard Rust toolchain (rustc, cargo)
- Development tools: rustfmt, rust-analyzer, clippy
- Build dependencies (gcc, openssl)
- Automatic .cargo/config.toml setup
- Custom ZSH prompt showing environment name

#### Usage
```bash
nix-shell rust.nix
```

### Go Development (`go.nix`)

A Go development environment with standard tooling and testing utilities.

#### Features
- Go compiler and standard tools
- Language server (gopls) and debugger (delve)
- Code quality tools: golangci-lint, gotest, gotestsum
- Automatic GOPATH and project structure setup
- Default configurations (.golangci.yml)
- Custom ZSH prompt showing environment name

#### Usage
```bash
nix-shell go.nix
```

### .NET Development (`dotnet.nix`)

A .NET development environment with version selection and common tools.

#### Features
- Configurable .NET SDK version (6.0, 7.0, 8.0)
- Language server (omnisharp-roslyn)
- Local tool and NuGet package management
- Default configurations (NuGet.Config)
- Custom ZSH prompt showing environment name

#### Usage
```bash
nix-shell dotnet.nix

# With specific .NET version:
nix-shell dotnet.nix --arg dotnetVersion '"7.0"'
```

### ZSH Configuration (`zsh-config.nix`)

A shared ZSH configuration used by all environments.

#### Features
- Gruvbox theme
- Custom prompt showing current nix environment
- Git integration
- Reusable across all development environments

## Prerequisites

- Nix package manager
- Configured nixpkgs channel

## Project Structure
```
.
├── python.nix          # Python development environment
├── rust.nix           # Rust development environment
├── go.nix            # Go development environment
├── dotnet.nix        # .NET development environment
├── zsh-config.nix    # Shared ZSH configuration
└── README.md         # This file
```
