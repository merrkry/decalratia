{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xremap";
  version = "0.10.12";

  src = fetchFromGitHub {
    owner = "xremap";
    repo = "xremap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZOiQffTHXw+anFckKO0jyd+LPw2zTqtqk87niCC38Q8=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-PqGY/fVW5jkTicKs0cONzdVrRFVOaHyVrFip4QADWck=";

  meta = {
    description = "Key remapper for X11 and Wayland";
    homepage = "https://github.com/xremap/xremap";
    license = lib.licenses.mit;
    maintainers = [ "merrkry" ];
    mainProgram = "xremap";
  };
})
