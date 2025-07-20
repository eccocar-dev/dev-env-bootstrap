#!/usr/bin/env zsh

# ===============================================================
# pkgx teardown script for macOS
# Description: Prunes pkgx packages, removes .pkgx.toml if needed,
# and completely uninstalls pkgx and its related data.
# ⚠️ Does NOT modify .gitignore
# ===============================================================

set -euo pipefail

PKGX_FILE=".pkgx.toml"

# ===============================================================
# Helper Functions
# ===============================================================

project::is_in_project_root() {
  [[ -f mix.exs || -f package.json || -d .git ]]
}

pkgx::remove_pkgx_file_if_generated() {
  if [[ -f "$PKGX_FILE" ]]; then
    if grep -q '^\[tools\]' "$PKGX_FILE"; then
      echo "🗑️ Removing $PKGX_FILE..."
      rm "$PKGX_FILE"
      echo "✅ Removed $PKGX_FILE"
    else
      echo "⚠️ $PKGX_FILE exists but doesn't match expected format. Skipping deletion."
    fi
  else
    echo "ℹ️ No $PKGX_FILE found. Nothing to remove."
  fi
}

pkgx::prune_installed_packages() {
  if ! command -v pkgx >/dev/null 2>&1; then
    echo "⚠️ pkgx is not installed. Skipping package pruning."
    return
  fi

  echo "🔍 Checking for installed pkgx packages..."

  local installed
  installed=$(pkgx mash ls | tail -n +2 | wc -l | tr -d ' ')

  if [[ "$installed" -gt 0 ]]; then
    echo "🧹 Pruning installed pkgx packages..."
    pkgx mash prune
    echo "✅ pkgx packages pruned"
  else
    echo "ℹ️ No pkgx packages currently installed. Skipping prune."
  fi
}

pkgx::full_uninstall() {
  echo "🧨 Fully uninstalling pkgx..."

  local BIN_PATHS=(
    /usr/local/bin/pkgx
    /usr/local/bin/pkgxm
  )
  local USER_PATHS=(
    "$HOME/.pkgx"
    "$HOME/Library/Caches/pkgx"
    "$HOME/Library/Application Support/pkgx"
  )

  for path in "${BIN_PATHS[@]}"; do
    if [[ -f "$path" ]]; then
      echo "🗑️ Removing $path (requires sudo)..."
      sudo rm -f "$path"
    fi
  done

  for path in "${USER_PATHS[@]}"; do
    if [[ -d "$path" ]]; then
      echo "🧽 Removing $path..."
      rm -rf "$path"
    fi
  done

  echo "✅ pkgx completely removed"
}

# ===============================================================
# Main Execution
# ===============================================================

echo "🚧 Starting teardown of pkgx environment..."

pkgx::prune_installed_packages
pkgx::full_uninstall

if project::is_in_project_root; then
  pkgx::remove_pkgx_file_if_generated
else
  echo "⚠️ Not in a project directory (no mix.exs, package.json, or .git found)."
  echo "⏭️ Skipping $PKGX_FILE removal."
fi

echo ""
echo "✅ Teardown complete. pkgx and all related files have been removed."
