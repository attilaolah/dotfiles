final: prev: {
  cudaPackages = prev.lib.recurseIntoAttrs (
    prev.cudaPackages_13_2.overrideScope (cudaFinal: cudaPrev: {
      backendStdenv = final.ccacheStdenv.override {
        stdenv = cudaPrev.backendStdenv;
      };
    })
  );
}
