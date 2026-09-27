final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["amol-/dukpy" "0.6.0"];
  hash-src = "sha256-BSgKu5sjWMGJt2zH2vHnWXGTRLxlX/+Dz2/lBTDJuWM=";

  version = elemAt github-tags 1;
in {
  inherit (final.python3Packages) dukpy;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _: {
        dukpy = pyFinal.buildPythonPackage {
          pname = "dukpy";
          inherit version;
          pyproject = true;

          src = fetchFromGitHubTuple {
            inherit github-tags hash-src;
          };

          build-system = [pyFinal.setuptools];

          pythonImportsCheck = ["dukpy"];
          nativeCheckInputs = with pyFinal; [
            mock
            pytestCheckHook
            webassets
          ];
          disabledTests = ["test_installer"];
          preCheck = ''
            rm -r dukpy
          '';

          meta = {
            description = "Simple JavaScript interpreter for Python";
            homepage = "https://github.com/amol-/dukpy";
            license = prev.lib.licenses.mit;
            mainProgram = "dukpy";
          };
        };
      })
    ];
}
