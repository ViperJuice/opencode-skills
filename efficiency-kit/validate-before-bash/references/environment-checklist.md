# Environment Checklist by Language

## TypeScript / Node.js

- [ ] `node --version` — v18+ recommended
- [ ] `npx tsc --version` — matches project's typescript dependency
- [ ] `tsconfig.json` exists with correct `compilerOptions`
- [ ] `node_modules/` present and matches `package-lock.json` timestamp
- [ ] If monorepo: check workspace root AND package-level `tsconfig.json`
- [ ] Build command: `npx tsc --noEmit` (type-check only), `npx tsc` (compile)

## Python

- [ ] Python interpreter: `.venv/bin/python` preferred over system python
- [ ] Package manager: `uv` > `poetry` > `pip` (check which lockfile exists)
- [ ] `pyproject.toml` or `setup.py` present
- [ ] Virtual env active: `echo $VIRTUAL_ENV` or check `.venv/`
- [ ] Dependencies installed: `pip list` or `uv pip list`
- [ ] Type checker: `mypy` or `pyright` if type checking needed

## Dart / Flutter

- [ ] `dart --version` or `flutter --version`
- [ ] `pubspec.yaml` present with correct SDK constraint
- [ ] `.dart_tool/` exists (run `dart pub get` if missing)
- [ ] For Flutter: `flutter doctor` for full environment check
- [ ] Analyze command: `dart analyze` or `flutter analyze`

## Rust

- [ ] `cargo --version` and `rustc --version`
- [ ] `Cargo.toml` present
- [ ] `Cargo.lock` present (run `cargo fetch` if missing)
- [ ] `target/` may be absent (first build creates it)
- [ ] Check command: `cargo check` (type-check without building)
- [ ] Toolchain: `rustup show` for active toolchain
