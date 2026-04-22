# Considerations

## Target harness

This repo targets **OpenCode**. Do not install these workflow skills into a different coding-agent harness. The skill names are prefixed with `opencode-` to prevent cross-framework ambiguity.

OpenCode-specific workflow skills are written for OpenCode Agent Skills and the OpenCode runtime under ~/.config/opencode.

## Runtime state

The old flat handoff/reflection layout is obsolete. Current workflow skills use the contract in `runtime-state.md`:

- `repo_hash = sha256(realpath(git rev-parse --show-toplevel))[:8]`
- `branch_slug = sanitized current branch`, or `detached-<short-sha>` when detached
- `run_id = <UTC YYYYMMDDTHHMMSSZ>-<short random suffix>`
- reflections: `$HOME/.config/opencode/skills/<skill>/reflections/<repo_hash>/<branch_slug>/<run_id>.md`
- handoffs: `$HOME/.config/opencode/skills/<skill>/handoffs/<repo_hash>/<branch_slug>/<run_id>.md`
- latest handoff pointer: `$HOME/.config/opencode/skills/<skill>/handoffs/<repo_hash>/<branch_slug>/latest.md`

Downstream skills must read `latest.md`, validate `from`, `repo`, `repo_root`, `branch`, `branch_slug`, `commit`, `run_id`, and `artifact`, and ignore mismatched handoffs unless the user explicitly asks to reuse cross-branch or cross-repo state.

## Architecture note for old sessions

If a running agent remembers unprefixed Claude-era names (`phase-roadmap-builder`, `plan-phase`, `execute-phase`, `plan-detailed`, `task-contextualizer`, `skill-improvement-planner`, `skill-editor`), redirect it to the prefixed skill in this repo. For example, use `opencode-plan-phase` instead of `plan-phase`.

## Skill groups

- `planning-chain/` contains the main roadmap -> plan -> execute loop.
- `meta/` contains the reflection aggregation and skill editing loop.
- `efficiency-kit/` contains passive utility skills. These are intentionally short and should not write runtime state.

## Installation target

Default install target: `$HOME/.config/opencode/skills`.

These framework-specific skills are intentionally not installed into `~/.agents/skills`. That directory should be reserved for future skills that are genuinely platform-neutral.

## Permission settings

Dotfiles manages OpenCode runtime permissions in `bootstrap.sh` by merging `permission.external_directory` and `permission.edit` rules into `$HOME/.config/opencode/opencode.json`. Both rules are needed for paths outside the current workspace. Keep them limited to generated `reflections/`, `handoffs/`, and `plans/` under `$HOME/.config/opencode/skills/<skill>/` and the dotfiles `opencode-config/skills` symlink target.

## Style

Keep instructions directive-first. Avoid long narrative justification, war stories, or benchmark claims. If behavior differs between frameworks, do not hide that behind a generic skill; make an explicit framework-specific port.
