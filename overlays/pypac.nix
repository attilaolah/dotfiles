final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["carsonyl/pypac" "0.19.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-GOqLeZgyvXXXbz9raLhhmgFfmd4zDPvA/R8kG2lBp9Y=";

  version = elemAt github-tags 1;
in {
  inherit (final.python3Packages) pypac;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _: {
        pypac = pyFinal.buildPythonPackage {
          pname = "pypac";
          inherit version;
          pyproject = true;

          src = fetchFromGitHubTuple {
            inherit github-tags hash-src;
            rev = "v${version}";
          };

          build-system = with pyFinal; [
            setuptools
            wheel
          ];

          dependencies = with pyFinal;
            [
              dukpy
              publicsuffixlist
              requests
            ]
            ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
              pyobjc-framework-SystemConfiguration
            ];
          pythonImportsCheck = ["pypac"];
          nativeCheckInputs = with pyFinal; [
            pytestCheckHook
          ];
          disabledTests =
            [
              # Require DNS lookups.
              "test_isResolvable"
              "test_isInNet"
              "test_dnsResolve"
              "test_dnsResolveEx"
            ]
            ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
              # Requires a resolvable local hostname.
              "test_myIpAddress"
            ];

          meta = {
            description = "Proxy auto-config and auto-discovery for Python";
            homepage = "https://github.com/carsonyl/pypac";
            license = prev.lib.licenses.asl20;
          };
        };
      })
    ];
}
