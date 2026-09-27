final: prev: let
  inherit (builtins) elemAt;

  pypi-releases = ["types-cachetools" "7.0.0.20260713"];
  hash-src = "sha256-8azweenGaoHglqiX7wsmGoIRfPhWg043tL0MmhFqB2o=";

  pname = elemAt pypi-releases 0;
  pypiName = "types_cachetools";
  version = elemAt pypi-releases 1;
in {
  inherit (final.python3Packages) types-cachetools;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _: {
        types-cachetools = pyFinal.buildPythonPackage {
          inherit pname version;
          pyproject = true;

          src = prev.fetchPypi {
            pname = pypiName;
            inherit version;
            hash = hash-src;
          };

          build-system = [pyFinal.setuptools];

          meta = {
            description = "Typing stubs for cachetools";
            homepage = "https://github.com/python/typeshed";
            license = prev.lib.licenses.asl20;
          };
        };
      })
    ];
}
