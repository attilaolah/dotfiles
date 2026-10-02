_final: prev: {
  opencode = prev.opencode.overrideAttrs (oldAttrs:
    oldAttrs
    // {
      # Remove when upstream releases the fix:
      # https://github.com/anomalyco/opencode/pull/50622
      postInstall = let
        oldPostInstall = oldAttrs.postInstall;
        oldCompletionInvocations = [
          "--bash <($out/bin/opencode completion)"
          "--bash <($out/bin/opencode2 completion)"
          "--zsh <(SHELL=/bin/zsh $out/bin/opencode completion)"
          "--zsh <(SHELL=/bin/zsh $out/bin/opencode2 completion)"
        ];
      in
        assert prev.lib.all (invocation: prev.lib.hasInfix invocation oldPostInstall) oldCompletionInvocations;
          prev.lib.replaceStrings
          oldCompletionInvocations
          (map (prev.lib.removeSuffix "\n") [
            ''
              --bash <($out/bin/opencode --completions bash) \
                --fish <($out/bin/opencode --completions fish)
            ''
            ''
              --bash <($out/bin/opencode2 --completions bash) \
                --fish <($out/bin/opencode2 --completions fish)
            ''
            "--zsh <(SHELL=/bin/zsh $out/bin/opencode --completions zsh)"
            "--zsh <(SHELL=/bin/zsh $out/bin/opencode2 --completions zsh)"
          ])
          oldPostInstall;
      node_modules = oldAttrs.node_modules.overrideAttrs (nodeModulesAttrs: let
        brokenHash =
          if prev.stdenv.hostPlatform.isDarwin
          then "sha256-B0m41LelD7d61vPHGIZZSO/cU7gbjHDJHt6oxNRRM8Q="
          else nodeModulesAttrs.outputHash;
        outputHash =
          if prev.stdenv.hostPlatform.isDarwin
          then "sha256-e/SZjrMOh6jxjUmrCBrUXZURqWrs3crFIrzWoqKojUw="
          else nodeModulesAttrs.outputHash;
      in
        assert nodeModulesAttrs.outputHash == brokenHash;
          nodeModulesAttrs // {inherit outputHash;});
    });
}
