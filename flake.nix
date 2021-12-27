{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, fenix, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        deps = with pkgs; [
          xorg.libX11
          xorg.libXinerama
        ];

        devToolchain = fenix.packages.${system}.stable;

        leftwm = ((naersk.lib.${system}.override {
          inherit (fenix.packages.${system}.minimal) cargo rustc;
        }).buildPackage {
          name = "leftwm";
          src = ./.;
          buildInputs = deps;
          postFixup = ''
            for p in $out/bin/leftwm*; do
              patchelf --set-rpath "${pkgs.lib.makeLibraryPath deps}" $p
            done
            # '';
        });
      in
      rec {
        # `nix build`
        packages.leftwm = leftwm;
        defaultPackage = packages.leftwm;

        # `nix run`
        apps.leftwm = flake-utils.lib.mkApp {
          drv = packages.leftwm;
        };
        defaultApp = apps.leftwm;

        # `nix develop`
        devShell = pkgs.mkShell
          {
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (deps ++ [ (pkgs.lib.getLib pkgs.systemd) ]);
            buildInputs = deps ++ [ pkgs.pkg-config ];
            nativeBuildInputs = with pkgs; [
              gnumake
              (devToolchain.withComponents [
                "cargo"
                "clippy"
                "rust-src"
                "rustc"
                "rustfmt"
              ])
              fenix.packages.${system}.rust-analyzer
            ];
          };
      });
}
