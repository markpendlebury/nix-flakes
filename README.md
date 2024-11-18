# Development Environments

This repository contains Nix flake configurations for various development environments.

## Available Environments

### Python Development (`python.nix`)

A Python development environment with virtualenv management and common development tools.

#### Features
- Configurable Python version
- Automatic virtualenv setup
- Pre-installed: black, pytest, pip
- Requirements.txt handling

#### Usage
```bash
nix-shell PATH/TO/python.nix

# With specific Python version:
nix-shell PATH/TO/python.nix--arg pythonVersion '"3.11"'
```

## Adding New Environments

Each environment should:
1. Have its own directory
2. Include a README explaining specific features/usage
3. Contain required Nix configuration files
4. Document any prerequisites or dependencies

## Prerequisites

- Nix package manager
- Configured nixpkgs channel

## Contributing

