{
  inputs,
  overlays,
  unfree,
}: {
  perSystem = {system, ...}: {
    _module.args = let
      build = config:
        import (inputs.nixpkgs-patcher.lib.patchNixpkgs {
          inherit system inputs;
          inherit (inputs) nixpkgs;
        }) {
          inherit system overlays;
          config = config // unfree;
        };
    in {
      pkgs = build {};
      inherit build;
    };
  };
}
