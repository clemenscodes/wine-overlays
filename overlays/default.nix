{self, ...}: {
  wine-10_18 = (
    final: prev: let
      version = "10.18";
      src = prev.fetchurl rec {
        inherit version;
        url = "https://dl.winehq.org/wine/source/10.x/wine-${version}.tar.xz";
        hash = "sha256-Uftyc9ZdCd6gMsSl4hl7EnJLJ8o2DhpiKyNz0e5QrXs=";
      };
      patch = prev.fetchFromGitLab rec {
        inherit version;
        hash = "sha256-vhIjeEbWLpcKtkBd/KeAeaLKOUZt7LAkH6GTebs3ROM=";
        domain = "gitlab.winehq.org";
        owner = "wine";
        repo = "wine-staging";
        rev = "v${version}";
      };
    in
      self.lib.mkWinePkgs {inherit final prev version src patch;}
  );
  wine-11_0 = (
    final: prev: let
      version = "11.0";
      src = prev.fetchurl rec {
        inherit version;
        url = "https://dl.winehq.org/wine/source/11.0/wine-${version}.tar.xz";
        hash = "sha256-wHpoV5M8H8YN/1RI1585ySSBwenbWqYo250DWERuBwE=";
      };
      patch = prev.fetchFromGitLab rec {
        inherit version;
        hash = "sha256-Yhf0HjfrKxo/AY1jrK+iovwsx3hB/GZiWv2zeBGAels=";
        domain = "gitlab.winehq.org";
        owner = "wine";
        repo = "wine-staging";
        rev = "v${version}";
      };
    in
      self.lib.mkWinePkgs {inherit final prev version src patch;}
  );
  wine-11_2 = (
    final: prev: let
      version = "11.2";
      src = prev.fetchurl rec {
        inherit version;
        url = "https://dl.winehq.org/wine/source/11.x/wine-${version}.tar.xz";
        hash = "sha256-F1Yie9s/60F1CvqXtErFCiKJCohwSh8PoU2IxPkh4YM=";
      };
      patch = prev.fetchFromGitLab rec {
        inherit version;
        hash = "sha256-Cdm+WMiFlsVro9yhJnqpUdYF5J1usScZv9JMtBE+uto=";
        domain = "gitlab.winehq.org";
        owner = "wine";
        repo = "wine-staging";
        rev = "v${version}";
      };
    in
      self.lib.mkWinePkgs {inherit final prev version src patch;}
  );
  wine = final: prev: {
    winetricks-compat = prev.callPackage self.lib.mkWineWinetricks {inherit (final) wine;};
    wine = prev.wineWow64Packages.stagingFull;
  };
}
