# Upgrades

We use a mixture of declarative, convergent, and imperative configuration methods for maximal UX.

## Development Environments

For language toolchain and day-to-day CLIs, we prefer following upstream over relying on abstractions.

`nix-ld` is therefore needed.

## Mise

Mise's UX for lockfiles is really strange.
`mise upgrade` doesn't update lockfile, we need to run `mise lock --global` separately, which performs yet another round of download and calculations.

For now we simply use `"latest"` without lockfiles.
Might lock version with semver in the future.

To upgrade packages:

```
mise upgrade
```

To install from config file:

```
mise install
```

To cleanup:

```
mise prune
```

## Rustup

Mise doesn't play well with nightly rust. See [Better support for rust@nightly · jdx/mise · Discussion #4737](https://github.com/jdx/mise/discussions/4737).

Install `rustup` from upstream scripts with options below:

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

- `default` profile
- default to nightly toolchain
- not modifying PATH

For finalizing setup / daily upgrades, run:

```
just rustup
```
