{
  description = "Emacs with native compilation and pgtk";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.emacs-pgtk-nativecomp = { url = "github:flatwhatson/emacs/pgtk-nativecomp"; flake = false; };

  outputs = { self, flake-utils, emacs-pgtk-nativecomp, nixpkgs }:
    (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      src = pkgs.callPackage ./default.nix { inherit emacs-pgtk-nativecomp; };
    in rec {
      inherit (src) packages;
      legacyPackages = packages;
      defaultPackage = packages.emacsGccPgtkWrapped;
    }))
    // {
      overlay = import ./overlay.nix;
    };
}
