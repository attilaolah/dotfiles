final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["hunyadi/md2conf" "0.6.1"];
  hash-src = "sha256-DFGFDJYpadcRZ6gJ4yjYHS7d+oJtu4L/fwKIyJDNneA=";

  version = elemAt github-tags 1;
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
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
            pymdown-extensions
            pyyaml
            requests
            truststore
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

  markdown-to-confluence = final.python3Packages.markdown-to-confluence;
}
