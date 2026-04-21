---
name: file-read-cache
description: "Guidelines for avoiding redundant file reads during a session. Use throughout any coding session. Instructs Claude to track which files have been read and avoid re-reading unchanged files."
---

# File Read Cache

## The Rule

Before calling Read on any file, ask: "Have I already read this file in this conversation, and has anything modified it since?"

If you already have the contents and nothing modified the file → use your existing knowledge. Don't re-read.

## When to Re-Read (legitimate reasons)

- You used Edit or Write on the file since your last Read
- A Bash command may have modified it (sed, code generators, git checkout, npm install)
- You need a different line range than what you previously read
- The conversation has been running so long that context compression may have dropped the content

## When NOT to Re-Read

- You read it 2-5 turns ago and only did Grep/Glob/other searches since (file unchanged)
- You want to "double-check" something you already read (trust your earlier read)
- You're referencing a config file (package.json, tsconfig.json) you read at session start

## Subagent Exception

This rule applies within a SINGLE conversation. Subagents have separate context and MUST read files independently — they cannot access the parent's prior reads. Similarly, if you ARE a subagent, you must read everything you need regardless of what the parent may have read.
