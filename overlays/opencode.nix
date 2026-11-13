final: prev: {
  opencode = prev.opencode.overrideAttrs (oldAttrs:
    oldAttrs
    // {
      node_modules = oldAttrs.node_modules.overrideAttrs (nodeModulesAttrs: let
        brokenHash =
          if prev.stdenv.hostPlatform.isLinux
          then "sha256-UOVs48Z4yO4TJv859cg89lsul54KB9StTSl/VSQJXmc="
          else if prev.stdenv.hostPlatform.isDarwin
          then "sha256-AU2AUkdlL1g+hBkMZX93gQeQy6u8F0Gyzuk48yoN8as="
          else nodeModulesAttrs.outputHash;
        outputHash =
          if prev.stdenv.hostPlatform.isLinux
          then "sha256-PYcpyYP/i0e6ZIt27u1tFYbjU4Cl848w77dU1NiIEls="
          else if prev.stdenv.hostPlatform.isDarwin
          then "sha256-ewGKM0UKTv+97MLpscGMDbx7qsGZXxloRfmJNfY5MMo="
          else nodeModulesAttrs.outputHash;
      in
        assert outputHash != brokenHash;
        assert nodeModulesAttrs.outputHash == brokenHash;
          nodeModulesAttrs // {inherit outputHash;});
    });
}
