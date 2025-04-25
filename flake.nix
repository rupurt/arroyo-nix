{
  description = "Nix flake for arroyo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    arroyo-src = {
      url = "github:ArroyoSystems/arroyo?ref=refs/tags/v0.14.0";
      flake = false;
    };
  };

  outputs = {
    flake-utils,
    nixpkgs,
    arroyo-src,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [];
      };
    in rec {
      # packages exported by the flake
      packages = rec {
        arroyo = pkgs.rustPlatform.buildRustPackage {
          pname = "arroyo";
          version = "v0.14.0";

          src = arroyo-src;
          # doCheck = false;
          nativeBuildInputs = with pkgs; [
            grpc-tools
            jemalloc
            openssl
            perl
          ];

          useFetchCargoVendor = true;
          cargoHash = "sha256-RypK7D4DaWBhTHJzXkp0b8S9fFRh8YkI3Mh7l0hlajA=";

          meta = {
            description = "Distributed stream processing engine in Rust";
            homepage = "https://github.com/ArroyoSystems/arroyo";
            license = pkgs.lib.licenses.mit;
          };
        };
        default = arroyo;
      };

      # nix fmt
      formatter = pkgs.alejandra;

      # nix develop -c $SHELL
      devShells.default = pkgs.mkShell {
        packages = [
          packages.arroyo
        ];

        shellHook = ''
          export IN_NIX_DEVSHELL=1;
        '';
      };
    });
  in
    outputs;
}
