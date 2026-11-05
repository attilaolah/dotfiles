final: prev: {
  opencode = prev.opencode.overrideAttrs (oldAttrs:
    oldAttrs
    // {
      node_modules = oldAttrs.node_modules.overrideAttrs (nodeModulesAttrs: let
        brokenHash =
          if prev.stdenv.hostPlatform.isLinux
          then "sha256-j261NtmgO2n2vUlIPXv4t0W3r8uNQQrpMoQ/NRE51X0="
          else if prev.stdenv.hostPlatform.isDarwin
          then prev.lib.fakeHash
          else nodeModulesAttrs.outputHash;
        outputHash =
          if prev.stdenv.hostPlatform.isLinux
          then "sha256-+GgLX4lq8fPOJVoDGp220uiCTLB0ZwrBkcNo36q9MZU="
          else if prev.stdenv.hostPlatform.isDarwin
          then prev.lib.fakeHash
          else nodeModulesAttrs.outputHash;
      in
        assert nodeModulesAttrs.outputHash == brokenHash;
          nodeModulesAttrs // {inherit outputHash;});
    });
}
