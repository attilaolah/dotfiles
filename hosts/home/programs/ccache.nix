{
  programs.ccache = {
    enable = true;
    packageNames = [
      "darktable"
      "opencv"
      "openvino"
    ];
  };
}
