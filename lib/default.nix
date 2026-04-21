{pkgs, ...}: {
  mkWinePkgs = {
    final,
    prev,
    version,
    src,
    patch,
    ...
  }: let
    v = builtins.replaceStrings ["."] ["_"] version;
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
    "wine-${v}" = prev.wineWow64Packages.stagingFull.overrideAttrs (self: {
      inherit version src;
      buildInputs = selfBuildInputs self;
      nativeBuildInputs = selfNativeBuildInputs self;
      prePatch = prePatch patch pkgs;
      postInstall = (self.postInstall or "") + ''
        ln -sf $out/bin/wine $out/bin/wine64
      '';
    });
  };
}
