{
  description = "Scidb chess database application";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in {
      packages.${system} = rec {
        scidb = pkgs.callPackage ./nix/package.nix { src = self; vistaFonts = pkgs."vista-fonts"; };
        default = scidb;
      };
    };
}
