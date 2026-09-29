{
  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
    packageNames = [
      "onnxruntime"
    ];
  };
}
