{
  nixConfig = {
    extra-substituters = ["https://nix-gaming.cachix.org"];
    extra-trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    overlays = import ./overlays {inherit self pkgs;};
    lib = import ./lib {inherit pkgs;};
    pkgs = import nixpkgs {
      inherit system;
      overlays = [overlays.wine-10_4];
    };
  in {
    inherit lib overlays;
    packages = {
      ${system} = {
        inherit
          (inputs.nix-gaming.packages.${system})
          wine-ge
          wine-osu
          wine-tkg
          wineprefix-preparer
          winetricks-git
          umu-launcher
          ;
        wine-staging-10_4 = pkgs."wine-staging-10.4";
        wine64-staging-10_4 = pkgs."wine64-staging-10.4";
        wine64-staging-winetricks-10_4 = pkgs."wine64-staging-winetricks-10.4";
        wine-wow-staging-10_4 = pkgs."wine-wow-staging-10.4";
        wine-wow64-staging-10_4 = pkgs."wine-wow64-staging-10.4";
        wine-wow64-staging-winetricks-10_4 = pkgs."wine-wow64-staging-winetricks-10.4";
      };
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = with self.packages.${system}; [
            wine-staging-10_4
            wine64-staging-10_4
            wine64-staging-winetricks-10_4
            wine-wow-staging-10_4
            wine-wow64-staging-10_4
            wine-wow64-staging-winetricks-10_4
          ];
        };
      };
    };
  };
}
