{
  programs.ccache = {
    enable = true;
    trace = false;
    packageNames = [
      "darktable"
      "magma"
      "openmpi"
      "openvino"
      "ucx"
    ];
  };
}
