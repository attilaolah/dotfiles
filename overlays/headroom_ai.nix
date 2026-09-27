final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;
  github-tags = ["headroomlabs-ai/headroom" "0.39.1"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-pcsKKq27cKyB7uWskbnWP8VI/UU9RdrE89QClLisvcU=";
  hash-cargo-deps = "sha256-azHjTfjdARzYuDMdH1AOYn0YV9U9lzaoULcSC/a9MuE=";

  pname = "headroom-ai";
  version = elemAt github-tags 1;
  src = fetchFromGitHubTuple {
    inherit github-tags hash-src;
    rev = "v${version}";
  };
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
        headroom-ai = pyFinal.buildPythonPackage (let
          dependencies = with pyFinal; [
            ast-grep-cli
            click
            datasets
            fastapi
            fastembed
            h2
            httpx
            jinja2
            litellm
            magika
            mcp
            numpy
            onnxruntime
            openai
            openpyxl
            opentelemetry-api
            opentelemetry-exporter-otlp-proto-http
            opentelemetry-sdk
            orjson
            pillow
            pydantic
            pyyaml
            rapidocr
            rich
            scikit-learn
            sentence-transformers
            sentencepiece
            sqlite-vec
            tiktoken
            tomlkit
            torch
            trafilatura
            transformers
            tree-sitter
            tree-sitter-language-pack
            uvicorn
            watchdog
            websockets
            xlrd
            zstandard
          ];
        in {
          inherit pname version src;
          pyproject = true;

          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit pname version src;
            hash = hash-cargo-deps;
          };
          build-system = [
            final.cargo
            final.rustPlatform.cargoSetupHook
            final.rustPlatform.maturinBuildHook
            final.rustc
          ];

          # The upstream [all] extra covers every supported runtime feature.
          inherit dependencies;

          # Proxy startup re-execs `python -m headroom.cli`; preserve its package closure for that child interpreter.
          makeWrapperArgs = [
            "--prefix"
            "PYTHONPATH"
            ":"
            "$out/${pyFinal.python.sitePackages}:${pyFinal.makePythonPath dependencies}"
          ];

          doCheck = false;

          meta = {
            description = "Context optimization layer for LLM applications";
            homepage = "https://github.com/headroomlabs-ai/headroom";
            license = final.lib.licenses.asl20;
            mainProgram = "headroom";
          };
        });
      })
    ];

  headroom-ai = final.python3Packages.headroom-ai;
}
