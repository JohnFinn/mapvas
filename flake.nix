{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system} = {
      default = pkgs.mkShell {
        nativeBuildInputs = [pkgs.pkg-config];
        # Needed to get openssl-sys to use pkg-config.
        # Doesn't seem to like OpenSSL 3
        OPENSSL_NO_VENDOR = 1;

        buildInputs = [pkgs.openssl_3];
      };
    };
    defaultPackage.x86_64-linux = pkgs.rustPlatform.buildRustPackage rec {
      name = "mapvas";
      src = ./.;
      nativeBuildInputs = [pkgs.pkg-config];
      # OPENSSL_DIR = "${pkgs.openssl.dev}";
      # PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
      buildInputs = [pkgs.openssl pkgs.xorg.libX11 pkgs.xorg.libXcursor pkgs.xorg.libXrandr pkgs.xorg.libXi];
      # LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${
      #       with pkgs;
      #       lib.makeLibraryPath [ libGL xorg.libX11 xorg.libXi ]
      #     }"
      OPENSSL_NO_VENDOR = 1;
      cargoLock = {
        lockFile = "${src}/Cargo.lock";
      };
    };
  };
}
