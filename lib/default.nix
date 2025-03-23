{pkgs, ...}: {
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
}
