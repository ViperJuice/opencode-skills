#!/bin/sh
# env-probe.sh — One-pass environment detection for development tools.
# Output: JSON object with tool paths, versions, and project config detection.
# Always exits 0. Missing tools are reported as null.

get_version() {
    # Usage: get_version "command" "args"
    # Returns version string or empty
    if command -v "$1" >/dev/null 2>&1; then
        "$@" 2>/dev/null | head -1 | sed 's/[^0-9.]*//' | sed 's/[^0-9.].*//'
    fi
}

json_tool() {
    # Usage: json_tool "name" "cmd_path" "version" ["extra_key" "extra_val"]
    if [ -n "$2" ]; then
        printf '"%s":{"cmd":"%s","version":"%s"' "$1" "$2" "$3"
        if [ -n "$4" ]; then
            printf ',"%s":%s' "$4" "$5"
        fi
        printf '}'
    else
        printf '"%s":null' "$1"
    fi
}

# --- Python detection ---
PYTHON_CMD=""
PYTHON_VER=""

if [ -f ".venv/bin/python" ]; then
    PYTHON_CMD=".venv/bin/python"
    PYTHON_VER=$(.venv/bin/python --version 2>&1 | sed 's/Python //')
elif command -v poetry >/dev/null 2>&1 && poetry env info -e >/dev/null 2>&1; then
    PYTHON_CMD=$(poetry env info -e 2>/dev/null)
    if [ -n "$PYTHON_CMD" ]; then
        PYTHON_VER=$("$PYTHON_CMD" --version 2>&1 | sed 's/Python //')
    fi
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD=$(command -v python3)
    PYTHON_VER=$(python3 --version 2>&1 | sed 's/Python //')
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD=$(command -v python)
    PYTHON_VER=$(python --version 2>&1 | sed 's/Python //')
fi

# Pip detection
PIP_CMD=""
PIP_VER=""
if [ -f ".venv/bin/pip" ]; then
    PIP_CMD=".venv/bin/pip"
    PIP_VER=$(.venv/bin/pip --version 2>&1 | awk '{print $2}')
elif command -v pip3 >/dev/null 2>&1; then
    PIP_CMD=$(command -v pip3)
    PIP_VER=$(pip3 --version 2>&1 | awk '{print $2}')
elif command -v pip >/dev/null 2>&1; then
    PIP_CMD=$(command -v pip)
    PIP_VER=$(pip --version 2>&1 | awk '{print $2}')
fi

# Python package manager
PKG_MGR="null"
if [ -f "uv.lock" ] && command -v uv >/dev/null 2>&1; then
    PKG_MGR='"uv"'
elif [ -f "poetry.lock" ] && command -v poetry >/dev/null 2>&1; then
    PKG_MGR='"poetry"'
elif [ -f "Pipfile.lock" ] && command -v pipenv >/dev/null 2>&1; then
    PKG_MGR='"pipenv"'
elif [ -f "requirements.txt" ]; then
    PKG_MGR='"pip"'
fi

# --- Node.js detection ---
NODE_CMD=""
NODE_VER=""
if command -v node >/dev/null 2>&1; then
    NODE_CMD=$(command -v node)
    NODE_VER=$(node --version 2>/dev/null | sed 's/v//')
fi

NPM_CMD=""
NPM_VER=""
if command -v npm >/dev/null 2>&1; then
    NPM_CMD=$(command -v npm)
    NPM_VER=$(npm --version 2>/dev/null)
fi

# --- TypeScript detection ---
TSC_CMD=""
TSC_VER=""
if command -v npx >/dev/null 2>&1 && [ -f "tsconfig.json" ]; then
    TSC_VER=$(npx tsc --version 2>/dev/null | sed 's/Version //')
    if [ -n "$TSC_VER" ]; then
        TSC_CMD="npx tsc"
    fi
fi

# --- Dart / Flutter detection ---
DART_CMD=""
DART_VER=""
if command -v dart >/dev/null 2>&1; then
    DART_CMD=$(command -v dart)
    DART_VER=$(dart --version 2>&1 | sed 's/Dart SDK version: //' | awk '{print $1}')
fi

FLUTTER_CMD=""
FLUTTER_VER=""
if command -v flutter >/dev/null 2>&1; then
    FLUTTER_CMD=$(command -v flutter)
    FLUTTER_VER=$(flutter --version 2>&1 | head -1 | awk '{print $2}')
fi

# --- Rust detection ---
CARGO_CMD=""
CARGO_VER=""
if command -v cargo >/dev/null 2>&1; then
    CARGO_CMD=$(command -v cargo)
    CARGO_VER=$(cargo --version 2>/dev/null | awk '{print $2}')
fi

# --- Git detection ---
GIT_CMD=""
GIT_VER=""
IN_REPO="false"
if command -v git >/dev/null 2>&1; then
    GIT_CMD=$(command -v git)
    GIT_VER=$(git --version 2>/dev/null | awk '{print $3}')
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        IN_REPO="true"
    fi
fi

# --- Docker detection ---
DOCKER_CMD=""
DOCKER_VER=""
if command -v docker >/dev/null 2>&1; then
    DOCKER_CMD=$(command -v docker)
    DOCKER_VER=$(docker --version 2>/dev/null | sed 's/Docker version //' | sed 's/,.*//')
fi

COMPOSE_VER=""
if command -v docker >/dev/null 2>&1; then
    COMPOSE_VER=$(docker compose version 2>/dev/null | sed 's/Docker Compose version //' | sed 's/v//')
fi

# --- Java detection ---
JAVA_CMD=""
JAVA_VER=""
if command -v java >/dev/null 2>&1; then
    JAVA_CMD=$(command -v java)
    JAVA_VER=$(java -version 2>&1 | head -1 | awk -F '"' '{print $2}')
fi

# --- Output JSON ---
printf '{\n'
printf '  '; json_tool "python" "$PYTHON_CMD" "$PYTHON_VER"; printf ',\n'
printf '  '; json_tool "pip" "$PIP_CMD" "$PIP_VER"; printf ',\n'
printf '  "package_manager":%s,\n' "$PKG_MGR"
printf '  '; json_tool "node" "$NODE_CMD" "$NODE_VER"; printf ',\n'
printf '  '; json_tool "npm" "$NPM_CMD" "$NPM_VER"; printf ',\n'
printf '  '; json_tool "tsc" "$TSC_CMD" "$TSC_VER"; printf ',\n'
printf '  '; json_tool "dart" "$DART_CMD" "$DART_VER"; printf ',\n'
printf '  '; json_tool "flutter" "$FLUTTER_CMD" "$FLUTTER_VER"; printf ',\n'
printf '  '; json_tool "cargo" "$CARGO_CMD" "$CARGO_VER"; printf ',\n'
printf '  '; json_tool "git" "$GIT_CMD" "$GIT_VER" "in_repo" "$IN_REPO"; printf ',\n'
printf '  '; json_tool "docker" "$DOCKER_CMD" "$DOCKER_VER"
if [ -n "$COMPOSE_VER" ]; then
    printf ',\n  "docker_compose":{"version":"%s"}' "$COMPOSE_VER"
else
    printf ',\n  "docker_compose":null'
fi
printf ',\n  '; json_tool "java" "$JAVA_CMD" "$JAVA_VER"; printf '\n'
printf '}\n'

exit 0
