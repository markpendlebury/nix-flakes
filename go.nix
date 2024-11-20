{ pkgs ? import <nixpkgs> {} }:

let
  # Import ZSH configuration
  zshConfig = import ./zsh-config.nix { inherit pkgs; };
  
in pkgs.mkShell {
  buildInputs = [
    # Go and core tools
    pkgs.go
    pkgs.gopls          # Language server
    pkgs.go-tools       # Extra tools like staticcheck
    pkgs.delve          # Debugger
    
    # Code quality and testing tools
    pkgs.golangci-lint  # Meta linter
    pkgs.gotest         # Test runner with colors
    pkgs.gotestsum     # Better test output
    
    # Build tools
    pkgs.gcc
    pkgs.gnumake
    
    # Optional but useful tools
    pkgs.git
  ] ++ zshConfig.packages;  # Add ZSH packages

  shellHook = ''
    # Set the environment name
    ${zshConfig.envNameFunction "go"}

    # Set up GOPATH and other Go directories
    export GOPATH="$PWD/.go"
    export PATH="$GOPATH/bin:$PATH"
    export GO111MODULE=on

    # Create necessary directories if they don't exist
    mkdir -p .go/bin .go/src .go/pkg
    
    # Create default .golangci.yml if it doesn't exist
    if [ ! -f .golangci.yml ]; then
      echo "Creating default .golangci.yml"
      cat > .golangci.yml << EOF
run:
  deadline: 5m

linters:
  enable:
    - gofmt
    - golint
    - govet
    - errcheck
    - staticcheck
    - gosimple
    - ineffassign

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - errcheck
EOF
    fi

    # Create default .gitignore if it doesn't exist
    if [ ! -f .gitignore ]; then
      echo "Creating default .gitignore"
      cat > .gitignore << EOF
# Go specific
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
.go/

# IDE specific
.idea/
.vscode/
*.swp
EOF
    fi

    echo "Go development environment ready"
    echo "go version: $(go version)"
    echo "GOPATH set to: $GOPATH"

    # Apply ZSH configuration
    ${zshConfig.config}
  '';

  # Environment variables for better Go development
  GOROOT = "${pkgs.go}/share/go";
  CGO_ENABLED = "1";
}
