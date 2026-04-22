---
name: opencode-skill-improvement-planner
description: "OpenCode skill feedback aggregator. Use when the user wants to review OpenCode skill reflections, aggregate recurring feedback, or plan improvements to `opencode-*` skills. Produces an improvement plan for opencode-skill-editor and does not edit skills itself."
---

# OpenCode Skill Improvement Planner

Aggregates reflection files for OpenCode skills and produces a structured improvement plan. It does not edit skills; `opencode-skill-editor` applies the plan.

## Core Rules

- Planning only. Do not modify `SKILL.md` files.
- Prefer OpenCode skill state under `~/.config/opencode/skills/<skill>/reflections/**`.
- Also inspect source-controlled reflections under `opencode-config/skills/opencode-*/reflections/**` when present.
- Exclude any path with an `archive/` component.
- Follow the recursive reflection rules in `opencode-config/shared/runtime-state.md`.
- Act only on recurring evidence unless the user explicitly asks to apply one-off feedback.
- Do not spawn subagents unless the user explicitly asks for delegated analysis.

## Inputs

- `--target <skill-name>`: plan for one skill.
- `--min-reflections <N>`: default `2`.
- `--output <path>`: default `~/.config/opencode/skills/opencode-skill-improvement-planner/plans/plan-v<N>-<ISO>.md`.

## Workflow

1. Enumerate unarchived reflections for:
   - `opencode-phase-roadmap-builder`
   - `opencode-plan-phase`
   - `opencode-execute-phase`
   - `opencode-task-contextualizer`
   - `opencode-skill-improvement-planner`
   - `opencode-skill-editor`
   - `opencode-plan-detailed`
2. Parse each reflection:
   - skill name;
   - version or timestamp;
   - `What worked`;
   - `Improvements to SKILL.md`;
   - raw body when headings are missing.
3. Gate on minimum evidence:
   - zero reflections: report that there is nothing to aggregate;
   - fewer than `--min-reflections` for a skill: record as skipped.
4. Aggregate recommendations:
   - group recurring themes by skill;
   - separate actionable changes from speculative notes;
   - flag contradictions instead of resolving them silently;
   - reject repo-specific recommendations unless the target skill is intentionally repo-specific.
5. Produce a plan with:
   - frontmatter listing consumed reflection paths;
   - recommendations by skill;
   - cross-cutting recommendations;
   - speculative notes;
   - contradictions;
   - archival directive for `opencode-skill-editor`.

## Plan Format

```markdown
---
from: opencode-skill-improvement-planner
timestamp: <ISO>
min_reflections: <N>
reflections_consumed:
  - <absolute path>
---

# OpenCode skill improvement plan — <ISO>

## Summary

## Recommendations by skill

### <skill-name>
- **Change**: <directive>
  - **Rationale**: <evidence>
  - **Supporting reflections**: <ids>

## Cross-cutting recommendations

## Speculative / low-confidence notes

## Contradictions surfaced

## Archival directive for opencode-skill-editor
```

## Closeout

In Default mode, write the plan only if the user asked for an artifact. Otherwise summarize the recommendations. Do not archive reflections; that is the editor's job.

If writing self-improvement state, follow `opencode-config/shared/runtime-state.md` and use OpenCode paths only:

- Reflection: `~/.config/opencode/skills/opencode-skill-improvement-planner/reflections/<repo_hash>/<branch_slug>/<run_id>.md`
- Handoff: `~/.config/opencode/skills/opencode-skill-improvement-planner/handoffs/<repo_hash>/<branch_slug>/<run_id>.md`
- Latest handoff pointer: `~/.config/opencode/skills/opencode-skill-improvement-planner/handoffs/<repo_hash>/<branch_slug>/latest.md`

Handoff frontmatter must include `from: opencode-skill-improvement-planner`, `timestamp:`, `repo:`, `repo_root:`, `branch:`, `branch_slug:`, `commit:`, `run_id:`, and `artifact:`. Update `latest.md` with the same handoff content.
