---
name: diagnose-bash-error
description: "Diagnostic guide for Bash command failures. Use when a Bash command returns a non-zero exit code. Provides error categorization by exit code, root cause analysis procedures, and specific fix suggestions. Helps avoid blind retry loops by diagnosing the error before attempting another command. Trigger on any Bash failure, especially exit codes 1, 2, 127, and 255."
---

# Diagnose Bash Error

## The Rule

When a Bash command fails, read the full stderr and categorize the error against the patterns below before retrying.

## Decision Tree

When a command fails, match stderr against these patterns:

### Exit Code 1 (General Error)
- stderr matches `TS\d+:` or `error TS` → TypeScript type error → Read the file at the reported line, fix the type issue
- stderr matches `Cannot find module` or `ModuleNotFoundError` → Missing dependency → Run `npm install` or `pip install`, or check the import path
- stderr matches `No such file or directory` or `ENOENT` → Wrong path → Verify the file exists with Glob before re-running
- stderr matches `Permission denied` → Insufficient permissions → Check file ownership with `ls -la`, fix permissions
- stderr matches `EADDRINUSE` → Port conflict → Find what's using the port: `lsof -i :<port>`

### Exit Code 2 (Shell Misuse)
- stderr contains a line number → Syntax error → Read the file at that line and fix the syntax
- stderr matches `unexpected token` → Shell syntax error → Check for unclosed quotes, missing semicolons

### Exit Code 126 (Not Executable)
- `Permission denied` on a script → Run `chmod +x <script>` or invoke with interpreter: `bash <script>`

### Exit Code 127 (Command Not Found)
- Run `which <command>` exactly once
- Check if you're in a virtual env that has the tool: `ls .venv/bin/<command>`
- If truly not installed, tell the user — don't try to install it yourself without asking

### Exit Code 128+N (Killed by Signal)
- 137 (SIGKILL) → Out of memory → Reduce scope of operation, tell user about memory limits
- 139 (SIGSEGV) → Segfault → This is a bug in the program, not fixable by retrying
- 130 (SIGINT) → User interrupted → Don't retry; the user wanted it stopped

### Exit Code 255 (SSH/Network)
- `Connection refused` → Service not running → Check if the target service is up
- `Host not found` or `Could not resolve hostname` → DNS issue → Verify the hostname/URL

## Anti-Patterns to Avoid

1. **Same command, different flag**: Trying `command --flag1`, then `command --flag2`, then `command --flag3` without understanding why the first one failed. Diagnose first.
2. **Tool-location chain**: Running `which tool`, `whereis tool`, `find / -name tool`, `type tool` in sequence. Run `which tool` once. If not found, it's not installed.
3. **Tool-switching instead of diagnosing**: Switching from `grep` to `rg` to `ag` because the first one "didn't work." The tool isn't the problem — your pattern or path is.
4. **Retry with wait**: Adding `sleep 5 && command` doesn't fix deterministic errors. Only use waits for genuinely transient issues (network timeouts, server startup).

## When to Ask the User

Stop trying to fix it yourself when:
- A required tool isn't installed (don't install system packages without asking)
- The error is environment-specific (wrong Python version, missing system library)
- You've diagnosed the issue but the fix requires elevated permissions
- The error suggests corrupted state (broken lockfile, corrupted node_modules) — suggest the fix, let the user approve

## Reference

See `references/exit-codes.md` for a quick-lookup table of exit codes, common causes, stderr patterns, and recommended actions.
