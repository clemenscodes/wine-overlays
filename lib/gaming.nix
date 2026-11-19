{pkgs, ...}: let
  vkd3d-proton-bin = pkgs.callPackage ../pkgs/vkd3d-proton-bin.nix {};
  dxvk-nvapi-bin = pkgs.callPackage ../pkgs/dxvk-nvapi-bin.nix {};
in {
  inherit vkd3d-proton-bin dxvk-nvapi-bin;

  # Package a launcher with a desktop entry and an icon, so it shows up in the
  # application menu. The entry id, the Icon= name and the icon file all equal
  # `name`, which is how icon themes resolve it. `wmClass` is the class of the
  # game window, for docks and taskbars to match the window to the entry.
  mkGameApp = {
    launcher,
    desktopName,
    name ? launcher.meta.mainProgram or launcher.name,
    # PNG, installed as hicolor 256x256
    icon ? null,
    wmClass ? null,
  }: let
    inherit (pkgs) lib;
    desktop = pkgs.writeText "${name}.desktop" (
      ''
        [Desktop Entry]
        Type=Application
        Name=${desktopName}
        Exec=${launcher}/bin/${name}
        Categories=Game;
      ''
      + lib.optionalString (icon != null) "Icon=${name}\n"
      + lib.optionalString (wmClass != null) "StartupWMClass=${wmClass}\n"
    );
  in
    pkgs.runCommand name {} (
      ''
        mkdir -p $out/bin $out/share/applications
        ln -s ${launcher}/bin/${name} $out/bin/${name}
        install -m 644 ${desktop} $out/share/applications/${name}.desktop
      ''
      + lib.optionalString (icon != null) ''
        install -Dm 644 ${icon} $out/share/icons/hicolor/256x256/apps/${name}.png
      ''
    );

  # A launcher that runs a game on a plain wine build with the parts Proton
  # would otherwise bring: DXVK (D3D8 to 11), vkd3d-proton (D3D12), and on
  # NVIDIA dxvk-nvapi plus the driver's NGX DLLs for DLSS, frame generation and
  # Reflex. HDR comes from wine's own winewayland.drv (wp_color_manager_v1),
  # DXVK and vkd3d-proton only need DXVK_HDR=1 to offer HDR swapchains.
  #
  # The prefix is brought up to date whenever any of these store paths or
  # options change, recorded in a stamp file in the prefix. Without `exe` the
  # launcher runs whatever it is given, e.g. `<name> setup.exe`.
  mkGamingLauncher = {
    name,
    wine,
    # Prefix directory, may reference $HOME
    prefix,
    # Game executable: an absolute path (e.g. in a Steam library, may
    # reference $HOME) or a path relative to the prefix. The game starts in
    # the directory of the executable.
    exe ? null,
    args ? [],
    # NVIDIA driver package (e.g. config.hardware.nvidia.package), enables
    # dxvk-nvapi and copies nvngx*.dll from its lib/nvidia/wine
    nvidia ? null,
    hdr ? true,
    # Use winewayland.drv instead of winex11.drv for this prefix
    wayland ? true,
    # Experimental: Steamworks through the running Linux Steam client, without
    # Proton. Needs a wine from withLsteamclient and `exe`. Example:
    # { appId = 1091500; }. Starts `steam -silent` when Steam is not running.
    steam ? null,
    env ? {},
    # The DLLs are in the bin output, out only holds the setup script
    dxvk ? pkgs.dxvk.bin,
    vkd3d-proton ? vkd3d-proton-bin,
    dxvk-nvapi ? dxvk-nvapi-bin,
  }: let
    inherit (pkgs) lib;
    nvapi = nvidia != null;
    useSteam = steam != null;
    appId = toString steam.appId;
    steamDir = steam.steamDir or "$HOME/.steam/steam";
    overrides =
      ["d3d8,d3d9,d3d10core,d3d11,dxgi,d3d12,d3d12core=n,b"]
      ++ lib.optional nvapi "nvapi,nvapi64,nvofapi64=n"
      # the builtin steam.exe is Proton's steam_helper, not Valve's SteamService
      ++ lib.optional useSteam "steam.exe=b";
    stamp = lib.concatStringsSep " " (
      [wine dxvk vkd3d-proton "wayland=${lib.boolToString wayland}"]
      ++ lib.optionals nvapi [dxvk-nvapi nvidia]
    );
    exports = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg v}") (
        lib.optionalAttrs nvapi {DXVK_ENABLE_NVAPI = "1";}
        // lib.optionalAttrs hdr {DXVK_HDR = "1";}
        # On winewayland, closing the game window destroys the wl_surface
        # before the game releases its D3D12 swapchain, and vkd3d-proton then
        # waits forever in present_wait for a frame the compositor never
        # acknowledges, so the game never exits. Without present_wait it
        # exits normally, at the cost of vkd3d-proton's latency limiting.
        // lib.optionalAttrs wayland {VKD3D_DISABLE_EXTENSIONS = "VK_KHR_present_wait,VK_KHR_present_wait2";}
        // lib.optionalAttrs useSteam {
          WINE_LSTEAMCLIENT = "1";
          SteamAppId = appId;
          SteamGameId = appId;
        }
        // env
      )
    );
    # The real Windows client files, which ntdll redirects to lsteamclient.
    # Steam updates them, so they are synced on every start.
    steamSetup = ''
      steam_dir="$(readlink -f "${steamDir}")"
      export STEAM_COMPAT_CLIENT_INSTALL_PATH="$steam_dir"

      if ! pgrep -x steam >/dev/null; then
        echo "${name}: starting Steam in the background" >&2
        setsid steam -silent >/dev/null 2>&1 </dev/null &
        for _ in $(seq 120); do
          pgrep -x steamwebhelper >/dev/null && break
          sleep 0.5
        done
      fi

      steam_pfx="$WINEPREFIX/drive_c/Program Files (x86)/Steam"
      mkdir -p "$steam_pfx"
      for pair in steamclient.dll:steamclient.dll steamclient64.dll:steamclient64.dll \
                  GameOverlayRenderer64.dll:GameOverlayRenderer64.dll \
                  SteamService.exe:steam.exe Steam.dll:Steam.dll; do
        src="$steam_dir/legacycompat/''${pair%%:*}"
        dst="$steam_pfx/''${pair##*:}"
        [ -f "$src" ] || continue
        cmp -s "$src" "$dst" 2>/dev/null || place "$src" "$steam_pfx" "''${pair##*:}"
      done
    '';
    gamePath =
      if lib.hasPrefix "/" exe || lib.hasPrefix "$HOME" exe
      then exe
      else "$WINEPREFIX/${exe}";
    # Not exec'd: the Windows processes outlive the wine loader, so the
    # launcher owns the prefix and kills the whole wine process tree through
    # wineserver when it ends for any reason. INT/TERM/HUP and a normal exit
    # go through the EXIT trap, a SIGKILL through the watchdog.
    runWine = cmd: ''
      trap '${wine}/bin/wineserver -k 2>/dev/null || true' EXIT
      trap 'exit 130' INT
      trap 'exit 143' TERM
      trap 'exit 129' HUP
      launcher=$$
      (
        trap "" INT TERM HUP
        while kill -0 "$launcher" 2>/dev/null; do sleep 1; done
        ${wine}/bin/wineserver -k 2>/dev/null || true
      ) &
      ${cmd} &
      wait $! || status=$?
      exit "''${status:-0}"
    '';
    run =
      if exe == null
      then runWine ''${wine}/bin/wine "$@"''
      else ''
        game="${gamePath}"
        cd "$(dirname "$game")"
        ${runWine (
          if useSteam
          then ''${wine}/bin/wine 'C:\windows\system32\steam.exe' "$game" ${lib.escapeShellArgs args} "$@"''
          else ''${wine}/bin/wine "$game" ${lib.escapeShellArgs args} "$@"''
        )}
      '';
  in
    assert lib.assertMsg (!useSteam || exe != null) "mkGamingLauncher: steam needs exe";
    assert lib.assertMsg (!useSteam || lib.hasSuffix "-lsteamclient" (wine.pname or ""))
    "mkGamingLauncher: steam needs a wine from withLsteamclient";
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [pkgs.coreutils pkgs.util-linux] ++ lib.optionals useSteam [pkgs.procps pkgs.diffutils];
        text = ''
          export WINEPREFIX="${prefix}"
          export WINEDEBUG="''${WINEDEBUG:--all}"

          # The launcher kills the whole prefix when it ends, so a second
          # start must not run next to a first one. The lock is inherited by
          # the wine processes and only released once all of them are gone.
          mkdir -p "$WINEPREFIX"
          exec 9>"$WINEPREFIX/.wine-overlays.lock"
          if ! flock -w 10 9; then
            echo "${name}: $WINEPREFIX is already in use by another instance" >&2
            exit 1
          fi
          export WINEDLLOVERRIDES="${lib.concatStringsSep ";" overrides}''${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}"
          ${exports}

          # New inode via rename, so a running wine process keeps its mapping.
          place() {
            local target
            target="$2/''${3:-$(basename "$1")}"
            cp "$1" "$target.wine-overlays-new"
            chmod 644 "$target.wine-overlays-new"
            mv -f "$target.wine-overlays-new" "$target"
          }

          stamp_file="$WINEPREFIX/.wine-overlays-gaming"
          if [ "$(cat "$stamp_file" 2>/dev/null)" != "${stamp}" ]; then
            echo "${name}: updating $WINEPREFIX" >&2
            mkdir -p "$WINEPREFIX"
            ${wine}/bin/wineboot -u
            ${wine}/bin/wineserver -w

            system32="$WINEPREFIX/drive_c/windows/system32"
            syswow64="$WINEPREFIX/drive_c/windows/syswow64"

            for dll in ${dxvk}/x64/*.dll ${vkd3d-proton}/x64/*.dll; do place "$dll" "$system32"; done
            for dll in ${dxvk}/x32/*.dll ${vkd3d-proton}/x32/*.dll; do place "$dll" "$syswow64"; done
            ${lib.optionalString nvapi ''
            for dll in ${dxvk-nvapi}/x64/*.dll ${nvidia}/lib/nvidia/wine/*.dll; do place "$dll" "$system32"; done
            for dll in ${dxvk-nvapi}/x32/*.dll; do place "$dll" "$syswow64"; done
            # DLSS looks up the NGX DLLs through this key, as under Proton
            ${wine}/bin/wine reg add 'HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore' /v FullPath /d 'C:\Windows\System32' /f >/dev/null
          ''}
            ${
            if wayland
            then ''${wine}/bin/wine reg add 'HKCU\Software\Wine\Drivers' /v Graphics /d wayland /f >/dev/null''
            else ''${wine}/bin/wine reg delete 'HKCU\Software\Wine\Drivers' /v Graphics /f >/dev/null 2>&1 || true''
          }
            ${wine}/bin/wineserver -w
            echo "${stamp}" > "$stamp_file"
          fi

          ${lib.optionalString useSteam steamSetup}
          ${run}
        '';
      };
}
