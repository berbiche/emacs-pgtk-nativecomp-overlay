let
  sources = import ./nix/sources.nix;
  nixpkgs = sources."nixos-unstable";
  emacs-pgtk-overlay = import ./default.nix;
  pkgs = import nixpkgs { config = {}; overlays = [ emacs-pgtk-overlay ]; };
in
{
  emacsGccPgtk = pkgs.emacsGccPgtk;
}
