final: prev: {
  suitesparse = prev.suitesparse.override {
    enableCuda = assert (
      # SuiteSparse 5.13.0..7.10.0 are not compatible with the CUDA 13 stdenv, but it is pulled into the desktop
      # closure through GEGL/GIMP. Drop this when nixpkgs updates SuiteSparse, possibly via:
      # https://github.com/NixOS/nixpkgs/pull/486083
      prev.suitesparse.version == "7.10.0"
    ); false;
  };
}
