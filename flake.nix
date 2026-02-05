{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    overlays = import ./overlays {inherit self pkgs;};
    lib = import ./lib {inherit pkgs;};
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        overlays.wine-10_18
        overlays.wine-11_0
      ];
    };
  in {
    inherit lib overlays;
    packages = {
      ${system} = {
        wine-10_18 = pkgs."wine-wow64-staging-10.18";
        winetricks-compat-10_18 = pkgs."wine-wow64-staging-winetricks-10.18";
        wine-11_0 = pkgs."wine-wow64-staging-11.0";
        winetricks-compat-11_0 = pkgs."wine-wow64-staging-winetricks-11.0";
      };
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = with self.packages.${system};
            [
              # wine-10_18
              # wine-11_0
            ]
            ++ (with pkgs; [winetricks]);
        };
      };
    };
  };
}
