final: prev: let
  version = "2.1.1";
  hash-src = "sha256-O2T6Lc2YEI/4oZv7Ae7j2rQbwjC+JIGASu/XwWWdHCM=";
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
        geojson-pydantic = pyFinal.buildPythonPackage {
          pname = "geojson-pydantic";
          inherit version;
          src = final.fetchPypi {
            pname = "geojson_pydantic";
            inherit version;
            hash = hash-src;
          };
          pyproject = true;
          build-system = [pyFinal.hatchling];
          dependencies = [pyFinal.pydantic];
          pythonImportsCheck = ["geojson_pydantic"];
          meta = {license = final.lib.licenses.mit;};
        };
      })
    ];

  geojson-pydantic = final.python3Packages.geojson-pydantic;
}
