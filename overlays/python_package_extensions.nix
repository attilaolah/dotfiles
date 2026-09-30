final: prev:
if !(prev.config.cudaSupport or false)
then {}
else {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (_: pythonPrev: let
        inherit (builtins) filter listToAttrs map;
      in
        listToAttrs (map (name: {
            inherit name;
            value = let
              ccache = prev.lib.getExe prev.ccache;
              withCcacheStdenv = pythonPrev.${name}.override {
                buildPythonPackage = pythonPrev.buildPythonPackage.override {stdenv = final.ccacheStdenv;};
              };
            in
              if name == "triton"
              then let
                cudaPackages = pythonPrev.${name}.passthru.cudaPackages;
                ccacheBackendStdenv = final.ccacheStdenv.override {
                  stdenv = cudaPackages.backendStdenv;
                  extraConfig = final.ccacheExtraConfig;
                };
              in
                pythonPrev.${name}.override {
                  cudaPackages = cudaPackages // {backendStdenv = ccacheBackendStdenv;};
                }
              else
                withCcacheStdenv.overridePythonAttrs (oldAttrs: {
                  preConfigure =
                    (oldAttrs.preConfigure or "")
                    + ''
                      ${final.ccacheExtraConfig}

                      export CMAKE_C_COMPILER_LAUNCHER="${ccache}"
                      export CMAKE_CXX_COMPILER_LAUNCHER="${ccache}"
                      export CMAKE_CUDA_COMPILER_LAUNCHER="${ccache}"
                    '';
                });
          }) (
            filter (name: pythonPrev ? ${name})
            # CUDA-sensitive dependencies.
            # Covers most packages imported by this flake that are sensitive to the nixpkgs.config.cudaSupport flag.
            [
              "fastembed"
              "magika"
              "onnxruntime"
              "rapidocr"
              "safetensors"
              "sentence-transformers"
              "torch"
              "transformers"
              "triton"
            ]
          )))
    ];
}
