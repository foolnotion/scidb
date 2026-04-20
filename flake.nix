{
  description = "Scidb chess database application";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = rec {
        scidb = pkgs.callPackage ./nix/package.nix { src = self; };
        default = scidb;
      };
    };
}
