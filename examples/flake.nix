{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    wine-overlays = {
      url = "github:clemenscodes/wine-overlays";
    };
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [inputs.overlays.wine-10_4];
    };
  in {
    packages = {
      ${system} = {
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
