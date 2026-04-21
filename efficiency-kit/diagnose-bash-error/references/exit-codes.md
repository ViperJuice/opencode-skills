# Bash Exit Codes Quick Reference

| Exit Code | Signal | Common Causes | Stderr Patterns | Action |
|-----------|--------|---------------|-----------------|--------|
| 0 | — | Success | — | No action needed |
| 1 | — | General error | `error TS`, `ModuleNotFoundError`, `ENOENT`, `Cannot find module` | Read error details, fix specific issue |
| 2 | — | Shell misuse | `syntax error`, `unexpected token`, `parse error` | Fix syntax at reported line |
| 126 | — | Not executable | `Permission denied` (on script) | `chmod +x` or use interpreter directly |
| 127 | — | Command not found | `command not found`, `not recognized` | `which <cmd>`, verify installation |
| 128 | — | Invalid exit argument | — | Check script's exit calls |
| 130 | SIGINT | Ctrl+C / interrupted | `^C`, `Interrupted` | User intended this — don't retry |
| 137 | SIGKILL | Out of memory / killed | `Killed`, `OOMKilled` | Reduce scope, check memory limits |
| 139 | SIGSEGV | Segfault | `Segmentation fault` | Bug in program, not a retry issue |
| 143 | SIGTERM | Graceful termination | `Terminated` | Process was asked to stop |
| 255 | — | SSH/network/misc | `Connection refused`, `Host not found`, `Connection timed out` | Check network, hostname, service status |

## TypeScript-Specific Errors (Exit 1)

| Stderr Pattern | Cause | Fix |
|---------------|-------|-----|
| `error TS2304` | Cannot find name | Import missing, check type definitions |
| `error TS2345` | Argument type mismatch | Fix type at reported location |
| `error TS2339` | Property does not exist | Check type definition, add property or fix access |
| `error TS6133` | Declared but never used | Remove unused variable or add `_` prefix |
| `error TS1005` | Expected token | Syntax error, check for missing brackets/semicolons |

## Python-Specific Errors (Exit 1)

| Stderr Pattern | Cause | Fix |
|---------------|-------|-----|
| `ModuleNotFoundError` | Missing package | `pip install <package>` in correct venv |
| `ImportError` | Bad import path | Check module structure, `__init__.py` |
| `SyntaxError` | Invalid syntax | Fix at reported line |
| `IndentationError` | Wrong indentation | Fix whitespace at reported line |
| `FileNotFoundError` | Missing file | Verify path with Glob |

## Node.js-Specific Errors (Exit 1)

| Stderr Pattern | Cause | Fix |
|---------------|-------|-----|
| `Cannot find module` | Missing dependency | `npm install` or fix import path |
| `ENOENT` | File not found | Check path |
| `EADDRINUSE` | Port in use | `lsof -i :<port>`, kill or use different port |
| `EACCES` | Permission denied | Check file permissions |
| `ERR_MODULE_NOT_FOUND` | ESM import failed | Check file extension, exports field |
