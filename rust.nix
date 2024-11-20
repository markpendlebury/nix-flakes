{ pkgs ? import <nixpkgs> {} }:

let
  # Import ZSH configuration
  zshConfig = import ./zsh-config.nix { inherit pkgs; };
  
in pkgs.mkShell {
  buildInputs = [
    # Rust packages
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.rust-analyzer
    pkgs.clippy
    
    # Build tools
    pkgs.pkg-config
    pkgs.openssl
    pkgs.gcc
    
    # Optional but useful tools
    pkgs.git
  ] ++ zshConfig.packages;  # Add ZSH packages

  shellHook = ''
    # Set the environment name
    ${zshConfig.envNameFunction "rust"}

    # Add cargo bin to path
    export PATH="$HOME/.cargo/bin:$PATH"

    # Set useful rust env vars
    export RUST_BACKTRACE=1
    
    # Optional: Create a .cargo/config.toml if it doesn't exist
    mkdir -p .cargo
    if [ ! -f .cargo/config.toml ]; then
      echo "Creating default .cargo/config.toml"
      cat > .cargo/config.toml << EOF
[build]
# Add useful rustc warnings
rustflags = [
    "-W", "missing_docs",
    "-W", "rust_2018_idioms",
]

[target.x86_64-unknown-linux-gnu]
linker = "gcc"

[target.x86_64-apple-darwin]
linker = "gcc"
EOF
    fi

    echo "Rust development environment ready"
    echo "rustc --version: $(rustc --version)"
    echo "cargo --version: $(cargo --version)"

    # Apply ZSH configuration
    ${zshConfig.config}
  '';

  # Ensure openssl linking works
  OPENSSL_DIR="${pkgs.openssl.dev}";
  OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib";
}
