---
name: batch-verify
description: "Workflow for batching edit verification instead of checking after each individual change. Use when making multiple related file edits (3+ files) in a coding session. Groups syntax checks, type checking, and test runs into a single verification phase after all edits are complete, instead of scattering verification calls throughout."
---

# Batch Verify

## The Pattern

When editing multiple related files, complete ALL edits first, THEN verify once.

**Bad**: Edit A → tsc → Edit B → tsc → Edit C → tsc (3 type-check runs)
**Good**: Edit A → Edit B → Edit C → tsc (1 type-check run)

Type checkers report project-wide errors. Running tsc after editing 1 of 5 related files just reports errors for the 4 you haven't fixed yet — that's noise, not signal.

## When to Batch

- Editing 3+ files for the same feature/fix
- Adding a new type and its usages across multiple files
- Refactoring an interface used in many places
- Any change where intermediate states are expected to have type errors

## When NOT to Batch (verify immediately instead)

- A single risky edit where you want to confirm it works before continuing
- Edits to independent features (no relationship between changes)
- Changes to build configuration (package.json, tsconfig.json) — verify these immediately

## Verification Commands

| Language | Command | What it checks |
|----------|---------|---------------|
| TypeScript | `npx tsc --noEmit` | Type errors across project |
| Python | `python -m py_compile file.py` | Syntax per file |
| Python | `pytest -x` | Tests (stop on first failure) |
| Dart | `dart analyze` | Type + lint errors |
| Rust | `cargo check` | Type errors without building |

## Workflow

1. Plan all edits needed for this change
2. Make all edits (Edit/Write calls)
3. Run ONE verification command
4. Fix any errors reported
5. Run verification again to confirm clean
