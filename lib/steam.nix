{pkgs, ...}: let
  # Proton's lsteamclient (Steamworks bridge to the native steamclient.so of
  # the running Linux Steam client) and steam_helper (steam.exe, which sets up
  # the Steam registry keys and environment and then starts the game).
  proton-src = pkgs.fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "Proton";
    rev = "1f089f5610a882c8bfcb4b58a3c86ee88bb4b9f1"; # proton_11.0, 2026-11-10
    hash = "sha256-Z7mvEHVE4rEE535Y4dz5+LGEzIaAAXD74hG0f3MHg+E=";
  };
in {
  inherit proton-src;

  # A wine build that also carries lsteamclient.dll and steam.exe, plus the
  # ntdll loader redirect from the native steamclient to lsteamclient. The
  # redirect only happens with WINE_LSTEAMCLIENT=1, so without it the build
  # behaves like the one it is made from.
  withLsteamclient = wine:
    wine.overrideAttrs (old: {
      pname = "${old.pname}-lsteamclient";
      patches = (old.patches or []) ++ [../patches/ntdll-lsteamclient.patch];
      postPatch =
        (old.postPatch or "")
        + ''
          cp -r ${proton-src}/lsteamclient dlls/lsteamclient
          cp -r ${proton-src}/steam_helper programs/steam
          chmod -R u+w dlls/lsteamclient programs/steam
          # Its unix side is C++, and upstream makedep links unix libraries
          # with the C compiler, so libstdc++ has to be named explicitly.
          sed -i '/^UNIXLIB/a UNIX_LIBS = -lstdc++' dlls/lsteamclient/Makefile.in
          grep -q '^UNIX_LIBS = -lstdc++$' dlls/lsteamclient/Makefile.in
          sed -i 's|^WINE_CONFIG_MAKEFILE(dlls/lz32)$|&\nWINE_CONFIG_MAKEFILE(dlls/lsteamclient)|' configure.ac
          sed -i 's|^WINE_CONFIG_MAKEFILE(programs/start)$|&\nWINE_CONFIG_MAKEFILE(programs/steam)|' configure.ac
          grep -q '^WINE_CONFIG_MAKEFILE(dlls/lsteamclient)$' configure.ac
          grep -q '^WINE_CONFIG_MAKEFILE(programs/steam)$' configure.ac
          autoreconf -f
        '';
    });
}
