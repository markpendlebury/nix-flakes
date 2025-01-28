{ pkgs ? import <nixpkgs> {} }:

{
  packages = [
    pkgs.zsh
    pkgs.oh-my-zsh
    pkgs.zsh-autocomplete
    pkgs.zsh-history
    pkgs.zsh-git-prompt
    pkgs.zsh-completions
    pkgs.zsh-you-should-use
    pkgs.zsh-autosuggestions
    pkgs.zsh-syntax-highlighting
  ];

  config = let
    gruvbox-theme = pkgs.fetchFromGitHub {
      owner = "sbugzu";
      repo = "gruvbox-zsh";
      rev = "c54443c8d3da35037b7ae3ca73b30b45bc91a9e7";
      sha256 = "1ibn2pd04rj4w66izn1pi2vkawvlx9c0vzalpcm0i11q5hybc4d7";
    };

    # Custom theme to add dynamic nix environment label
    customized-theme = pkgs.writeText "gruvbox.zsh-theme" ''
      # Source the original theme first so we have access to the colors
      source ${gruvbox-theme}/gruvbox.zsh-theme

      # Add nix environment indicator function using the theme's background
      function nix_shell_prompt() {
        if [ -n "$IN_NIX_SHELL" ]; then
          if [ -n "$NIX_ENV_NAME" ]; then
            echo "%K{$CURRENT_BG}%F{cyan}[nix-$NIX_ENV_NAME]%f%k "
          else
            echo "%K{$CURRENT_BG}%F{cyan}[nix-shell]%f%k "
          fi
        fi
      }
      
      # Add nix environment indicator to the prompt
      PROMPT="$(nix_shell_prompt)$PROMPT"
    '';

    # ZSH configuration
    zshConfig = pkgs.writeText "zshrc" ''
      # Source Oh-My-Zsh
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      export ZSH_CUSTOM=$ZDOTDIR/custom

      # Set theme before sourcing oh-my-zsh
      ZSH_THEME="gruvbox"
      SOLARIZED_THEME="dark"

      # Oh-My-Zsh plugins
      plugins=(git)

      # Create custom themes directory and copy customized Gruvbox theme
      mkdir -p $ZSH_CUSTOM/themes
      cp ${customized-theme} $ZSH_CUSTOM/themes/gruvbox.zsh-theme

      source $ZSH/oh-my-zsh.sh
    '';
  in ''
    export ZDOTDIR=$(mktemp -d)
    mkdir -p $ZDOTDIR/custom/themes
    cp ${zshConfig} $ZDOTDIR/.zshrc
    exec zsh
  '';

  # Export a function to set the environment name
  envNameFunction = envName: ''
    export NIX_ENV_NAME="${envName}"
  '';
}
