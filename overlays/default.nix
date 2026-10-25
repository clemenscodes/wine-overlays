{self, ...}: let
  splitDot = s: builtins.filter builtins.isString (builtins.split "\\." s);
  mkWineOverlay = {version, srcHash, patchHash, extraPatches ? []}: let
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
      self.lib.mkWinePkgs {inherit final prev version src patch extraPatches;};
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
  wine-11_8 = mkWineOverlay {
    version = "11.8";
    srcHash = "sha256-U6qFmV1Ll/ARahxWuKahQXcw71mid4GdLT0xNk6lVrA=";
    patchHash = "sha256-lW5dfCfsB+z84mlLpfmkR7QDxmhL+RcBufSftUutHto=";
  };
  wine-11_9 = mkWineOverlay {
    version = "11.9";
    srcHash = "sha256-45zBjbKHNYokNvivSYvtx+RE1V65nvVFtg53i7TqD28=";
    patchHash = "sha256-IQSu/Nr3JynVv95/jaZCZrCQWKE8/pp9JGEwfmDdI9s=";
  };
  wine-11_10 = mkWineOverlay {
    version = "11.10";
    srcHash = "sha256-5MNevib0+O718hQ+JKH7n9ED8dRhMq1HVUeSJ9CGuOc=";
    patchHash = "sha256-KzWZv5ljHp97FqVmoOQNQ+qhXnGK1S7uz0CtOZFGAgA=";
  };
  wine-11_11 = mkWineOverlay {
    version = "11.11";
    srcHash = "sha256-V9/ZZEi/GV78GxOGExw7oV1LLZ+vL+ujFOg9dD02040=";
    patchHash = "sha256-Seg8A8zppBUTyCx8U0SOpzWpyHtucCTCemHFzAUcozE=";
  };
  wine-11_12 = mkWineOverlay {
    version = "11.12";
    srcHash = "sha256-07wJEZLZhYRsnyAGXMgfITMfAeIrc2sTHjRJ4TBmcbw=";
    patchHash = "sha256-3pE/RVUvH56z9Ilumokl7nNMrhfksuUWzKq6k8behW4=";
  };
  wine-11_13 = mkWineOverlay {
    version = "11.13";
    srcHash = "sha256-lUg5DFBCEmtuzwryy6R3t1qj6ZvpeX6nDVAmN0xQdPE=";
    patchHash = "sha256-btsPAspaUDuTaESbyaEKMEqQD+74KZZT0iNuFYD7TO0=";
  };
  wine-11_14 = mkWineOverlay {
    version = "11.14";
    srcHash = "sha256-BrO9hyrg1NRUuaDAB3JydwFyDeGE02xoWXCIA4ET7cQ=";
    patchHash = "sha256-Xat/Xp6FcY4MVQjxz2lp36+tnlu7hoHoQw5WpZDOa2E=";
  };
  wine-11_15 = mkWineOverlay {
    version = "11.15";
    srcHash = "sha256-UEbzba4hCxmOppeSd01EAf7tl11GXspsJRyTlEAOwnI=";
    patchHash = "sha256-/mu7seIsrkXzfJjIzyrMavBT6ZC8Gz/6PZPm9TjjekE=";
  };
  wine-11_16 = mkWineOverlay {
    version = "11.16";
    srcHash = "sha256-xm4gkDQ9zXJ/f3/S+H7gv7CxGHkMHXRat7ikw6QZfy8=";
    patchHash = "sha256-14VEZMMlWCsStm2AJNO+wBPPO67EGDsQyNiFBBtIcUg=";
  };
  wine-11_17 = mkWineOverlay {
    version = "11.17";
    srcHash = "sha256-jnUuKbuikBrZ+RUTk0XG7mcYSwmdQlcE2RWXHKXAVfw=";
    patchHash = "sha256-VSYkI9XTU8Lg5UooZBlRXVQ9hVJ+YdoRr5GAc+jBDsI=";
  };
  wine-11_18 = mkWineOverlay {
    version = "11.18";
    srcHash = "sha256-xigvbU2uzxHzq5+aK2xZj2e+fijDY7osroo8RLYR56Q=";
    patchHash = "sha256-KZCkra0y3XFNrbD2lZ+YUCLyq1POC30Sd4sGCJZuwgQ=";
  };
  wine-11_19 = mkWineOverlay {
    version = "11.19";
    srcHash = "sha256-SCAGbtpo5VPTMCOf/GKBZKNI0cYj5J0FjgEcWnzalfE=";
    patchHash = "sha256-Dnb/CjzxWDdMDXfJB/hiWHhQLjU49F6OyM6qqC0g/v0=";
    extraPatches = [
      # Reject a stream connect() to destination port 0 with WSAEADDRNOTAVAIL,
      # like Windows. Fixes the in-game Battle.net web login hanging under Wine
      # (the browser self-connects to http://localhost:0/?ST=... instead of
      # failing fast, so the session ticket is never harvested). See the patch
      # header for the full root-cause analysis.
      ../patches/reject-connect-port0.patch
      # winex11: sync Win32 visibility when another X client withdraws/maps a
      # managed window, so an external unmap is not silently reverted by the
      # next SetWindowPos. Repro + analysis in ~/.local/src/wine-external-unmap-repro.
      ../patches/0001-winex11-sync-win32-visibility-on-external-withdraw-map.patch
    ];
  };
  wine =_final: prev: {
    wine = prev.wineWow64Packages.stagingFull.overrideAttrs (self: {
      postInstall = (self.postInstall or "") + ''
        ln -sf $out/bin/wine $out/bin/wine64
      '';
    });
  };
}
