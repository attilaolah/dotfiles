final: prev: let
  osImport = "import os";
  dhcpInfoTest = "class TestSCDynamicStoreCopyDHCPInfo(TestCase):";
in {
  inherit (final.python3Packages) pyobjc-framework-SystemConfiguration;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _: {
        pyobjc-framework-SystemConfiguration = pyFinal.buildPythonPackage rec {
          pname = "pyobjc-framework-SystemConfiguration";
          pyproject = true;

          inherit (pyFinal.pyobjc-core) version src;
          sourceRoot = "${src.name}/pyobjc-framework-SystemConfiguration";

          build-system = [pyFinal.setuptools];
          buildInputs = [prev.darwin.libffi];
          nativeBuildInputs = [prev.darwin.DarwinTools];
          nativeCheckInputs = [pyFinal.unittestCheckHook];

          # See https://github.com/ronaldoussoren/pyobjc/pull/641.
          postPatch = ''
            substituteInPlace pyobjc_setup.py \
              --replace-fail "-buildversion" "-buildVersion" \
              --replace-fail "-productversion" "-productVersion" \
              --replace-fail "/usr/bin/" ""

            substituteInPlace PyObjCTest/test_scdynamicstorecopydhcpinfo.py \
              --replace-fail '${osImport}' '${osImport}
            import unittest' \
              --replace-fail '${dhcpInfoTest}' '@unittest.skip("requires a host DHCP lease")
            ${dhcpInfoTest}'
          '';

          dependencies = with pyFinal; [
            pyobjc-core
            pyobjc-framework-Cocoa
          ];

          env.NIX_CFLAGS_COMPILE = toString [
            "-I${prev.lib.getDev prev.darwin.libffi}/include"
            "-Wno-error=unused-command-line-argument"
          ];

          pythonImportsCheck = ["SystemConfiguration"];

          meta = {
            description = "PyObjC wrappers for the SystemConfiguration framework on macOS";
            homepage = "https://github.com/ronaldoussoren/pyobjc";
            license = prev.lib.licenses.mit;
            platforms = prev.lib.platforms.darwin;
          };
        };
      })
    ];
}
