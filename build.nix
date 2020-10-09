let
  sources = import ./nix/sources.nix;
  nixpkgs = sources.nixos-unstable;
  emacs-pgtk-overlay = import ./overlay.nix;
  pkgs = import nixpkgs { config = { }; overlays = [ emacs-pgtk-overlay ]; };
in
{
  inherit (pkgs) emacsGccPgtk;
}
