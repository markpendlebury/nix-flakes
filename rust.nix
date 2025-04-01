let
  nixpkgs = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-23.11.tar.gz";
    sha256 = "1aqh8khd19wqn2438wyg7dlx1dx7cj5z6lz7qvj33yii4w9wlrqf";
  };
  rust-overlay = fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
    sha256 = "06h37n8pc5h3lm50kl56yh3ikcdw4fvgm0tjd2j9pmg8mq5kc44g";
  };
   pkgs = import nixpkgs {
    overlays = [ (import rust-overlay) ];
  };

  # Import ZSH configuration
  zshConfig = import ./zsh-config.nix { inherit pkgs; };

in pkgs.mkShell {
  buildInputs = [
    # Rust packages (using pinned version)
    (pkgs.rust-bin.stable."1.83.0".default)
    pkgs.rust-analyzer
    
    # Build tools
    pkgs.pkg-config
    pkgs.openssl
    pkgs.gcc
    
    # Optional but useful tools
    pkgs.git
  ] ++ zshConfig.packages;  # Add ZSH packages
  
  shellHook = ''
    # Set the environment name
    zshConfig.envNameFunction = "rust"
    
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
    zshConfig.config
  '';
  
  # Ensure openssl linking works
  OPENSSL_DIR="${pkgs.openssl.dev}";
  OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib";
}
