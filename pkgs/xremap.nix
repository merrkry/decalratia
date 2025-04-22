{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xremap";
  version = "0.10.10";

  src = fetchFromGitHub {
    owner = "xremap";
    repo = "xremap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U2TSx0O2T53lUiJNpSCUyvkG4Awa0+a4N6meFn09LbI";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-8IVexszltzlBBShGkjZwyDKs02udrVpZEOwfzRzAraU";

  meta = {
    description = "Key remapper for X11 and Wayland";
    homepage = "https://github.com/xremap/xremap";
    license = lib.licenses.mit;
    maintainers = [ "merrkry" ];
    mainProgram = "xremap";
  };
})
