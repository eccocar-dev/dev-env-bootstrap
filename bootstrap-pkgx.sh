#!/usr/bin/env zsh

# ===============================================================
# pkgx environment bootstrap script for macOS
# Description: Installs Erlang, Elixir, Node.js, and PostgreSQL
# via pkgx with pinned versions, only if not already present.
# ===============================================================

set -e 

# ===============================================================
# Metadata / Compatibility
# ===============================================================

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This script is intended for macOS. Aborting."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew is not installed. Please install it first: https://brew.sh"
  exit 1
fi

# ===============================================================
# Configuration
# ===============================================================

ERLANG_VERSION="28.0.2"
ELIXIR_VERSION="1.18.4"
NODE_VERSION="22.17.1"
POSTGRES_VERSION="17.2.0"

PKGX_FILE=".pkgx.toml"

# ===============================================================
# Helper Functions
# ===============================================================

brew::install_if_missing() {
  for pkg in "$@"; do
    if brew list "$pkg" >/dev/null 2>&1; then
      echo "✅ $pkg is already installed via Homebrew"
    else
      echo "📦 Installing $pkg via Homebrew..."
      brew install "$pkg"
    fi
  done
}

pkgx::ensure_tool() {
  local tool="$1"
  local version="$2"
  echo "📦 Ensuring $tool@$version is available via pkgx..."
  if pkgx "+$tool@$version" --version >/dev/null 2>&1; then
    echo "✅ $tool@$version is ready"
  else
    echo "❌ Failed to ensure $tool@$version"
    exit 1
  fi
}

pkgx::generate_pkgx_file_if_in_project() {
  if [ -f mix.exs ] || [ -f package.json ] || [ -d .git ]; then
    echo "🛠️  Detected project context. Managing $PKGX_FILE..."

    local new_content
    new_content=$(cat <<EOF
[tools]
erlang = "$ERLANG_VERSION"
elixir = "$ELIXIR_VERSION"
nodejs = "$NODE_VERSION"
postgresql = "$POSTGRES_VERSION"
EOF
    )

    if [[ ! -f "$PKGX_FILE" ]] || [[ "$(cat "$PKGX_FILE")" != "$new_content" ]]; then
      echo "$new_content" > "$PKGX_FILE"
      echo "✅ $PKGX_FILE created/updated"
    else
      echo "🔁 $PKGX_FILE already up to date"
    fi

    if ! grep -qxF "$PKGX_FILE" .gitignore 2>/dev/null; then
      echo "$PKGX_FILE" >> .gitignore
      echo "📁 Added $PKGX_FILE to .gitignore"
    fi
  else
    echo "⚠️  Not in a recognized project directory. Skipping $PKGX_FILE generation."
  fi
}

shell::usage_info() {
  echo ""
  echo "ℹ️  To use these tools, prepend with 'pkgx run' or use '+pkg' syntax:"
  echo "   pkgx run elixir --version"
  echo "   pkgx +erlang@$ERLANG_VERSION +elixir@$ELIXIR_VERSION iex"
  echo ""
  echo "🔒 Versions pinned in $PKGX_FILE (if applicable)"
}

# ===============================================================
# Bootstrap Flow
# ===============================================================

echo "🚀 Starting pkgx bootstrap for macOS..."

brew::install_if_missing pkgx

pkgx::ensure_tool erlang.org "$ERLANG_VERSION"
pkgx::ensure_tool elixir-lang.org "$ELIXIR_VERSION"
pkgx::ensure_tool nodejs.org "$NODE_VERSION"
pkgx::ensure_tool postgresql.org "$POSTGRES_VERSION"

pkgx::generate_pkgx_file_if_in_project

shell::usage_info
echo "🎉 All tools installed and ready!"
