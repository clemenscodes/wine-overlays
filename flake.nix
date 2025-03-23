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
  } @ inputs: let
    system = "x86_64-linux";
    mkWinePkgs = {
      final,
      prev,
      version,
      src,
      patch,
      ...
    }: let
      selfBuildInputs = self:
        [
          pkgs.perl
          pkgs.autoconf
          pkgs.gitMinimal
        ]
        ++ self.buildInputs;
      selfNativeBuildInputs = self:
        [
          pkgs.autoconf
          pkgs.hexdump
          pkgs.perl
          pkgs.python3
          pkgs.gitMinimal
        ]
        ++ self.nativeBuildInputs;
      prePatch = patch: pkgs: ''
        patchShebangs tools
        cp -r ${patch}/patches ${patch}/staging .
        chmod +w patches
        patchShebangs ./patches/gitapply.sh
        python3 ./staging/patchinstall.py DESTDIR="$PWD" --all ${
          pkgs.lib.concatMapStringsSep " " (ps: "-W ${ps}") []
        }
      '';
    in {
      "wine-staging-${version}" = prev.winePackages.stagingFull.overrideAttrs (self: {
        inherit version src;
        buildInputs = selfBuildInputs self;
        nativeBuildInputs = selfNativeBuildInputs self;
        prePatch = prePatch patch pkgs;
      });
      "wine64-staging-${version}" = prev.wine64Packages.stagingFull.overrideAttrs (self: {
        inherit version src;
        buildInputs = selfBuildInputs self;
        nativeBuildInputs = selfNativeBuildInputs self;
        prePatch = prePatch patch pkgs;
      });
      "wine64-staging-winetricks-${version}" = prev.stdenv.mkDerivation {
        name = "wine64-staging-winetricks-${version}";
        phases = "installPhase";
        installPhase = ''
          mkdir -p $out/bin
          ln -s ${final."wine64-staging-${version}"}/bin/wine $out/bin/wine64
        '';
      };
      "wine-wow-staging-${version}" = prev.wineWowPackages.stagingFull.overrideAttrs (self: {
        inherit version src;
        buildInputs = selfBuildInputs self;
        nativeBuildInputs = selfNativeBuildInputs self;
        prePatch = prePatch patch pkgs;
      });
      "wine-wow64-staging-${version}" = prev.wineWow64Packages.stagingFull.overrideAttrs (self: {
        inherit version src;
        buildInputs = selfBuildInputs self;
        nativeBuildInputs = selfNativeBuildInputs self;
        prePatch = prePatch patch pkgs;
      });
      "wine-wow64-staging-winetricks-${version}" = prev.stdenv.mkDerivation {
        name = "wine-wow64-staging-winetricks-${version}";
        phases = "installPhase";
        installPhase = ''
          mkdir -p $out/bin
          ln -s ${final."wine-wow64-staging-${version}"}/bin/wine $out/bin/wine64
        '';
      };
    };
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (
          final: prev: let
            version = "10.4";
            src = prev.fetchurl rec {
              inherit version;
              url = "https://dl.winehq.org/wine/source/10.x/wine-${version}.tar.xz";
              hash = "sha256-oJAZzlxCuga6kexCPUnY8qmo6sTBqSMMc+HRGWOdXpI=";
            };
            patch = prev.fetchFromGitLab rec {
              inherit version;
              hash = "sha256-LteUANxr+w1N9r6LNztjRfr3yXtJnUMi0uayTRtFoSU=";
              domain = "gitlab.winehq.org";
              owner = "wine";
              repo = "wine-staging";
              rev = "v${version}";
            };
          in
            mkWinePkgs {inherit final prev version src patch;}
        )
      ];
    };
    winePkgs = [
    ];
  in {
    packages = {
      ${system} = {
        "wine-staging-10.4" = pkgs."wine-staging-10.4";
        "wine64-staging-10.4" = pkgs."wine64-staging-10.4";
        "wine64-staging-winetricks-10.4" = pkgs."wine64-staging-winetricks-10.4";
        "wine-wow-staging-10.4" = pkgs."wine-wow-staging-10.4";
        "wine-wow64-staging-10.4" = pkgs."wine-wow64-staging-10.4";
        "wine-wow64-staging-winetricks-10.4" = pkgs."wine-wow64-staging-winetricks-10.4";
      };
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs."wine-staging-10.4"
            pkgs."wine64-staging-10.4"
            pkgs."wine64-staging-winetricks-10.4"
            pkgs."wine-wow-staging-10.4"
            pkgs."wine-wow64-staging-10.4"
            pkgs."wine-wow64-staging-winetricks-10.4"
          ];
        };
      };
    };
  };
}
