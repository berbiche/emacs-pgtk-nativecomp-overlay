{ sources ? import ./nix/sources.nix
, pkgs ? import sources."nixos-unstable" { }
, emacs-pgtk-nativecomp ? sources."emacs-pgtk-nativecomp"
}:

let
  libPath = with pkgs; lib.concatStringsSep ":" [
    "${lib.getLib libgccjit}/lib/gcc/${stdenv.targetPlatform.config}/${libgccjit.version}"
    "${lib.getLib stdenv.cc.cc}/lib"
    "${lib.getLib stdenv.glibc}/lib"
  ];
in
rec {
  ci = (import ./nix {}).ci;

  overlay = final: prev: builtins.mapAttrs (x: x prev) packages;

  packages = {
    emacsGccPgtk = 
      builtins.foldl' (drv: fn: fn drv) pkgs.emacs [

        (drv: drv.override { srcRepo = true; })

        (
          drv: drv.overrideAttrs (
            old: {
              name = "emacsGccPgtk";
              version = "28.0.50";
              src = pkgs.fetchFromGitHub {
                inherit (emacs-pgtk-nativecomp) owner repo rev sha256;
              };

              configureFlags = old.configureFlags
              ++ [ "--with-pgtk" ];


              patches = [
                (
                  pkgs.fetchpatch {
                    name = "clean-env.patch";
                    url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/clean-env.patch";
                    sha256 = "0lx9062iinxccrqmmfvpb85r2kwfpzvpjq8wy8875hvpm15gp1s5";
                  }
                )
                (
                  pkgs.fetchpatch {
                    name = "tramp-detect-wrapped-gvfsd.patch";
                    url = "https://raw.githubusercontent.com/nix-community/emacs-overlay/master/patches/tramp-detect-wrapped-gvfsd.patch";
                    sha256 = "19nywajnkxjabxnwyp8rgkialyhdpdpy26mxx6ryfl9ddx890rnc";
                  }
                )
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

    emacsGccPgtkWrapped =
      pkgs.symlinkJoin {
        name = "emacsGccPgtkWrapped";
        paths = [ (emacsGccPgtk pkgs) ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/emacs \
          --set LIBRARY_PATH ${libPath}
        '';
        meta.platforms = pkgs.stdenv.lib.platforms.linux;
        passthru.nativeComp = true;
        src = emacsGccPgtk.src;
      };
  };
}
