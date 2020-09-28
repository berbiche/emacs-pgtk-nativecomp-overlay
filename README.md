# To get nix and set up the binary cache

Follow the instructions [here](https://app.cachix.org/cache/mjlbach) to set up nix and add my cachix cache which provides precompiled binaries, built against the nixos-unstable channel each night.

# To use the overlay

Add the following to your $HOME/.config/nixpkgs/overlays directory: (make a file $HOME/.config/nixpkgs/overlays/emacs.nix and paste the snippet below into that file)

```nix
import (builtins.fetchTarball {
      url = https://github.com/mjlbach/emacs-pgtk-nativecomp-overlay/archive/master.tar.gz;
    })
```

Install emacsGccPgtk:
```
nix-env -iA nixpkgs.emacsGccPgtk
```
or add to home-manager/configuration.nix.

Note:

Emacs no longer needs to be wrapped to find the appropriate libgccjit libraries, as such emacsGccPgtkWrapped was removed.
