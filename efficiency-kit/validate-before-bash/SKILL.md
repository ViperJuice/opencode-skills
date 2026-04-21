---
name: validate-before-bash
description: "Pre-validation checks before running build tools and type checkers. Use before running tsc, dart analyze, flutter build, pytest, python -m compile, or similar build/check commands. Runs prerequisite checks (tool installed, config file exists, dependencies resolved) to prevent predictable failures. Also use when starting work in a new project to verify the build environment."
---

# Validate Before Bash

## When to Run Preflight

Run the preflight script in these situations:
- Before the FIRST `tsc`, `dart analyze`, `flutter build`, `pytest`, `cargo build` in a session
- After switching to a different project directory
- After `git checkout` to a different branch (dependencies may differ)
- When a command fails with exit 127 (command not found) or missing config errors

NOT needed for: `ls`, `git status`, `cat`, `grep`, or other basic commands.

## Quick Start

```bash
bash scripts/preflight.sh [auto|typescript|python|dart|rust]
```

- `auto` mode (default): detects language from config files in the current directory
- Output is JSON: `{"ready": true/false, "language": "...", "issues": [...]}`
- Exit 0 if ready, exit 1 if issues found

## What It Checks

For each language:
- **Tool exists** on PATH (e.g., `npx`, `python3`, `cargo`)
- **Config file present** (tsconfig.json, pyproject.toml, pubspec.yaml, Cargo.toml)
- **Dependencies installed** (node_modules, .venv, .dart_tool, target/)
- **Basic version output** works (tool isn't broken)

## Using Results

If the script reports issues:
1. Fix each issue before running the build command
2. Common fixes: `npm install`, `pip install -e .`, `dart pub get`, `cargo fetch`
3. If the tool isn't installed, tell the user — don't try to install system tools without asking

## Reference

See `references/environment-checklist.md` for detailed per-language checklists covering version requirements and build-specific flags.
