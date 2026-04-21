---
name: smart-search
description: "Guide for efficient codebase searching with Grep and Glob. Use when a search returns no results or unexpected results, or when about to perform multiple consecutive search operations. Provides common pattern mistakes (escaping, flags, scope), search planning strategies, and a decision tree for choosing between Grep, Glob, and Explore agents. Helps avoid search thrashing (3+ similar searches in sequence)."
---

# Smart Search

## Decision Tree: Pick the Right Tool

| Goal | Tool | Pattern Example |
|------|------|-----------------|
| Find a file by name | Glob | `**/{name}*` or `**/*.{ext}` |
| Find where a function/class is defined | Grep | `"(function\|class\|def\|const)\\s+NAME"` |
| Find all usages of a symbol | Grep with `--type` | `"NAME"` + `type: "ts"` |
| Find a file matching a vague description | Explore agent | Natural language prompt |
| Understand how a module works | Explore agent | Better than 10 Grep calls |

**Rule of thumb**: If you'd need 4+ Grep calls to answer a question, use an Explore agent instead.

## Ripgrep Escaping Rules

The Grep tool uses ripgrep, NOT standard grep. These characters need escaping for literal matches:

| Character | Meaning in Regex | Escape for Literal |
|-----------|-----------------|-------------------|
| `{` `}` | Repetition `{n,m}` | `\{` `\}` |
| `(` `)` | Capture group | `\(` `\)` |
| `[` `]` | Character class | `\[` `\]` |
| `\|` | Alternation (OR) | `\\\|` |
| `.` | Any character | `\.` |
| `*` | Zero or more | `\*` |
| `+` | One or more | `\+` |
| `?` | Optional | `\?` |
| `^` | Start of line | `\^` |
| `$` | End of line | `\$` |

**The #1 mistake**: Searching for `interface{}` in Go code without escaping braces. Correct: `interface\{\}`

## Search Planning Rule

Before your second Grep/Glob call on the same topic, STOP and diagnose:

1. **Wrong pattern?** → Check escaping rules above, verify regex syntax
2. **Wrong scope?** → Add `path:` to narrow, or `type:` to filter by language
3. **Wrong tool?** → Maybe Glob for filenames, Explore for broad understanding
4. **Doesn't exist?** → Accept that the thing may not exist; tell the user

Do NOT: run 3+ similar searches changing one letter at a time. That's thrashing.

## Useful Flag Combinations

- `type: "ts"` — filter to TypeScript files only (also: `py`, `js`, `rust`, `go`, `java`)
- `-i: true` — case-insensitive (use when unsure of casing conventions)
- `output_mode: "content"` with `context: 3` — show matching lines with 3 lines of surrounding context
- `output_mode: "count"` — check if pattern exists at all before reading matches
- `output_mode: "files_with_matches"` — just get file paths (default, good for scoping)
- `head_limit: 10` — stop after 10 results to avoid overwhelming output

## Common Mistakes

1. **Forgetting file type filter**: Searching entire repo when you know the language
2. **Too-broad patterns**: `"error"` matches thousands of lines. Be specific: `"error TS\\d+"`
3. **No context lines**: Finding a match but not understanding it. Use `-C 3` to see surrounding code
4. **Searching in node_modules/build artifacts**: Use `type:` filter or narrow `path:`
5. **Using Grep to find files by name**: That's what Glob is for

## Reference

See `references/ripgrep-patterns.md` for a cheatsheet of common code patterns and their correct ripgrep syntax.
