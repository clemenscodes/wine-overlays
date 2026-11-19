# Windows DLLs of vkd3d-proton (D3D12 on Vulkan). nixpkgs' vkd3d-proton is the
# Linux build (libvkd3d-proton-*.so), so the release tarball is used instead.
{
  lib,
  stdenvNoCC,
  fetchurl,
  zstd,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vkd3d-proton-bin";
  version = "3.1";

  src = fetchurl {
    url = "https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v${finalAttrs.version}/vkd3d-proton-${finalAttrs.version}.tar.zst";
    hash = "sha256-uF6oIZtxCTo5JJE916rmFyMz3AwGmYPtUQgW1n8CEgs=";
  };

  nativeBuildInputs = [zstd];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r x64 $out/x64
    cp -r x86 $out/x32
    runHook postInstall
  '';

  meta = {
    description = "D3D12 to Vulkan translation layer, Windows DLLs for Wine prefixes";
    homepage = "https://github.com/HansKristian-Work/vkd3d-proton";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
  };
})
