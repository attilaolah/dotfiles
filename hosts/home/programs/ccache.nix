{
  programs.ccache = {
    enable = true;
    packageNames = [
      "opencv"
      "openvino"
    ];
  };
}
