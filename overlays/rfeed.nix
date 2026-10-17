final: prev: let
  version = "1.1.1";
  hash-src = "sha256-qpUG8oZrdPWjItOUoUpjwZpoJcLZR1X/GdRt0eJDSBk=";
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
        rfeed = pyFinal.buildPythonPackage {
          pname = "rfeed";
          inherit version;
          src = final.fetchPypi {
            pname = "rfeed";
            inherit version;
            hash = hash-src;
          };
          pyproject = true;
          build-system = [pyFinal.setuptools];
          pythonImportsCheck = ["rfeed"];
          meta = {license = final.lib.licenses.mit;};
        };
      })
    ];

  rfeed = final.python3Packages.rfeed;
}
