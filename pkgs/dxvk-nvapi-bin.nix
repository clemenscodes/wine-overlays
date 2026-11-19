# Windows DLLs of dxvk-nvapi (NVAPI on top of DXVK and vkd3d-proton), which
# DLSS, DLSS frame generation and Reflex need on NVIDIA. Not in nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dxvk-nvapi-bin";
  version = "0.9.3";

  src = fetchurl {
    url = "https://github.com/jp7677/dxvk-nvapi/releases/download/v${finalAttrs.version}/dxvk-nvapi-v${finalAttrs.version}.tar.gz";
    hash = "sha256-KEAzw45GO6MdQEZtZQ0MQR329ku/jtPRnJygyt8x39M=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/x64 $out/x32
    cp x64/nvapi64.dll x64/nvofapi64.dll $out/x64/
    cp x32/nvapi.dll $out/x32/
    runHook postInstall
  '';

  meta = {
    description = "NVAPI implementation on top of DXVK, Windows DLLs for Wine prefixes";
    homepage = "https://github.com/jp7677/dxvk-nvapi";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
