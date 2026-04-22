---
name: opencode-phase-roadmap-builder
description: "OpenCode-optimized roadmap planner. Use when the user wants to turn a conversation, architecture discussion, or markdown spec into a multi-phase roadmap for later OpenCode planning and execution. Creates or extends versioned phase roadmap specs in execution mode, but in Plan Mode returns a proposed plan only. Do not use for single bounded changes; use opencode-plan-detailed instead."
---

# OpenCode Phase Roadmap Builder

Builds a multi-phase roadmap that downstream `opencode-plan-phase` can turn into implementation lanes. This is the OpenCode port of the Claude-oriented roadmap builder; do not edit or depend on the original skill at runtime.

## Core Rules

- Preserve Plan Mode boundaries. In Plan Mode, inspect files and produce a `<proposed_plan>` roadmap only; do not create or edit repo-tracked files.
- In Default mode, write the roadmap artifact only after enough context is available.
- During planning-only roadmap creation, do not execute test suites, builds, formatters, generators, or migrations. Capture end-to-end verification commands in the roadmap without running them.
- Use local truth first: read named specs, `AGENTS.md`, and repo docs the user explicitly points at. Do not invent phases from vague context.
- Use PMCP for external capability research when current docs or third-party tooling facts affect the roadmap. Prefer `gateway_catalog_search`, then `gateway_describe`, then `gateway_invoke`; use Context7 for library/product docs. Use Bright Data only if PMCP exposes it in the current environment.
- Use `request_user_input` only when available; in Default mode ask one concise plain-text question only if a missing decision would make the roadmap wrong.
- Prefer fewer serial phases and more parallel work inside each phase. A phase boundary exists only when a contract must freeze before downstream work starts.
- Do not spawn subagents unless the user explicitly asks for agents, subagents, delegation, or parallel agent work.

## Inputs

- Optional spec path: markdown file to fold into the roadmap.
- Optional output path: default `specs/phase-plans-v<N>.md`, choosing the highest existing version or `v1` if none exists.
- Append mode: if the output roadmap exists, add phases without rewriting prior phases unless the user explicitly requests a replacement.

## Workflow

1. Resolve repo root with `git rev-parse --show-toplevel`, then inspect:
   - the named spec, if any;
   - `AGENTS.md` and `CLAUDE.md`, if present;
   - existing `specs/phase-plans-v*.md`;
   - markdown files the user named.
2. Choose create or append mode:
   - Create mode writes a full roadmap.
   - Append mode reads existing aliases, phase numbers, dependencies, and interface gates, then appends only new phases.
3. Write top-level context:
   - `Context`
   - `Architecture North Star` when structural
   - `Assumptions`
   - `Non-Goals`
   - `Cross-Cutting Principles`
4. Decompose into phases:
   - serial phases only at interface-freeze boundaries;
   - sibling phases for independent subtrees;
   - at least two likely lanes per implementation phase unless it is a preamble or interface-only phase;
   - explicit `Depends on` and `Produces` entries.
5. Add:
   - `Top Interface-Freeze Gates`;
   - `Phase Dependency DAG`;
   - `Execution Notes` that name which phases can be planned or executed concurrently;
   - end-to-end `Verification` commands.
6. Validate manually:
   - stable headings are present;
   - aliases are unique;
   - dependency graph is acyclic;
   - every produced gate has a producing phase;
   - append mode did not silently rewrite old phases.

## Artifact Contract

Use this shape so `opencode-plan-phase` can parse it:

```markdown
# Phase roadmap v<N>

## Context

## Architecture North Star

## Assumptions

## Non-Goals

## Cross-Cutting Principles

## Top Interface-Freeze Gates
- IF-0-<ALIAS>-<N> — <frozen contract>

## Phases

### Phase N — <Name> (<ALIAS>)
**Objective**

**Exit criteria**
- [ ] <testable criterion>

**Scope notes**

**Non-goals**

**Key files**

**Depends on**
- (none)

**Produces**
- IF-0-<ALIAS>-<N> — <contract>

## Phase Dependency DAG

## Execution Notes

## Verification
```

## Closeout

In Default mode, write the roadmap with the active session's file-editing tool, then report the artifact path and the next suggested `opencode-plan-phase` invocation. Do not commit unless the user asked for a commit.

If writing self-improvement state, follow `opencode-config/shared/runtime-state.md` and use OpenCode paths only:

- Reflection: `~/.config/opencode/skills/opencode-phase-roadmap-builder/reflections/<repo_hash>/<branch_slug>/<run_id>.md`
- Handoff: `~/.config/opencode/skills/opencode-phase-roadmap-builder/handoffs/<repo_hash>/<branch_slug>/<run_id>.md`
- Latest handoff pointer: `~/.config/opencode/skills/opencode-phase-roadmap-builder/handoffs/<repo_hash>/<branch_slug>/latest.md`

Handoff frontmatter must include `from: opencode-phase-roadmap-builder`, `timestamp:`, `repo:`, `repo_root:`, `branch:`, `branch_slug:`, `commit:`, `run_id:`, and `artifact:`. Update `latest.md` with the same handoff content.
