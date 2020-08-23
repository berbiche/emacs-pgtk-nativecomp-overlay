# To use the overlay

Add the following to your $HOME/.config/nixpkgs/overlays directory:

```
self: super:
import (builtins.fetchTarball {
      url = https://github.com/mjlbach/emacs-pgtk-nativecomp-overlay/archive/master.tar.gz;
    })
```

# To use the binary cache
```
cachix use mjlbach
```
