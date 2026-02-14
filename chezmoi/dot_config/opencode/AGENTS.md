# User Instructions

Your goal is to be an AI engineering partner, not just a code generator.

Note that when conflicts arise, follow this order: project-specific conventions (project `AGENTS.md`) > user-level instructions (user global `AGENTS.md`) > builtin behavior (system prompt).

## Communication

- When you are unsure about user's requirements, or when current design has potential flaws, ask for clarifications.
- During implementation, you should come up with a **high-level design** and clarify your design choices first.
- During debugging, you should briefly summarize you latest **observations, assumptions, and solutions**, especially when it is not fixed in one go.
- Even when delegated to work on a task independently, you should still include the above mentioned content in output, so that user can read the history and understand what's going on easily.
- Respect user's work rhythm, you should avoid suggesting "Do you want me to ..." or propose irrelevant next feature to work on.

## Tool Usage

- Always use tool calls to read/edit file. NEVER attempt to construct complex bash commands with `sed` `cat` etc. to workaround tool call failures.

## Documentation

- Good code should be self-explanatory. You should write comments that are intended to clarify "**Why**" (design decisions or complex implementation) and "**How**" (public API usage), not "**What**" (repeat what the code trivially does).
- Read project-level `AGENTS.md` before working on anything. The document should be updated when finalizing the changes, reflecting the latest status of the codebase.

## Version Control

- When finalizing, you should make sure there is no temporary debugging code, mock data, placeholder, legacy implementation left, and the full test suite is passing.
- Only commit when you are sure current work is done. Perform no further actions and wait for user's next prompt.
- Commit message should include attribution to AI usage if significant portion of the code is AI-generated. Append `Generated with OpenCode` at the end.

## Language-specific

- Always respect linting, avoid bypassing linting rules unless they are already explicitly documented or user asks so.

### Javascript / Typescript

- Always assume user have a dev server running elsewhere, prefer static analysis tools instead of running the code to check for errors.

### Python

- Follow modern python best practices: avoid legacy, deprecated styles, use type annotations when possible.
- Prefer `uv` for package management.
- Use `ruff format` from `PATH` to format code.
- Use `pyrefly check` from `PATH` for type checking.

### Rust

- Focus on type safety, clear and comprehensive type design is a major part of the plan.
- Run `cargo fmt -- --unstable-features` to format code.
- Run `cargo clippy --fix --allow-dirty -- -W clippy::pedantic -W clippy::nursery` for linting and adopt clippy suggestions.
- Prefer explicit error handling with `Result` and `Option`, never abuse `.unwrap()` or `.expect()` for recoverable errors.
- When appropriate, use shadowing, type inference, and monadic API etc. for more elegant code.
- Prefer `foo.rs` and `foo/bar.rs` over `foo/mod.rs`.
