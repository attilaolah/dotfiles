{
  inputs,
  overlays,
  unfree,
}: {
  perSystem = {system, ...}: let
    build = config:
      import (inputs.nixpkgs-patcher.lib.patchNixpkgs {
        inherit system inputs;
        inherit (inputs) nixpkgs;
      }) {
        inherit system overlays;
        config = config // unfree;
      };
  in {
    _module.args = {
      pkgs = build {};
      inherit build;
    };
  };
}
