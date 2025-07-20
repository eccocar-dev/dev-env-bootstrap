#!/usr/bin/env zsh

# ===============================================================
# Uninstall asdf setup: Removes plugins, asdf via Homebrew,
# and cleans environment variables from ~/.zshrc
# ===============================================================

set -e  # Exit immediately if any command fails

PLUGINS=("erlang" "elixir" "nodejs" "postgres")
ZSHRC="$HOME/.zshrc"

# Load asdf into current shell session if available
asdf::load() {
  local asdf_path
  asdf_path="$(brew --prefix asdf)/libexec/asdf.sh"

  if [[ -f "$asdf_path" ]]; then
    . "$asdf_path"
  else
    echo "⚠️ asdf not found. Skipping plugin removal."
    return 1
  fi
}

# Remove asdf plugins
asdf::remove_plugins() {
  echo "🧹 Removing asdf plugins..."
  for plugin in "${PLUGINS[@]}"; do
    if asdf plugin list | grep -q "^$plugin$"; then
      echo "❌ Removing $plugin..."
      asdf plugin remove "$plugin"
    else
      echo "⚠️ $plugin not installed, skipping."
    fi
  done
}

# Uninstall asdf via Homebrew
brew::uninstall_asdf() {
  if brew list asdf >/dev/null 2>&1; then
    echo "🧼 Uninstalling asdf via Homebrew..."
    brew uninstall asdf
  else
    echo "⚠️ asdf not installed via Homebrew, skipping."
  fi
}

# Clean environment variables from .zshrc
zshrc::cleanup_env_vars() {
  echo "🧽 Cleaning up environment variables from $ZSHRC..."

  # Erlang config
  sed -i '' '/# ASDF \/ Erlang settings/d' "$ZSHRC"
  sed -i '' '/export KERL_CONFIGURE_OPTIONS=/d' "$ZSHRC"
  sed -i '' '/export KERL_BUILD_DOCS=/d' "$ZSHRC"
  sed -i '' '/export KERL_INSTALL_HTMLDOCS=/d' "$ZSHRC"
  sed -i '' '/export KERL_INSTALL_MANPAGES=/d' "$ZSHRC"

  # Postgres build config
  sed -i '' '/# Postgres plugin build config/d' "$ZSHRC"
  sed -i '' '/export PKG_CONFIG_PATH=/d' "$ZSHRC"

  # asdf environment and completions
  sed -i '' '/# asdf completions/d' "$ZSHRC"
  sed -i '' '/fpath=.*asdf.*\/completions/d' "$ZSHRC"
  sed -i '' '/autoload -Uz compinit && compinit/d' "$ZSHRC"
  sed -i '' '/# asdf: Custom data directory (default)/d' "$ZSHRC"
  sed -i '' '/export ASDF_DATA_DIR=/d' "$ZSHRC"
}

zshrc::remove_asdf_shims_literal_from_path() {
  local zshrc="$HOME/.zshrc"
  local literal='\${ASDF_DATA_DIR:-\$HOME/.asdf}/shims'
  echo "🧹 Removing $literal from PATH in $zshrc..."

  # Reescribe las líneas export PATH=... donde esté presente el literal
  sed -i '' -E "s|$literal:?||g" "$zshrc"

  echo "✅ Removed $literal from PATH"
}

# Execute steps
if asdf::load; then
  asdf::remove_plugins
fi

brew::uninstall_asdf
zshrc::cleanup_env_vars
zshrc::remove_asdf_shims_literal_from_path

echo "✅ Uninstallation complete."
echo "👉 You may want to run 'source ~/.zshrc' or restart your terminal session."
