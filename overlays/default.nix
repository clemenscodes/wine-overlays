{self, ...}: {
  wine-10_4 = (
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
      self.lib.mkWinePkgs {inherit final prev version src patch;}
  );
  wine = final: prev: {
    winetricks-compat = prev.callPackage self.lib.mkWineWinetricks {inherit (final) wine;};
    wine = prev.wineWow64Packages.stagingFull;
  };
}
