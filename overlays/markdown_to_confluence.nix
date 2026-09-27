final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["hunyadi/md2conf" "0.6.4"];
  hash-src = "sha256-+jbCJKOivJWuxfgLT7sUEJWunfG2S0i6qaC04MQojik=";

  version = elemAt github-tags 1;
in {
  inherit (final.python3Packages) markdown-to-confluence;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _: {
        markdown-to-confluence = pyFinal.buildPythonPackage {
          pname = "markdown_to_confluence";
          inherit version;
          pyproject = true;

          src = fetchFromGitHubTuple {
            inherit github-tags hash-src;
          };

          build-system = [pyFinal.setuptools];
          dependencies = with pyFinal; [
            cattrs
            lxml
            markdown
            orjson
            pathspec
            pymdown-extensions
            pyyaml
            requests
            truststore
          ];

          pythonImportsCheck = ["md2conf"];
          pythonRelaxDeps = [
            "cattrs"
            "orjson"
            "pymdown-extensions"
          ];

          doCheck = false;

          meta = {
            description = "Publish Markdown files to Confluence wiki";
            homepage = "https://github.com/hunyadi/md2conf";
            license = prev.lib.licenses.mit;
          };
        };
      })
    ];
}
