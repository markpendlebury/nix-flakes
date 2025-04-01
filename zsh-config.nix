{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-23.11.tar.gz") {} }:
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

}