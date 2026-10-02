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
          bundledTools = with final; [
            ast-grep
            difftastic
            scc
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
            "--prefix"
            "PATH"
            ":"
            (final.lib.makeBinPath bundledTools)
          ];

          pythonImportsCheck = ["headroom"];
          disabledTests = [
            # These tests cover service/process management or platform behavior untestable in the test sandbox.
            "test_bash_native_installer_supports_persistent_docker_lifecycle"
            "test_bash_native_wrapper_supports_opencode"
            "test_device_authorization_uses_form_encoded_request"
            "test_device_poll_uses_form_encoded_request"
            "test_dynamic_detector_import_skips_optional_ml_dependencies"
            "test_ensure_proxy_dependencies_exits_when_fastapi_missing"
            "test_exchange_token_sync_raises_for_http_error"
            "test_install_supervisor_darwin_windows_and_unsupported"
            "test_ordinary_install_does_not_adopt_serena"
            "test_proxy_command_exits_when_mcp_missing"
            "test_quiesce_turns_config_is_honored"
            "test_readyz_excludes_kompress_from_aggregate_readiness"
            "test_readyz_keeps_pending_kompress_unloaded"
            "test_readyz_kompress_state_matrix"
            "test_readyz_never_calls_lazy_kompress_getters"
            "test_replayed_marker_is_not_rebooked_in_the_emitted_savings"
            "test_run_server_uses_selector_loop_on_windows"
            "test_runtime_start_lock_blocks_another_process"
            "test_sighup_on_launch_tool_reaps_the_proxy"
            "test_verbatim_read_never_cache_written_before_maturation"
            # These tests download a SentenceTransformer model from Hugging Face, which is unavailable in the sandbox.
            "test_cpu_embed_workers_are_thread_capped"
            "test_cpu_uses_dedicated_thread_capped_executor"
            "test_embed_single"
            "test_embed_batch"
            "test_similar_texts_have_high_similarity"
          ];
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
            ++ bundledTools
            ++ [
              final.unzip
              prev.versionCheckHook
            ];

          versionCheckProgram = "${placeholder "out"}/bin/headroom";

          preCheck = ''
            export HOME="$TMPDIR/home"
            mkdir -p "$HOME"

            # Fail fast for optional Hugging Face models, which cannot be downloaded in the test sandbox.
            export HF_HUB_OFFLINE=1

            # Use LiteLLM's bundled price map; the test sandbox has no network access.
            export LITELLM_LOCAL_MODEL_COST_MAP=True

            # Pytest imports the source tree first, so expose maturin's built extension from the wheel.
            # Extract the full wheel because the extension's platform-specific filename is not stable across targets.
            unzip -o "$dist"/*.whl -d .
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
