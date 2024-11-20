{ pkgs ? import <nixpkgs> {}, dotnetVersion ? "8.0" }:

let
  # Import ZSH configuration
  zshConfig = import ./zsh-config.nix { inherit pkgs; };
  
  # Convert version string to package attribute
  dotnetPkg = 
    let
      versionMap = {
        "6.0" = pkgs.dotnet-sdk_6;
        "7.0" = pkgs.dotnet-sdk_7;
        "8.0" = pkgs.dotnet-sdk_8;
      };
    in
      if builtins.hasAttr dotnetVersion versionMap
      then builtins.getAttr dotnetVersion versionMap
      else throw "Dotnet version ${dotnetVersion} not found. Available versions: 6.0, 7.0, 8.0";

in pkgs.mkShell {
  buildInputs = [
    # .NET SDK
    dotnetPkg

    # Additional development tools
    pkgs.omnisharp-roslyn  # C# language server
    pkgs.msbuild
    
    # Build dependencies
    pkgs.icu
    pkgs.zlib
    pkgs.openssl
    
    # Optional but useful tools
    pkgs.git
  ] ++ zshConfig.packages;  # Add ZSH packages

  shellHook = ''
    # Set the environment name
    ${zshConfig.envNameFunction "dotnet"}

    # Create local directories for .NET
    mkdir -p .dotnet/tools
    mkdir -p .nuget

    # Set up .NET environment variables
    export DOTNET_ROOT="${dotnetPkg}/sdk/${dotnetVersion}"
    export DOTNET_CLI_HOME="$PWD/.dotnet"
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export DOTNET_NOLOGO=1
    export PATH="$DOTNET_CLI_HOME/tools:$PATH"
    
    # Configure NuGet
    export NUGET_PACKAGES="$PWD/.nuget"
    
    # Create local NuGet.Config if it doesn't exist
    if [ ! -f NuGet.Config ]; then
      echo "Creating default NuGet.Config"
      cat > NuGet.Config << EOF
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
  </packageSources>
</configuration>
EOF
    fi

    # Create default .gitignore if it doesn't exist
    if [ ! -f .gitignore ]; then
      echo "Creating default .gitignore"
      cat > .gitignore << EOF
# .NET specific
bin/
obj/
.dotnet/
.nuget/
*.dll
*.pdb
*.user
*.userosscache
*.suo
*.cache

# IDE specific
.vs/
.vscode/
.idea/
*.swp
EOF
    fi

    echo ".NET development environment ready"
    echo "dotnet version: $(dotnet --version)"
    echo "SDK location: $DOTNET_ROOT"
    
    # Print available SDKs
    echo "Available SDKs:"
    dotnet --list-sdks

    # Apply ZSH configuration
    ${zshConfig.config}
  '';

  # Environment variables for SSL certificates
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
}
