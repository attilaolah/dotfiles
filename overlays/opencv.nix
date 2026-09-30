final: prev: {
  opencv4 = prev.opencv4.overrideAttrs (oldAttrs: {
    patches =
      (oldAttrs.patches or [])
      ++ [
        (prev.fetchpatch {
          # https://github.com/NixOS/nixpkgs/pull/568676
          url = "https://github.com/opencv/opencv_contrib/commit/054007b78c8288ef2fd040e77dc0cf2e45f70c15.patch";
          hash = "sha256-vDW6kfDmwPB/tTurkDXuvViXrzXYV4njjDN6kLoIvJ4=";
          extraPrefix = "opencv_contrib/";
          stripLen = 2;
        })
      ];
  });
  opencv = final.opencv4;
}
