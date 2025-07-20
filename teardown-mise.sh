#!/usr/bin/env zsh

# ==============================================================================
# mise teardown script for macOS
# ------------------------------------------------------------------------------
# Description : Uninstalls all mise-managed tools, removes mise and its config.
# ⚠️ WARNING   : This operation is destructive and irreversible.
# ==============================================================================

set -euo pipefail

echo "🚧 Starting mise teardown..."

# ------------------------------------------------------------------------------
# 1. Uninstall all tools managed by mise (if available)
# ------------------------------------------------------------------------------

if command -v mise >/dev/null 2>&1; then
  echo "🧹 Uninstalling all tools installed via mise..."

  tools=$(mise ls | tail -n +2 | awk '{print $1}' | sort -u)

  for tool in ${(f)tools}; do
    versions=$(mise ls "$tool" 2>/dev/null | tail -n +2 | awk '{print $2}' | sed 's/ (missing)//')
    for version in ${(f)versions}; do
      if [[ -n "$version" ]]; then
        echo "🗑️  Uninstalling $tool@$version..."
        mise uninstall "$tool@$version" || echo "⚠️ Failed to uninstall $tool@$version"
      fi
    done
  done

  # ----------------------------------------------------------------------------
  # 2. Uninstall mise itself via Homebrew (if applicable)
  # ----------------------------------------------------------------------------
  if brew list mise >/dev/null 2>&1; then
    echo "🧨 Uninstalling mise via Homebrew..."
    brew uninstall mise || echo "⚠️ Failed to uninstall mise via Homebrew"
  else
    echo "ℹ️ mise was not installed via Homebrew or already removed"
  fi
else
  echo "ℹ️ mise not found in PATH. Skipping tool uninstallation."
fi

# ------------------------------------------------------------------------------
# 3. Clean up remaining mise directories
# ------------------------------------------------------------------------------

echo "🧽 Cleaning up leftover mise data..."
rm -rf ~/.local/share/mise ~/.config/mise ~/.mise
echo "✅ Removed mise data from ~/.local/share, ~/.config, and ~/.mise"

# ------------------------------------------------------------------------------
# 4. Remove mise-related lines from ~/.zshrc
# ------------------------------------------------------------------------------

ZSHRC="${HOME}/.zshrc"

echo "🧼 Cleaning up mise configuration in $ZSHRC..."

cp "$ZSHRC" "$ZSHRC.bak"
echo "📦 Backup saved as ~/.zshrc.bak"

# Remove mise activation block
sed -i '' '/^# mise activation$/d' "$ZSHRC"
sed -i '' '/^eval "\$(mise activate zsh)"/d' "$ZSHRC"

# Remove Postgres build config
sed -i '' '/^# Postgres plugin build config$/d' "$ZSHRC"
sed -i '' '/^export PKG_CONFIG_PATH=/d' "$ZSHRC"

# Remove Erlang (KERL) config
sed -i '' '/^# ASDF \/ Erlang settings$/d' "$ZSHRC"
sed -i '' '/^export KERL_CONFIGURE_OPTIONS=/d' "$ZSHRC"
sed -i '' '/^export KERL_BUILD_DOCS=/d' "$ZSHRC"
sed -i '' '/^export KERL_INSTALL_HTMLDOCS=/d' "$ZSHRC"
sed -i '' '/^export KERL_INSTALL_MANPAGES=/d' "$ZSHRC"

# ------------------------------------------------------------------------------
# 5. Final cleanup of shell functions
# ------------------------------------------------------------------------------

echo "🚫 Removing leftover shell functions..."

unset -f _mise_hook 2>/dev/null || true
unset -f mise       2>/dev/null || true

# ------------------------------------------------------------------------------
# 6. Done
# ------------------------------------------------------------------------------

echo ""
echo "🎉 Teardown complete! mise and all its tools have been removed."
echo "📂 A backup of your previous ~/.zshrc was saved as ~/.zshrc.bak"
echo "💡 You may want to restart your terminal or run:"
echo "     source ~/.zshrc"
