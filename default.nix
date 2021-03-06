{ version ? "28.0.50"
, sources ? import ./nix/sources.nix
, pkgs ? import sources.nixos-unstable {}
, stdenv ? pkgs.stdenv
, emacs-pgtk-nativecomp ? sources.emacs-pgtk-nativecomp
, emacs ? pkgs.emacs
, fetchpatch ? pkgs.fetchpatch
, fetchFromGitHub ? pkgs.fetchFromGitHub
}:

with stdenv.lib;
let
  emacsGccPgtk = builtins.foldl' (drv: fn: fn drv)
    emacs
    [

      (drv: drv.override { srcRepo = true; })

      (
        drv: drv.overrideAttrs (
          old: {
            name = "emacsGccPgtk";
            inherit version;
            src = toString emacs-pgtk-nativecomp;

            configureFlags = old.configureFlags ++ [ "--with-pgtk" ];

            patches = [
              (fetchpatch {
                  name = "clean-env.patch";
                  url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/clean-env.patch";
                  sha256 = "0lx9062iinxccrqmmfvpb85r2kwfpzvpjq8wy8875hvpm15gp1s5";
              })
              (fetchpatch {
                  name = "tramp-detect-wrapped-gvfsd.patch";
                  url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/tramp-detect-wrapped-gvfsd.patch";
                  sha256 = "19nywajnkxjabxnwyp8rgkialyhdpdpy26mxx6ryfl9ddx890rnc";
              })
            ];

            postPatch = old.postPatch + ''
              substituteInPlace lisp/loadup.el \
              --replace '(emacs-repository-get-version)' '"${emacs-pgtk-nativecomp.rev}"' \
              --replace '(emacs-repository-get-branch)' '"master"'
            '';

          }
        )
      )
      (
        drv: drv.override {
          nativeComp = true;
        }
      )
    ];
in
{
  ci = (import ./nix {}).ci;
  packages = {
    inherit emacsGccPgtk;
  };
}
