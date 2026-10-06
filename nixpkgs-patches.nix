{fetchpatch2}: [
  (fetchpatch2 {
    # gdbuspp,openvpn3: fix build with C++20
    url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/569341.patch?full_index=1";
    hash = "sha256-RbFTpuZtHmM4gda5RGCL5zQ5MyR+bSzIioLLpM3ncHU=";
  })
  (fetchpatch2 {
    # headroom-ai: init at 0.39.1
    url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/569784/changes/d8a1143951791b077d0d998220b8c7e5642094e8.patch?full_index=1";
    hash = "sha256-mv/xSckno53poINDtpBPc9402ugm4P5k7XTEj9XVuGQ=";
  })
]
