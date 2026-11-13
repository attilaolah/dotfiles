final: prev: let
  github-tags = ["ggml-org/llama.cpp" "1.0.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-aYziwYzK9Zj7sopAEsrANhMGs4BO0F2g0cDCGmYLxDA=";
  hash-npm-deps = "sha256-0OJIueUN5oD/V2NtVcXTiRW59u2tJIG3OxW8aJ8JDBY=";
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
