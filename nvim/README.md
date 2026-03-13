# Neovim Config

## Usage

Install from lockfile, useful when syncing configs:

```
nvim --headless "+Lazy! restore" +qa
```

Note that if plugins were added/removed, lockfile will be updated before the execution of this command.
You need to reset the lockfile and execute again.

Update without entering UI:

```
nvim --headless "+Lazy! sync" +qa
```
