---
name: skill-identifier
description: When to trigger this skill - be specific about the scenarios where Claude should use it
---

# Skill Name

Brief overview of what this skill provides.

## When to Use

Specific triggers that should activate this skill:
- User asks to [do X]
- User mentions [keyword Y]
- User wants to [accomplish Z]

## Instructions

Clear, concise instructions for Claude to follow when using this skill.

### Step 1: [Action]

Detailed guidance on the first step.

### Step 2: [Action]

Detailed guidance on the second step.

## Examples

```bash
# Example command or code snippet
```

## Notes

- **references/**: Place detailed documentation here (loaded only when needed)
- **scripts/**: Place reusable scripts here for deterministic operations
- **assets/**: Place templates, config files, or other resources here

## Important Principles

1. **Directive-only** — no narratives, war stories, anecdotes, or stats (e.g. "47% of sessions…", "we got burned last quarter…"). Rules only, in imperative form. If a rule needs a reason, state it in one clause, not a paragraph.
2. **Description is for triggering** — describe *when* the skill fires and *what* it does. Never cite metrics, session counts, or incident rates.
3. **Keep SKILL.md concise** — you share the context window with the conversation. Target <300 lines; move long rationales to `references/`.
4. **Use references/ for details** — link to them rather than duplicating content.
5. **Scripts for consistency** — Python/Bash for operations that need exact behavior.
