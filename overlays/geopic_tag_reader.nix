final: prev: let
  version = "1.10.1";
  hash-src = "sha256-gAylrvRaOT0OfhiKlowDd7+WWBcf2Hm+JhPTsNBHb0c=";
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
        geopic-tag-reader = pyFinal.buildPythonPackage {
          pname = "geopic-tag-reader";
          inherit version;
          src = final.fetchPypi {
            pname = "geopic_tag_reader";
            inherit version;
            hash = hash-src;
          };
          pyproject = true;
          build-system = [pyFinal.flit-core];
          dependencies = with pyFinal; [pyexiv2 types-python-dateutil types-pytz python-dateutil pytz rtree timezonefinder typer xmltodict];
          pythonRelaxDeps = ["pyexiv2" "pytz" "timezonefinder" "xmltodict" "types-pytz"];
          pythonImportsCheck = ["geopic_tag_reader"];
          meta = {license = final.lib.licenses.mit;};
        };
      })
    ];

  geopic-tag-reader = final.python3Packages.geopic-tag-reader;
}
