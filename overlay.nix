final: prev: 
builtins.mapAttrs (x: x prev) (import ./default.nix { }).packages;
