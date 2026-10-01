# AGENTS.md

## Purpose
Pi Project Switcher manages Raspberry Pi project contexts, paths, virtual environments, and project scaffolding.

## Operating rules
- Preserve backward compatibility for existing project registries and shell usage unless explicitly changing it.
- Treat scripts as shell infrastructure: quote variables, avoid unsafe word splitting, and fail clearly.
- Never write or commit real environment secrets, credentials, SSH keys, or user-specific absolute paths unless they are documented examples.
- Do not modify the user's live project registry as part of tests.
- Prefer dry-run or temporary-directory tests for destructive filesystem behavior.

## Validation
For shell changes:
- run `bash -n` on changed shell scripts
- exercise non-destructive paths with temporary directories when practical
- verify README/ENVIRONMENT examples remain accurate

## Agent workflow
- INVESTIGATE: inspect and report.
- BUILD: implement in a feature branch with validation.
- FIX: reproduce safely, add a regression check where practical, fix, and validate.
- REVIEW: inspect quoting, path handling, destructive commands, compatibility, and documentation.

## Approval gates
Human approval is required before release/tag/push automation, destructive filesystem behavior, or changes that automatically modify other repositories.
