final: prev: let
  github-tags = ["ggml-org/llama.cpp" "0.6.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-l6l6JIlIVTaVC6xh5M4fRHFtXsweQuugtkNTWHcZZF4=";
  hash-npm-deps = "sha256-a17M+L3nLdRnN6WMB6imPFmwqG2g8uv+gwN0XTAUrf8=";
  version = builtins.elemAt github-tags 1;
in {
  llama-cpp = prev.llama-cpp.overrideAttrs (old: {
    inherit version;
    npmDepsHash = hash-npm-deps;
    preCheck = (old.preCheck or "") + ''
      cat >> "$NIX_BUILD_TOP/.ctest-excluded-tests" <<'EOF'
      test-recurrent-state-rollback
      test-save-load-state
      EOF
    '';
    src = import ./lib/fetch_from_github_tuple.nix prev {
      inherit github-tags hash-src;
      rev = "v${version}";
    };
  });
}
