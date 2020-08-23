# To use the binary cache

Follow the instructions [here](https://app.cachix.org/cache/mjlbach) to setup and add my cachix cache which provides precompiled binaries, built against nixos-unstable each night.

# To use the overlay (if you're managing/compiling your emacs packages via nix)

Add the following to your $HOME/.config/nixpkgs/overlays directory:

```nix
self: super:
import (builtins.fetchTarball {
      url = https://github.com/mjlbach/emacs-pgtk-nativecomp-overlay/archive/master.tar.gz;
    })
```

Install emacsGccPgtk:
```
nix-env -iA nixpkgs.emacsGccPgtk
```
or add to home-manager/configuration.nix.


# To use the overlay (if you're managing/compiling your emacs packages via straight.el or another package manager)
Emacs must be wrapped with the appropriate library path in order to find libgccjit and requisite libraries. Use the following overlay:
```nix
self: super:
let
  libPath = with super; lib.concatStringsSep ":" [
    "${lib.getLib libgccjit}/lib/gcc/${stdenv.targetPlatform.config}/${libgccjit.version}"
    "${lib.getLib stdenv.cc.cc}/lib"
    "${lib.getLib stdenv.glibc}/lib"
  ];
  emacs-overlay=import (builtins.fetchTarball {
          url = https://github.com/mjlbach/emacs-pgtk-nativecomp-overlay/archive/master.tar.gz;
        });
in {
  emacsGccPgtkWrapped = super.symlinkJoin {
    name = "emacsGccWrapped";
    paths = [ emacs-overlay.emacsGccPgtk ];
    buildInputs = [ super.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/emacs \
      --set LIBRARY_PATH ${libPath}
    '';
    meta.platforms = super.stdenv.lib.platforms.linux;
    passthru.nativeComp = true;
    src = emacs-overlay.emacsGccPgtk.src;
  };
} 

```
Install emacsGccPgtkWrapped:
```
nix-env -iA nixpkgs.emacsGccPgtkWrapped
```
or add to home-manager/configuration.nix.

