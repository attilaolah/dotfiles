final: prev: let
  inherit (builtins) elemAt;

  gitlab-tags = ["panoramax/server/api" "2.16.0"];
  hash-src = "sha256-sVrknvzicnrT5Am8yCyL01GVME00g1TknHtrICXFNjw=";

  version = elemAt gitlab-tags 1;
  src = final.fetchFromGitLab {
    owner = "panoramax/server";
    repo = "api";
    rev = version;
    hash = hash-src;
  };
in {
  inherit (final.python3Packages) geovisio;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _: {
        geovisio = pyFinal.buildPythonPackage {
          pname = "geovisio";
          inherit version src;
          pyproject = true;

          build-system = [pyFinal.flit-core];
          nativeBuildInputs = [pyFinal.babel];
          preBuild = ''
            pybabel compile -d geovisio/translations
          '';
           dependencies = with pyFinal; [
            authlib
            croniter
            email-validator
            flask
            flask-babel
            flask-compress
            flask-cors
            flask-executor
            flasgger
            geojson-pydantic
            geopic-tag-reader
            gunicorn
            joserfc
            multipart
            opendal
            pillow
            psycopg
            psycopg-pool
            pydantic
            pydantic-extra-types
            pygeofilter
            python-dateutil
            python-dotenv
            requests
            rfeed
            sentry-sdk
            tzdata
            yoyo-migrations
          ];

          nativeCheckInputs = [pyFinal.pytestCheckHook];
          checkInputs = [pyFinal.pytest];
          pytestFlags = ["geovisio/web/params.py"];
          preCheck = ''export HOME="$TMPDIR"'';

          postPatch = ''
            substituteInPlace pyproject.toml \
              --replace-fail '"psycopg-binary ~= 3.3"' '"psycopg ~= 3.3"' \
              --replace-fail '"opendal_panoramax_fork ~= 0.47.3"' '"opendal ~= 0.47.3"'
          '';
          postInstall = ''
            install -Dm644 images/* -t "$out/${pyFinal.python.sitePackages}/images"
          '';
          # Nixpkgs provides newer compatible releases of these dependencies.
          pythonRelaxDeps = [
            "flask-babel"
            "flask-compress"
            "gunicorn"
            "joserfc"
            "pillow"
            "pydantic-extra-types"
            "requests"
            "tzdata"
          ];
          pythonImportsCheck = ["geovisio"];
          passthru.sources = {inherit src;};

          meta = {
            description = "Panoramax backend API";
            homepage = "https://gitlab.com/panoramax/server/api";
            license = final.lib.licenses.mit;
            mainProgram = "panoramax_backend";
          };
        };
      })
    ];
}
