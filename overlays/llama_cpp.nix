final: prev: let
  github-tags = ["ggml-org/llama.cpp" "0.8.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-WQAtD8Hos6fEtgPQId7nZiLGyP4asAMKJYEXZid1nqc=";
  hash-npm-deps = "sha256-XLtEZsSFdk+2SyfXzBp8HQ2e27PQPpDCn1YjePU1/9w=";
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
