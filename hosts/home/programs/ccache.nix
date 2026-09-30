{
  programs.ccache = {
    enable = true;
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
