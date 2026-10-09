{
  inputs,
  overlays,
  unfree,
}: {
  perSystem = {system, ...}: let
    nixpkgs-patched = inputs.nixpkgs-patcher.lib.patchNixpkgs {
      inherit system inputs;
      inherit (inputs) nixpkgs;
    };
    mkPatchedPkgs = config:
      import nixpkgs-patched {
        inherit system overlays;
        config = config // unfree;
      };
  in {
    _module.args = {
      pkgs = mkPatchedPkgs {};
      inherit mkPatchedPkgs;
    };
  };
}
