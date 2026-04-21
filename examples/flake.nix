{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    wine-overlays = {
      url = "github:clemenscodes/wine-overlays";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.wine-overlays.overlays.wine-11_7 ];
      };
    in
    {
      devShells = {
        ${system} = {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.wine-11_7
              pkgs.winetricks
            ];
          };
        };
      };
    };
}
