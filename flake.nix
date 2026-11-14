{
  description = "Nix package for Creem's creem CLI, tracking the npm release feed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, systems }:
    let
      inherit (nixpkgs) lib;
      eachSystem = f: lib.genAttrs (import systems) f;
      overlay = final: prev: {
        creem-cli = final.callPackage ./package.nix { };
      };
      pkgsFor = system: import nixpkgs { inherit system; overlays = [ overlay ]; };
    in
    {
      overlays.default = overlay;

      packages = eachSystem (system: rec {
        creem-cli = (pkgsFor system).creem-cli;
        default = creem-cli;
      });

      apps = eachSystem (system: rec {
        creem = {
          type = "app";
          program = "${(pkgsFor system).creem-cli}/bin/creem";
        };
        default = creem;
      });

      devShells = eachSystem (system: {
        default = (pkgsFor system).mkShell {
          packages = with (pkgsFor system); [ nixpkgs-fmt jq curl nodejs_22 prefetch-npm-deps ];
        };
      });
    };
}
