{ pkgs, ... }:
{
  xwayland-satellite = pkgs.callPackage pkgs.xwayland-satellite.override {
    rustPlatform = pkgs.rustPlatform // {
      buildRustPackage =
        args:
        pkgs.rustPlatform.buildRustPackage (
          args
          // {
            src = pkgs.fetchFromGitHub {
              owner = "Supreeeme";
              repo = "xwayland-satellite";
              rev = "76ace3c656c6680e58e53f95baac0ae0fa1178b5";
              hash = "sha256-NPSbIK8dsayXj4RbEwm+fMbnAKrTRRB/qFoWxfkRLDo=";
            };
            cargoLock = null;
            useFetchCargoVendor = true;
            cargoHash = "sha256-tzRafL9vTiMfpGmcUwnEUHtcE54RXLXUgosdkiZzNiE=";
          }
        );
    };
  };
}
