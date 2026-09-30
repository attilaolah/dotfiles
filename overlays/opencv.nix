final: prev:
if !prev.stdenv.hostPlatform.isLinux
then {}
else let
  mkOpenCV = args:
    (prev.opencv4.override args).overrideAttrs (oldAttrs: {
      patches =
        (oldAttrs.patches or [])
        ++ [
          (prev.fetchpatch {
            # https://github.com/NixOS/nixpkgs/pull/568676
            url = "https://github.com/opencv/opencv_contrib/commit/054007b78c8288ef2fd040e77dc0cf2e45f70c15.patch";
            hash = "sha256-vDW6kfDmwPB/tTurkDXuvViXrzXYV4njjDN6kLoIvJ4=";
            extraPrefix = "opencv_contrib/";
            stripLen = 2;
          })
        ];
    });
in {
  opencv4 = mkOpenCV {stdenv = final.ccacheStdenv;};
  opencv = final.opencv4;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pythonFinal: pythonPrev: let
        opencv4 = pythonPrev.toPythonModule (mkOpenCV {
          stdenv = final.ccacheStdenv;
          enablePython = true;
          pythonPackages = pythonFinal;
        });
      in {
        inherit opencv4;
        opencv-python = pythonPrev.opencv-python.override {inherit opencv4;};
      })
    ];
}
