final: prev: {
  gdbuspp = prev.gdbuspp.overrideAttrs (oldAttrs: {
    patches =
      (oldAttrs.patches or [])
      ++ [
        (prev.fetchpatch {
          # https://github.com/OpenVPN/gdbuspp/commit/7462325fb03d318658eaa9fecfc34f46cc5705fc
          url = "https://github.com/OpenVPN/gdbuspp/commit/7462325fb03d318658eaa9fecfc34f46cc5705fc.patch";
          hash = "sha256-pg1iWCbyGas7B/11Kt2ke/TlH1LC1EgNlUv7okuE5Sc=";
        })
      ];

    # The upstream patch's proxy.cpp hunk has context from post-v3 refactors.
    patchFlags = (oldAttrs.patchFlags or ["-p1"]) ++ ["--fuzz=2"];
  });
}
