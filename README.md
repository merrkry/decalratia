# declaratia

All configuration in one place, powered by Nix.

`decalratia` is a desensitized mirror.

## Hosts

- `akahi`: Asus TUF Gaming F15 FX507ZR
- `cryolite`: ThinkPad E14 Gen 3 (AMD)
- `hoshinouta`: "production" server of self-hosted services
- `karanohako`: Beelink EQ12 Mini PC
- `perimadeia`: another VPS
- `sapphire`: storage VPS

More machines to be migrated to this flake.

## CI

Thanks Garnix for its generous free plan.

Garnix CI will evaluate, build and cache updates of the repo. An Github Action is also deployed, to periodically bump flake inputs automatically if evaluation and builds are successful.

As Garnix's public cache doesn't require any kind of authentication by default, an attacker may be able to get private flake inputs from it, using NAR hash provided in `flake.lock`. That's why this repo is published as a mirrow, with `flake.lock` completed wiped from git history.
