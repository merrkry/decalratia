{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xremap";
  version = "0.10.11";

  src = fetchFromGitHub {
    owner = "xremap";
    repo = "xremap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z9QgiwG4muKYc1N9ycjs9r9QXB8JvzTdkCxu2c3mB9o=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-X2tcyf+vG6VFscInyDpcfZr79mSF+M9ziA6/cMJCL7w=";

  meta = {
    description = "Key remapper for X11 and Wayland";
    homepage = "https://github.com/xremap/xremap";
    license = lib.licenses.mit;
    maintainers = [ "merrkry" ];
    mainProgram = "xremap";
  };
})
