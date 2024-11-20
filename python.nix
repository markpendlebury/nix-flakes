{ pkgs ? import <nixpkgs> {}, pythonVersion ? "3.10" }:

let
  # Import ZSH configuration
  zshConfig = import ./zsh-config.nix { inherit pkgs; };
  
  # Python setup
  pythonPkg = if pkgs.lib.hasAttr "python${builtins.replaceStrings ["."] [""] pythonVersion}" pkgs
              then pkgs.lib.getAttr "python${builtins.replaceStrings ["."] [""] pythonVersion}" pkgs
              else throw "Python version ${pythonVersion} not found";
in pkgs.mkShell {
  buildInputs = [
    # Python packages
    pythonPkg
    pythonPkg.pkgs.pip
    pythonPkg.pkgs.virtualenv
    pythonPkg.pkgs.black
    pythonPkg.pkgs.pytest
    pkgs.which
    pkgs.git
  ] ++ zshConfig.packages;  # Add ZSH packages

  shellHook = ''
    # Set the environment name
    ${zshConfig.envNameFunction "python"}

    # Python Environment Setup
    python -m venv venv
    source venv/bin/activate

    # Ensure virtualenv is properly activated
    export VIRTUAL_ENV=$PWD/venv
    export PATH="$VIRTUAL_ENV/bin:$PATH"

    # Upgrade pip
    python -m pip install --upgrade pip

    # Install test requirements first
    if [ -f test-requirements.txt ]; then
      echo "Installing test-requirements.txt"
      pip install -r test-requirements.txt
    fi

    # Install main requirements
    if [ -f requirements.txt ]; then
      echo "Installing requirements.txt"
      pip install -r requirements.txt
    fi

    # Set PYTHONPATH to prioritize virtualenv and current directory
    export PYTHONPATH="$VIRTUAL_ENV/lib/python${pythonVersion}/site-packages:$PWD:$PYTHONPATH"

    echo "Development environment setup complete"
    echo "You are running python version: $(python --version)"

    # Apply ZSH configuration
    ${zshConfig.config}
  '';
}
