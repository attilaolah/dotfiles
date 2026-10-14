{inputs}: final: prev: {
  opencode = prev.opencode.overrideAttrs (_: {
    src = inputs.opencode;
  });
}
