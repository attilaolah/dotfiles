final: prev: let
  inherit (builtins) elemAt;

  pypi-releases = ["dukpy" "0.6.0"];
  hash-src = "sha256-+LHR91xqW+m1JdyA8FtshppnFIG+aJ2hRrLGk3s0UO4=";

  pname = elemAt pypi-releases 0;
  version = elemAt pypi-releases 1;
in {
  inherit (final.python3Packages) dukpy;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _: {
        dukpy = pyFinal.buildPythonPackage {
          inherit pname version;
          pyproject = true;

          src = prev.fetchPypi {
            inherit pname version;
            hash = hash-src;
          };

          build-system = [pyFinal.setuptools];

          meta = {
            description = "Simple JavaScript interpreter for Python";
            homepage = "https://github.com/amol-/dukpy";
            license = prev.lib.licenses.mit;
          };
        };
      })
    ];
}
