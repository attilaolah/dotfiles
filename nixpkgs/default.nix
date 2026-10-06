{
  lib,
  nixpkgs,
  system,
  config ? {},
  overlays ? [],
}: let
  bootstrap = import nixpkgs {inherit system;};
  fetchpatch = {
    pr,
    commit ? "",
    hash,
  }:
    bootstrap.fetchpatch2 {
      inherit hash;
      url =
        if commit != ""
        then url pr "/commits/${commit}"
        else url pr "";
      name = lib.removeSuffix "-" "nixpkgs-${prefix}${pr}-${commit}";
    };
  url = pr: path: "https://github.com/NixOS/nixpkgs/pull/${pr}${path}.patch?full_index=1";
  prefix = "pr-";
in
  import (
    bootstrap.applyPatches {
      name = "nixpkgs";
      src = nixpkgs;
      patches = lib.lists.flatten (lib.mapAttrsToList (name: {
        hash ? null,
        commits ? null,
      }: let
        pr = lib.strings.removePrefix prefix name;
      in
        if hash != null
        then [(fetchpatch {inherit pr hash;})]
        else map (commit: fetchpatch ({inherit pr;} // commit)) commits)
      (import ./patches.nix));
    }
  ) {inherit system config overlays;}
