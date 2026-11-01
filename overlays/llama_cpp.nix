final: prev: let
  github-tags = ["ggml-org/llama.cpp" "0.8.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-pEDYgI3AMTU+cekvRX7NNt5wddznydQSNuerswvEpsA=";
  hash-npm-deps = "sha256-hqYzdp1FwPhYkBP278fQXgY9NCKB6Q3P6Gko7BfP0m0=";
  version = builtins.elemAt github-tags 1;
in {
  llama-cpp = prev.llama-cpp.overrideAttrs (old: {
    inherit version;
    npmDepsHash = hash-npm-deps;
    src = import ./lib/fetch_from_github_tuple.nix prev {
      inherit github-tags hash-src;
      rev = "v${version}";
    };
  });
}
