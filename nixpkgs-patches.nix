{fetchpatch}: [
  (fetchpatch {
    # https://github.com/NixOS/nixpkgs/pull/569341
    url = "https://github.com/NixOS/nixpkgs/commit/6665b0d383bdd363d0e3f2009c20d129a0501e52.patch";
    hash = "sha256-D23yUFW6CCtrSUzS9fgsJmywrazVBXg7N+LN4YjJKpk=";
  })
  (fetchpatch {
    # https://github.com/NixOS/nixpkgs/pull/569341
    url = "https://github.com/NixOS/nixpkgs/commit/c4e5b4dab2130965b3cc5dc87fa74321c2c39b1a.patch";
    hash = "sha256-1jZ1utWjG9YBIGuk9nRpVFtSYq/6f1ir6P7O0EBemTs=";
  })
]
