# Upgrades

We use a mixture of declarative, convergent, and imperative configuration methods for maximal UX.

## Development Environments

For language toolchain and day-to-day CLIs, we prefer following upstream over relying on abstractions.

`nix-ld` is therefore needed.

## Mise

To upgrade packages:

```
mise upgrade
```

To install from lockfile:

```
mise install --locked
```

To cleanup:

```
mise prune
```

Sometimes lockfile needs to be updated manually:

```
mise lock --global
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
