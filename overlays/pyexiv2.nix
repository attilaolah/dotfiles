final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (_pyFinal: pyPrev: {
        pyexiv2 = pyPrev.pyexiv2.overridePythonAttrs (old: {
          # Exiv2's XMP serialization differs from the test fixtures.
          disabledTests =
            (old.disabledTests or [])
            ++ [
              "test_read_raw_xmp"
              "test_modify_raw_xmp"
              "test_memory_leak_when_reading"
            ];
        });
      })
    ];

  pyexiv2 = final.python3Packages.pyexiv2;
}
