# declaratia

All configuration in one place, powered by Nix.

`decalratia` is a desensitized mirror.

## Hosts

- `akahi`: Desktop workstation powered by 9700X + 9070XT
- `cryolite`: ThinkPad E14 Gen 3 (AMD)
- `ilmenite`: Services VPS
- `karanohako`: Beelink EQ12 Mini PC, NAS
- `sapphire`: Storage VPS

## Updates

To update a package, run:

```shell
nix run nixpkgs#nix-update -- <package_name> -F
```
