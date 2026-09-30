{
  programs.ccache = {
    enable = true;
    trace = false;
    packageNames = [
      "darktable"
      "magma"
      "opencv"
      "openmpi"
      "openvino"
      "ucx"
    ];
  };
}
