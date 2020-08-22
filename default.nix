{ pkgs ? import <nixos-unstable> { } }:
let
  rev = "b7adb08f960fe6568f702b8f328e65e3833ffc13";
  sha256 = "0p852k5wf8sy9h7x2z6iivf9xnhpy85vly9fn0a1qj2japrhvyr2";
in
{
  ci = (import ./nix { }).ci;
  emacsGccPGtk = builtins.foldl' (drv: fn: fn drv)
    pkgs.emacs
    [

      (drv: drv.override { srcRepo = true; })

      (
        drv: drv.overrideAttrs (
          old: {
            name = "emacs-pgtk-native-comp";
            version = "28.0.50";
            src = pkgs.fetchFromGitHub {
              owner = "fejfighter";
              repo = "emacs";
              inherit rev sha256;
            };

            configureFlags = old.configureFlags
              ++ [ "--with-pgtk" ];


            patches = [
              (pkgs.fetchpatch {
                name = "clean-env.patch";
                url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/clean-env.patch";
                sha256 = "0lx9062iinxccrqmmfvpb85r2kwfpzvpjq8wy8875hvpm15gp1s5";
              })
              (pkgs.fetchpatch {
                name = "tramp-detect-wrapped-gvfsd.patch";
                url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/tramp-detect-wrapped-gvfsd.patch";
                sha256 = "19nywajnkxjabxnwyp8rgkialyhdpdpy26mxx6ryfl9ddx890rnc";
              }
              )
            ];

            postPatch = old.postPatch + ''
              substituteInPlace lisp/loadup.el \
              --replace '(emacs-repository-get-version)' '"${rev}"' \
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
}
