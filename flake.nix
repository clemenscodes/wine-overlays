{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      toSuffix = v: builtins.replaceStrings [ "." ] [ "_" ] v;
      wineVersions = [
        "10.18"
        "11.0"
        "11.2"
        "11.4"
        "11.7"
      ];
      system = "x86_64-linux";
      overlays = import ./overlays { inherit self; };
      pkgs = import nixpkgs {
        inherit system;
        overlays = map (v: overlays."wine-${toSuffix v}") wineVersions;
      };
      lib = import ./lib { inherit pkgs; };
      winePackages = builtins.foldl' (
        acc: v: acc // { "wine-${toSuffix v}" = pkgs."wine-${toSuffix v}"; }
      ) { } wineVersions;
    in
    {
      inherit lib overlays;
      packages = {
        ${system} = winePackages;
      };
      devShells = {
        ${system} = {
          default = pkgs.mkShell {
            buildInputs =
              with self.packages.${system};
              [
                # wine-10_18
                # wine-11_0
                # wine-11_2
                # wine-11_4
                wine-11_7
              ]
              ++ (with pkgs; [ winetricks ]);
          };
        };
      };
    };
}
