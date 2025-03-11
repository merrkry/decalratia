{
  stdenvNoCC,
  tide,
  fish,
  writeText,
  tide-args,
  lib,
}:
let
  load-plugin = writeText "load-plugin.fish" ''
    set -l plugin_dir ${tide.src}

    # Set paths to import plugin components
    if test -d $plugin_dir/functions
        set fish_function_path $fish_function_path[1] $plugin_dir/functions $fish_function_path[2..-1]
    end

    if test -d $plugin_dir/completions
        set fish_complete_path $fish_complete_path[1] $plugin_dir/completions $fish_complete_path[2..-1]
    end

    # Source initialization code if it exists.
    if test -d $plugin_dir/conf.d
        for f in $plugin_dir/conf.d/*.fish
            source $f
        end
    end

    if test -f $plugin_dir/key_bindings.fish
        source $plugin_dir/key_bindings.fish
    end

    if test -f $plugin_dir/init.fish
        source $plugin_dir/init.fish
    end
  '';
  run =
    let
      tide-arg-names = builtins.attrNames tide-args;
      tide-arg-strings = map (x: "--${x}='${tide-args."${x}"}'") tide-arg-names;
      tide-arg-string = lib.concatStringsSep " " tide-arg-strings;
    in
    writeText "run.fish" "fish_trace=1 tide configure --auto ${tide-arg-string}";
in
stdenvNoCC.mkDerivation {
  name = "tide-configuration-log";
  nativeBuildInputs = [ fish ];
  unpackPhase = "true";
  buildPhase = ''
    export HOME=$PWD
    export XDG_CONFIG_HOME=$PWD/config
    mkdir -p config/fish/conf.d
    cp ${load-plugin} config/fish/conf.d/load-plugin.fish
    fish --debug-output=$PWD/tide_debug_output ${run}
  '';
  installPhase = ''
    cat tide_debug_output > $out
  '';
}
