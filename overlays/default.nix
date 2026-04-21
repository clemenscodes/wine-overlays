{self, ...}: let
  splitDot = s: builtins.filter builtins.isString (builtins.split "\\." s);
  mkWineOverlay = {version, srcHash, patchHash}: let
    parts = splitDot version;
    major = builtins.head parts;
    minor = builtins.elemAt parts 1;
    subdir = if minor == "0" then "${major}.${minor}" else "${major}.x";
  in
    final: prev: let
      src = prev.fetchurl {
        inherit version;
        url = "https://dl.winehq.org/wine/source/${subdir}/wine-${version}.tar.xz";
        hash = srcHash;
      };
      patch = prev.fetchFromGitLab {
        inherit version;
        hash = patchHash;
        domain = "gitlab.winehq.org";
        owner = "wine";
        repo = "wine-staging";
        rev = "v${version}";
      };
    in
      self.lib.mkWinePkgs {inherit final prev version src patch;};
in {
  wine-10_18 = mkWineOverlay {
    version = "10.18";
    srcHash = "sha256-Uftyc9ZdCd6gMsSl4hl7EnJLJ8o2DhpiKyNz0e5QrXs=";
    patchHash = "sha256-vhIjeEbWLpcKtkBd/KeAeaLKOUZt7LAkH6GTebs3ROM=";
  };
  wine-11_0 = mkWineOverlay {
    version = "11.0";
    srcHash = "sha256-wHpoV5M8H8YN/1RI1585ySSBwenbWqYo250DWERuBwE=";
    patchHash = "sha256-Yhf0HjfrKxo/AY1jrK+iovwsx3hB/GZiWv2zeBGAels=";
  };
  wine-11_2 = mkWineOverlay {
    version = "11.2";
    srcHash = "sha256-F1Yie9s/60F1CvqXtErFCiKJCohwSh8PoU2IxPkh4YM=";
    patchHash = "sha256-Cdm+WMiFlsVro9yhJnqpUdYF5J1usScZv9JMtBE+uto=";
  };
  wine-11_4 = mkWineOverlay {
    version = "11.4";
    srcHash = "sha256-GXCkY4HTvCxE1lHQgzY3Dkme64tT3JPL0c5UT3EV5Zg=";
    patchHash = "sha256-m7QrHWaRkoWSdaj4rwuZznjM8mrkxHGEqVSLZTKf4pU=";
  };
  wine-11_7 = mkWineOverlay {
    version = "11.7";
    srcHash = "sha256-sBqyHHn+3mx71THUadma/Z3N9T6ymviK2sajMutDX58=";
    patchHash = "sha256-EjAmwSZu/Q/8QfFERnV5iz1n5CsWPneBHflQDaD4LAc=";
  };
  wine = _final: prev: {
    wine = prev.wineWow64Packages.stagingFull.overrideAttrs (self: {
      postInstall = (self.postInstall or "") + ''
        ln -sf $out/bin/wine $out/bin/wine64
      '';
    });
  };
}
