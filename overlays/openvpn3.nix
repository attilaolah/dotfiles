final: prev: {
  openvpn3 = prev.openvpn3.overrideAttrs (oldAttrs: {
    patches =
      (oldAttrs.patches or [])
      ++ [
        (prev.fetchpatch {
          # Require C++20 for abseil-cpp 202608.
          url = "https://github.com/OpenVPN/openvpn3-linux/commit/f6b84daf83ef507a78ca4af32bf4a55470ba0043.patch";
          hash = "sha256-8AYvw6p4hw7gP9ROzjPNpsuEZtbw5c5z2goV5+arHa4=";
        })
        (prev.fetchpatch {
          # Avoid C++20 mixed-enum bitwise warnings.
          url = "https://github.com/OpenVPN/openvpn3/commit/f3e7d10dfb787de592a3b50bbe47b8a421c8d185.patch";
          hash = "sha256-8h+eIW+d4hCgJOYQzI/XOpVmhy4ojmxzzf5Hm3LcSTs=";
          extraPrefix = "openvpn3-core/";
          stripLen = 1;
        })
        (prev.fetchpatch {
          # Avoid C++20 mixed-enum arithmetic warnings.
          url = "https://github.com/OpenVPN/openvpn3/commit/11ab894befb781a3c255e64a53571f2fd697bdfe.patch";
          hash = "sha256-Dv2lOnxwZD7f2/6eauA60Q4qp+q/An/+B6Il4uHXhzU=";
          extraPrefix = "openvpn3-core/";
          stripLen = 1;
        })
      ];
  });
}
