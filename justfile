switch:
    nixos-rebuild switch --flake .#$HOSTNAME --use-remote-sudo

switch-boot:
    nixos-rebuild boot --flake .#$HOSTNAME --use-remote-sudo

localHostName := '$HOSTNAME'
evalTarget := 'system.build.toplevel'
eval hostname=localHostName attribute=evalTarget:
    nix eval --json .#nixosConfigurations.{{hostname}}.config.{{attribute}} | jq .
