---
name: safe-edit
description: "Checklist for safe file editing operations. Use before any Edit or Write tool call. Enforces read-before-edit pattern, detects potential conflicts from external modifications, and prevents common edit failures."
---

# Safe Edit

## Pre-Edit Checklist

Before every Edit or Write call:
1. Have I Read this file in THIS conversation? → If no, Read it first
2. Since my last Read, did I or a Bash command modify this file? → If yes, Re-read it
3. Is my old_string unique in the file? → If unsure, include 3+ surrounding lines for context
4. Am I preserving exact indentation? → Match the whitespace from Read output exactly (spaces vs tabs matter)

## Common Error Messages and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| "File has not been read yet" | Edit called without prior Read | Read the file first, always |
| "old_string not found" | Content changed or indentation mismatch | Re-read the file, copy exact whitespace |
| "old_string not unique" | Multiple matches in file | Include more surrounding context lines |

## Subagent Rule

**CRITICAL**: Subagents do NOT inherit the parent's file context. Even if the parent read a file 2 turns ago, the subagent has NEVER seen it. Always Read target files at the start of a subagent task.

## Edit Tool Indentation

When copying old_string from Read output, the format is: `[spaces][line_number][tab][actual content]`. Only copy the content AFTER the tab — never include line numbers in old_string.
