# OpenCode Runtime State

OpenCode skills store reflections, handoffs, and generated plans in repo-scoped runtime paths so unrelated repos, branches, worktrees, and runs do not collide.

## Identifiers

- `repo_hash`: first 8 hex characters of `sha256(realpath(git rev-parse --show-toplevel))`.
- `branch`: current branch name from `git branch --show-current`; when detached, use the short `HEAD` SHA.
- `branch_slug`: lowercase path-safe branch identifier. Replace any character outside `[A-Za-z0-9._-]` with `-`, collapse repeated `-`, and trim leading/trailing `-`. When HEAD is detached, use `detached-<short-sha>`.
- `commit`: short `HEAD` SHA from `git rev-parse --short HEAD`.
- `run_id`: `<UTC YYYYMMDDTHHMMSSZ>-<short random suffix>`, for example `20260420T153012Z-a1b2c3`.

## Paths

For skill name `<skill>`:

- Reflection: `~/.config/opencode/skills/<skill>/reflections/<repo_hash>/<branch_slug>/<run_id>.md`
- Handoff: `~/.config/opencode/skills/<skill>/handoffs/<repo_hash>/<branch_slug>/<run_id>.md`
- Latest handoff pointer: `~/.config/opencode/skills/<skill>/handoffs/<repo_hash>/<branch_slug>/latest.md`
- Plan output, when runtime-local: `~/.config/opencode/skills/<skill>/plans/<repo_hash>/<branch_slug>/<run_id>.md`

`latest.md` should contain the same content as the run-specific handoff, not a relative path, so downstream readers can validate frontmatter without resolving another file first.

## Handoff Frontmatter

Every handoff frontmatter must include:

```yaml
---
from: <skill-name>
timestamp: <ISO timestamp>
repo: <repo_hash>
repo_root: <absolute realpath repo root>
branch: <branch name or detached short sha>
branch_slug: <path-safe branch slug>
commit: <short HEAD sha>
run_id: <run_id>
artifact: <absolute artifact path>
---
```

The body may include warnings, follow-up items, or coordination notes for downstream skills.

## Writing Runtime State

1. Compute `repo_hash`, `branch`, `branch_slug`, `commit`, and `run_id` after resolving the current repo root.
2. Write reflections to the run-specific reflection path.
3. Write handoffs to the run-specific handoff path.
4. Update `latest.md` for the same `repo_hash` and `branch_slug` with the same handoff content.
5. Do not write Claude runtime paths from OpenCode skills.

## Reading Handoffs

Downstream readers must resolve handoffs in this order:

1. Compute the current `repo_hash`, `repo_root`, `branch`, and `branch_slug`.
2. Read `~/.config/opencode/skills/<predecessor>/handoffs/<repo_hash>/<branch_slug>/latest.md`.
3. Validate frontmatter before trusting it:
   - `from` matches the expected predecessor skill.
   - `repo` matches the current `repo_hash`.
   - `repo_root` realpath matches the current repo root.
   - `branch_slug` matches the current branch slug.
   - `branch` matches the current branch, except detached HEAD uses the current detached short SHA.
   - `commit` is present so readers can reason about staleness.
   - `artifact` is absolute, exists, and resolves under the current repo root.
4. Ignore stale, missing, malformed, or mismatched handoffs and continue from explicit inputs when possible.
5. Ask the user only when the missing handoff is necessary to proceed or when they explicitly request cross-branch or cross-repo state reuse.

## Reflection Aggregation

Reflection aggregators must scan recursively under:

- `~/.config/opencode/skills/<skill>/reflections/**`
- `opencode-config/skills/<skill>/reflections/**`

Exclude any path with an `archive/` component. When archiving consumed reflections, move each file into an `archive/` directory under the same repo and branch subtree, preserving branch isolation.
