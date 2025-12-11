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
      overlays = [overlays.wine];
    };
  in {
    inherit lib overlays;
    packages = {
      ${system} = {
        inherit (pkgs) wine winetricks-compat;
      };
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = with self.packages.${system};
            [
              wine
              winetricks-compat
            ]
            ++ (with pkgs; [winetricks]);
        };
      };
    };
  };
}
