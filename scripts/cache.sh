#! /usr/bin/env nix-shell
#! nix-shell -i bash -p attic-client

hosts=("akahi" "cryolite" "hoshinouta" "karanohako"  "perimadeia"  "sapphire")

for host in "${hosts[@]}"; do
  nix build .#nixosConfigurations."$host".config.system.build.toplevel --out-link ".cache/$host"
  attic push s3 ".cache/$host"
done
