final: prev:
if !prev.stdenv.hostPlatform.isLinux
then {}
else {
  opencv = final.opencv4;
  opencv4 = final.python3Packages.opencv4;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pythonFinal: pythonPrev: let
        opencv4 = pythonPrev.toPythonModule (prev.opencv4.override {
          enablePython = true;
          pythonPackages = pythonFinal;
        });
      in {
        inherit opencv4;
        opencv-python = pythonPrev.opencv-python.override {inherit opencv4;};
      })
    ];
}
