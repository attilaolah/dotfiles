final: prev: let
  version = "0.47.3";
  hash-src = "sha256-AzmijdATXQj7/l4QiRd8ACPFy809WJ2W4TjJ2Jqnq78=";
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
        opendal-panoramax-fork = pyFinal.buildPythonPackage {
          pname = "opendal-panoramax-fork";
          inherit version;
          format = "wheel";
          src = final.fetchurl {
            url = "https://files.pythonhosted.org/packages/cb/41/5fb389af3446c3f1af11511cd4eb2c9ae7ed0c48b120a0aa900f5006a603/opendal_panoramax_fork-0.47.3-cp311-abi3-manylinux_2_34_x86_64.whl";
            hash = hash-src;
          };
          nativeBuildInputs = [final.autoPatchelfHook];
          pythonImportsCheck = ["opendal"];
          meta = {
            license = final.lib.licenses.asl20;
            platforms = ["x86_64-linux"];
          };
        };
      })
    ];

  opendal-panoramax-fork = final.python3Packages.opendal-panoramax-fork;
}
