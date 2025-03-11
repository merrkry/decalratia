{
  haskellPackages,
  stdenvNoCC,
  fishPlugins,
  fish,
  writeText,
  lib,
  tide-args ? {
    style = "Lean";
    prompt_colors = "True color";
    show_time = "24-hour format";
    lean_prompt_height = "Two lines";
    prompt_connection = "Solid";
    prompt_connection_andor_frame_color = "Darkest";
    prompt_spacing = "Sparse";
    icons = "Few icons";
    transient = "Yes";
  },
}:
let
  tide-configuration-log = import ./tide-configuration-log.nix {
    inherit
      stdenvNoCC
      fish
      writeText
      tide-args
      lib
      ;
    inherit (fishPlugins) tide;
  };
in
stdenvNoCC.mkDerivation {
  name = "tide-config.fish";
  src = ./.;
  buildInputs = [ (haskellPackages.ghcWithPackages (ps: with ps; [ extra ])) ];
  buildPhase = "runghc Main ${tide-configuration-log} > config.fish";
  env = {
    LANG = "C.UTF-8";
  };
  installPhase = ''
    install -D --mode 644 config.fish $out/conf.d/_tide_config.fish
  '';
}
