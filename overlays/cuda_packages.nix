final: prev: let
  # Renovate will keep this updated.
  cudaPackages = prev.cudaPackages_13_4;
in {
  cudaPackages = prev.lib.recurseIntoAttrs (
    cudaPackages.overrideScope (cudaFinal: cudaPrev: {
      backendStdenv = final.ccacheStdenv.override {
        stdenv = cudaPrev.backendStdenv;
      };
    })
  );
}
