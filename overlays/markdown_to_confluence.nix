final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;
  py = prev.python3Packages;

  github-tags = ["hunyadi/md2conf" "0.6.4"];
  hash-src = "sha256-+jbCJKOivJWuxfgLT7sUEJWunfG2S0i6qaC04MQojik=";

  version = elemAt github-tags 1;
in {
  markdown-to-confluence = py.buildPythonPackage {
    pname = "markdown_to_confluence";
    inherit version;
    pyproject = true;

    src = fetchFromGitHubTuple {
      inherit github-tags hash-src;
    };

    build-system = [py.setuptools];
    dependencies = with py; [
      cattrs
      lxml
      markdown
      orjson
      pymdown-extensions
      pyyaml
      requests
      truststore
    ];

    pythonRelaxDeps = [
      "cattrs" # https://github.com/NixOS/nixpkgs/pull/534685
      "lxml"
    ];
    doCheck = false;

    meta = {
      description = "Publish Markdown files to Confluence wiki";
      homepage = "https://github.com/hunyadi/md2conf";
      license = prev.lib.licenses.mit;
    };
  };
}
