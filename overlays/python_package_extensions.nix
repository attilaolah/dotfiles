final: prev:
if !(prev.config.cudaSupport or false)
then {}
else {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (_: pythonPrev: let
        inherit (builtins) listToAttrs map;
        ccache = prev.lib.getExe prev.ccache;
      in
        listToAttrs (map (name: {
            inherit name;
            value =
              (
                pythonPrev.${name}.override {
                  buildPythonPackage = pythonPrev.buildPythonPackage.override {stdenv = final.ccacheStdenv;};
                }
              ).overridePythonAttrs (oldAttrs: {
                preConfigure =
                  (oldAttrs.preConfigure or "")
                  + ''
                    ${final.ccacheExtraConfig}

                    export CMAKE_C_COMPILER_LAUNCHER="${ccache}"
                    export CMAKE_CXX_COMPILER_LAUNCHER="${ccache}"
                    export CMAKE_CUDA_COMPILER_LAUNCHER="${ccache}"
                  '';
              });
          }) [
            # CUDA-sensitive dependencies.
            # Covers most packages imported by this flake that are sensitive to the nixpkgs.config.cudaSupport flag.
            "fastembed"
            "magika"
            "onnxruntime"
            "rapidocr"
            "safetensors"
            "sentence-transformers"
            "torch"
            "torchaudio"
            "torchcodec"
            "transformers"
          ]))
    ];
}
