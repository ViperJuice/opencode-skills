#!/bin/sh
# preflight.sh — Pre-validate build environment before running build tools.
# Usage: preflight.sh [auto|typescript|python|dart|rust]
# Output: JSON with {"ready": bool, "language": str, "issues": [...]}

set -e

LANG_ARG="${1:-auto}"
ISSUES=""
ISSUE_COUNT=0
DETECTED_LANG=""
READY="true"

add_issue() {
    if [ "$ISSUE_COUNT" -gt 0 ]; then
        ISSUES="${ISSUES},"
    fi
    ISSUES="${ISSUES}\"$1\""
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
    READY="false"
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        add_issue "$1 not found on PATH"
        return 1
    fi
    return 0
}

detect_language() {
    if [ -f "tsconfig.json" ] || [ -f "package.json" ]; then
        DETECTED_LANG="typescript"
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "setup.cfg" ] || [ -f "requirements.txt" ]; then
        DETECTED_LANG="python"
    elif [ -f "pubspec.yaml" ]; then
        DETECTED_LANG="dart"
    elif [ -f "Cargo.toml" ]; then
        DETECTED_LANG="rust"
    else
        DETECTED_LANG="unknown"
    fi
}

check_typescript() {
    DETECTED_LANG="typescript"

    # Check for npx (to run tsc)
    check_command "npx" || true

    # Check tsconfig.json
    if [ ! -f "tsconfig.json" ]; then
        add_issue "tsconfig.json not found in current directory"
    fi

    # Check package.json
    if [ ! -f "package.json" ]; then
        add_issue "package.json not found"
    fi

    # Check node_modules
    if [ ! -d "node_modules" ]; then
        add_issue "node_modules/ not found — run npm install or yarn install"
    elif [ ! -f "node_modules/.package-lock.json" ] && [ ! -f "node_modules/.yarn-integrity" ]; then
        add_issue "node_modules/ may be incomplete — consider running npm install"
    fi

    # Check tsc is accessible
    if command -v npx >/dev/null 2>&1; then
        if ! npx tsc --version >/dev/null 2>&1; then
            add_issue "tsc not accessible via npx — typescript may not be installed"
        fi
    fi
}

check_python() {
    DETECTED_LANG="python"

    # Find python command
    PYTHON_CMD=""
    if [ -f ".venv/bin/python" ]; then
        PYTHON_CMD=".venv/bin/python"
    elif command -v python3 >/dev/null 2>&1; then
        PYTHON_CMD="python3"
    elif command -v python >/dev/null 2>&1; then
        PYTHON_CMD="python"
    else
        add_issue "No python interpreter found (checked .venv/bin/python, python3, python)"
    fi

    # Check for config file
    if [ ! -f "pyproject.toml" ] && [ ! -f "setup.py" ] && [ ! -f "setup.cfg" ] && [ ! -f "requirements.txt" ]; then
        add_issue "No Python config found (pyproject.toml, setup.py, setup.cfg, requirements.txt)"
    fi

    # Check virtual env
    if [ ! -d ".venv" ] && [ -z "${VIRTUAL_ENV:-}" ]; then
        # Check for other venv indicators
        if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
            add_issue "No virtual environment found (.venv/ or VIRTUAL_ENV) — consider creating one"
        fi
    fi

    # Detect package manager
    if [ -f "uv.lock" ]; then
        check_command "uv" || true
    elif [ -f "poetry.lock" ]; then
        check_command "poetry" || true
    elif [ -f "Pipfile.lock" ]; then
        check_command "pipenv" || true
    fi
}

check_dart() {
    DETECTED_LANG="dart"

    # Check for dart or flutter
    HAS_DART=false
    HAS_FLUTTER=false
    if check_command "dart"; then HAS_DART=true; fi
    if check_command "flutter"; then HAS_FLUTTER=true; fi

    if [ "$HAS_DART" = false ] && [ "$HAS_FLUTTER" = false ]; then
        add_issue "Neither dart nor flutter found on PATH"
    fi

    # Check pubspec.yaml
    if [ ! -f "pubspec.yaml" ]; then
        add_issue "pubspec.yaml not found in current directory"
    fi

    # Check .dart_tool
    if [ ! -d ".dart_tool" ]; then
        add_issue ".dart_tool/ not found — run dart pub get or flutter pub get"
    fi
}

check_rust() {
    DETECTED_LANG="rust"

    check_command "cargo" || true

    if [ ! -f "Cargo.toml" ]; then
        add_issue "Cargo.toml not found in current directory"
    fi

    if [ ! -f "Cargo.lock" ]; then
        add_issue "Cargo.lock not found — run cargo fetch or cargo build to generate it"
    fi
}

# Main logic
if [ "$LANG_ARG" = "auto" ]; then
    detect_language
    case "$DETECTED_LANG" in
        typescript) check_typescript ;;
        python)     check_python ;;
        dart)       check_dart ;;
        rust)       check_rust ;;
        unknown)    add_issue "Could not detect language — no recognized config files in current directory" ;;
    esac
else
    case "$LANG_ARG" in
        typescript) check_typescript ;;
        python)     check_python ;;
        dart)       check_dart ;;
        rust)       check_rust ;;
        *)          add_issue "Unknown language: $LANG_ARG (supported: typescript, python, dart, rust)" ;;
    esac
fi

# Output JSON
printf '{"ready":%s,"language":"%s","issues":[%s]}\n' "$READY" "$DETECTED_LANG" "$ISSUES"

# Exit code
if [ "$READY" = "true" ]; then
    exit 0
else
    exit 1
fi
