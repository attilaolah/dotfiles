final: prev: let
  version = "1.5.1";
  hash-src = "sha256-8nprah7Lh66swrUbzFnKeb5w7RKgEE3oYBR4shPdXYE=";
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
        pygeoif = pyFinal.buildPythonPackage {
          pname = "pygeoif";
          inherit version;
          src = final.fetchPypi {
            pname = "pygeoif";
            inherit version;
            hash = hash-src;
          };
          pyproject = true;
          build-system = [pyFinal.setuptools];
          dependencies = [pyFinal.typing-extensions];
          nativeCheckInputs = with pyFinal; [hypothesis more-itertools pytestCheckHook];
          pythonImportsCheck = ["pygeoif"];
          meta = {license = final.lib.licenses.lgpl3Plus;};
        };
      })
    ];

  pygeoif = final.python3Packages.pygeoif;
}
