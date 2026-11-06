final: prev: let
  version = "1.0.0";
  hash-src = "sha256-S8ET3vXZ8cf/Jy/3ugn4Q0aOq4BGm9vSFiWhEbLIrns=";
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
        flask-executor = pyFinal.buildPythonPackage {
          pname = "flask-executor";
          inherit version;
          src = final.fetchPypi {
            pname = "Flask-Executor";
            inherit version;
            hash = hash-src;
          };
          pyproject = true;
          build-system = [pyFinal.setuptools];
          dependencies = [pyFinal.flask];
          pythonImportsCheck = ["flask_executor"];
          meta = {license = final.lib.licenses.mit;};
        };
      })
    ];

  flask-executor = final.python3Packages.flask-executor;
}
