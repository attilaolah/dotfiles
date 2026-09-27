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

          dependencies = with pyFinal; [
            dukpy
            publicsuffixlist
            requests
          ];

          pythonRelaxDeps = ["dukpy"];
          pythonImportsCheck = ["pypac"];
          nativeCheckInputs = with pyFinal; [
            mock
            pytestCheckHook
          ];
          disabledTestPaths = [
            # These assert against live DNS lookups, which are unavailable in the sandbox.
            "tests/test_parser.py::TestFunctionsInPacParser::test_isResolvable"
            "tests/test_parser.py::TestFunctionsInPacParser::test_isInNet"
            "tests/test_parser.py::TestFunctionsInPacParserIPv6::test_dnsResolveEx"
            "tests/test_parser.py::TestFunctionsInPacParserIPv6::test_isResolvableEx"
            "tests/test_parser_functions.py::test_isResolvable[www.google.com-True]"
            "tests/test_parser_functions.py::test_isInNet[google.com-0.0.0.0-0.0.0.0-True]"
            "tests/test_parser_functions.py::test_dnsResolve"
            "tests/test_parser_functions_ex.py::test_dnsResolveEx"
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
