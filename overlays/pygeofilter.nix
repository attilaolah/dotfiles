final: prev: let
  version = "0.3.1";
  hash-src = "sha256-+SvAYiCZ+H/os23nq92GBZ1hWontYIInNwgiI6V44VA=";
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
        pygeofilter = pyFinal.buildPythonPackage {
          pname = "pygeofilter";
          inherit version;
          src = final.fetchPypi {
            pname = "pygeofilter";
            inherit version;
            hash = hash-src;
          };
          pyproject = true;
          build-system = [pyFinal.setuptools];
          dependencies = [pyFinal.dateparser pyFinal.lark pyFinal.pygeoif pyFinal.shapely];
          nativeCheckInputs = [pyFinal.pytestCheckHook];
          pythonImportsCheck = ["pygeofilter"];
          meta = {license = final.lib.licenses.mit;};
        };
      })
    ];

  pygeofilter = final.python3Packages.pygeofilter;
}
