# shell.nix
{ pkgs ? import <nixpkgs> {}, pythonVersion ? "3.10" }:

let
  # Convert version string to package attribute
  pythonPkg = if pkgs.lib.hasAttr "python${builtins.replaceStrings ["."] [""] pythonVersion}" pkgs
              then pkgs.lib.getAttr "python${builtins.replaceStrings ["."] [""] pythonVersion}" pkgs
              else throw "Python version ${pythonVersion} not found";
in pkgs.mkShell {
  buildInputs = [
    pythonPkg
    pythonPkg.pkgs.pip
    pythonPkg.pkgs.virtualenv
    pythonPkg.pkgs.black
    pythonPkg.pkgs.pytest
    pkgs.which
    pkgs.git
  ];

  shellHook = ''
    # Create and activate virtual environment
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
    # Note: We use string substitution to get the correct Python version in the path
    export PYTHONPATH="$VIRTUAL_ENV/lib/python${pythonVersion}/site-packages:$PWD:$PYTHONPATH"

    # Print debug information
    echo "Virtual Environment: $VIRTUAL_ENV"
    echo "Python: $(which python)"
    echo "Pip: $(which pip)"
    echo "Python version: $(python --version)"

    echo "Verifying boto3 installation:"
    python -c "import boto3; print(boto3.__file__)"

    echo "Development environment setup complete"
  '';
}
