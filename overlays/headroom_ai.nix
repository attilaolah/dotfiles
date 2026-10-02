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
  inherit (final.python3Packages) headroom-ai;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _: {
        headroom-ai = pyFinal.buildPythonPackage (let
          dependencies = with pyFinal; [
            ast-grep-cli
            anthropic
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
          build-system = with final;
            [
              cargo
              rustc
            ]
            ++ (with rustPlatform; [
              cargoSetupHook
              maturinBuildHook
            ]);

          # The upstream [all] extra covers every supported runtime feature.
          inherit dependencies;

          # Proxy startup re-execs `python -m headroom.cli`; preserve its package closure for that child interpreter.
          makeWrapperArgs = [
            "--prefix"
            "PYTHONPATH"
            ":"
            "$out/${pyFinal.python.sitePackages}:${pyFinal.makePythonPath dependencies}"
          ];

          pythonImportsCheck = ["headroom"];
          nativeCheckInputs = with pyFinal;
            [
              cryptography
              hnswlib
              langchain-ollama
              ollama
              pytest-asyncio
              pytest-cov
              pytestCheckHook
              respx
              socksio
              xlwt
            ]
            ++ [
              final.ast-grep
              final.unzip
              prev.versionCheckHook
            ];

          versionCheckProgram = "${placeholder "out"}/bin/headroom";

          # Expose maturin's built extension there too, because pytest imports the source tree first.
          # Extract the wheel rather than selecting the extension by name: maturin's platform-specific extension
          # filename is not stable across targets.
          preCheck = ''
            unzip -o "$dist"/*.whl -d .
            export HOME="$TMPDIR/home"
            mkdir -p "$HOME"
          '';

          meta = {
            description = "Context optimization layer for LLM applications";
            homepage = "https://github.com/headroomlabs-ai/headroom";
            license = final.lib.licenses.asl20;
            mainProgram = "headroom";
          };
        });
      })
    ];
}
