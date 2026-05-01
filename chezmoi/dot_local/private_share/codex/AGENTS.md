# AGENTS.md

Global guidelines for coding agents.

- For web development, always assume a dev server is already running. Instead, use static analysis tools for feedback.
- Use `nix shell` for temporary tools that are not yet available in environment.
- When executing any non-trivial bash command in a project with Direnv `.envrc` or Nix Flake `devShell`, execute it with `direnv exec . <command>` to ensure the devShell and other environment configurations are applied correctly. If `.envrc` doesn't exist but a devShell is available, use `nix develop -c <command>` instead.
