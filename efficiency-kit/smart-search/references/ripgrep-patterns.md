# Ripgrep Pattern Cheatsheet

Common code patterns and their correct ripgrep syntax. Use these as starting points.

## Function/Method Definitions

| Language | Pattern | Example Match |
|----------|---------|---------------|
| JavaScript/TS | `"(function\|const\|let\|var)\\s+NAME"` | `function doThing()`, `const doThing =` |
| Python | `"def NAME"` | `def do_thing():` |
| Rust | `"fn NAME"` | `fn do_thing()` |
| Go | `"func NAME"` or `"func \\(.*\\) NAME"` | `func DoThing()`, `func (s *Server) DoThing()` |
| Java | `"(public\|private\|protected).*NAME\\s*\\("` | `public void doThing(` |

## Class/Type Definitions

| Language | Pattern | Example Match |
|----------|---------|---------------|
| TypeScript | `"(interface\|type\|class)\\s+NAME"` | `interface User`, `type User =` |
| Python | `"class NAME"` | `class User:` |
| Rust | `"(struct\|enum\|trait)\\s+NAME"` | `struct User` |
| Go | `"type NAME (struct\|interface)"` | `type User struct` |

## Import Statements

| Language | Pattern | Example Match |
|----------|---------|---------------|
| TypeScript/JS | `"(import\|require).*NAME"` | `import { User } from`, `require('user')` |
| Python | `"(from\|import).*NAME"` | `from models import User` |
| Rust | `"use.*NAME"` | `use crate::models::User` |
| Go | `"\".*NAME.*\""` with type go | `"myproject/models"` |

## Common Literal Patterns (Must Escape)

| Looking For | Wrong | Correct |
|------------|-------|---------|
| `interface{}` (Go) | `interface{}` | `interface\{\}` |
| `Array<string>` | `Array<string>` | `Array<string>` (angle brackets are literal in ripgrep) |
| `foo.bar()` | `foo.bar()` | `foo\.bar\(\)` |
| `[key: string]` | `[key: string]` | `\[key: string\]` |
| `file.ts` | `file.ts` | `file\.ts` |
| `a | b` (literal pipe) | `a | b` | `a \| b` |
| `{id}` in URLs | `{id}` | `\{id\}` |
| `$variable` | `$variable` | `\$variable` |

## Multiline Patterns

For patterns spanning multiple lines, use `multiline: true`:
- `"struct \\{[\\s\\S]*?field"` — find struct containing a field
- `"function NAME[\\s\\S]*?return"` — find function body through to return

Note: multiline searches are slower. Only use when single-line patterns can't work.

## Combining Filters

Effective search combos:
- `pattern: "TODO\|FIXME\|HACK"` + `type: "ts"` — find all TODOs in TypeScript
- `pattern: "console\\.log"` + `type: "ts"` — find debug logging
- `pattern: "error"` + `output_mode: "count"` — check error frequency before diving in
- `pattern: "import.*from"` + `path: "src/"` — imports only in source directory
