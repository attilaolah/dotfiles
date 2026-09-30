final: prev:
if !(prev.config.cudaSupport or false)
then {}
else {
  pythonPackagesExtensions = let
    override.stdenv = final.ccacheStdenv;
  in
    prev.pythonPackagesExtensions
    ++ [
      (_: pythonPrev: let
        # OpenCV-Python requires OpenCV's Python distribution metadata,
        # which the ordinary top-level `opencv` package does not provide.
        opencv4 = pythonPrev.toPythonModule (final.callPackage (final.path + "/pkgs/development/libraries/opencv/4.x.nix") {
            enablePython = true;
            pythonPackages = pythonPrev;
          }
          // override);
      in {
        inherit opencv4;
        opencv-python = pythonPrev.opencv-python.override {inherit opencv4;};
      })

      (_: pythonPrev: let
        inherit (builtins) listToAttrs map;
        ccache = prev.lib.getExe prev.ccache;
      in
        listToAttrs (map (name: {
            inherit name;
            value =
              (
                pythonPrev.${name}.override {
                  buildPythonPackage = pythonPrev.buildPythonPackage.override override;
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
            "numba"
            "onnxruntime"
            "rapidocr"
            "safetensors"
            "sentence-transformers"
            "torch"
            "torchaudio"
            "torchcodec"
            "torchmetrics"
            "torchvision"
            "transformers"
          ]))
    ];
}
