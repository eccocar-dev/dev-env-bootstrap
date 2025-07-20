#!/usr/bin/env zsh

# ===============================================================
# asdf environment bootstrap script for macOS
# Description: Installs Erlang, Elixir, Node.js, and Postgres via asdf
# Requires: Homebrew, macOS
# ===============================================================

set -e  # Exit immediately if any command fails

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This script is intended for macOS. Aborting."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew is not installed. Please install it first: https://brew.sh/"
  exit 1
fi

# ===============================================================
# Configuration
# ===============================================================

#Check compatibility between Erlang and Elixir versions: https://hexdocs.pm/elixir/compatibility-and-deprecations.html#between-elixir-and-erlang-otp
ERLANG_VERSION="28.0.2"
ELIXIR_VERSION="1.18.4-otp-27"
NODE_VERSION="22.17.1"
POSTGRES_VERSION="17.5"

# ===============================================================
# Helper functions
# ===============================================================
brew::install_if_missing() {
  for pkg in "$@"; do
    if brew list "$pkg" >/dev/null 2>&1; then
      echo "✅ $pkg already installed"
    else
      echo "📦 Installing $pkg..."
      brew install "$pkg"
    fi
  done
}

asdf::load() {
  local asdf_path
  asdf_path="$(brew --prefix asdf)/libexec/asdf.sh"

  if [[ -f "$asdf_path" ]]; then
    . "$asdf_path"
  else
    echo "❌ Failed to locate asdf. Aborting."
    exit 1
  fi
}

asdf::plugin_add_if_missing() {
  local plugin="$1"
  local repo_url="$2"

  if asdf plugin list | grep -q "^$plugin$"; then
    echo "✅ asdf plugin '$plugin' already added"
  else
    echo "➕ Adding asdf plugin '$plugin'..."
    asdf plugin add "$plugin" "$repo_url"
  fi
}

asdf::install_if_missing() {
  local plugin="$1"
  local version="$2"

  # Check if the version is already installed
  if asdf where "$plugin" "$version" &>/dev/null; then
    echo "✅ $plugin $version already installed"
  else
    echo "✅ Installing $plugin $version..."
    asdf install "$plugin" "$version"
  fi

  # Get the current global version (first one listed)
  local current_global
  current_global=$(asdf current "$plugin" 2>/dev/null | awk '{print $2}')

  if [[ "$current_global" != "$version" ]]; then
    echo "🔧 Setting $plugin $version as global..."
    asdf set -u "$plugin" "$version"
  else
    echo "✅ $plugin $version already set as global"
  fi
}


asdf::set_local_if_missing() {
  local plugin="$1"
  local version="$2"

  # Check if version is already set locally
  local current_local
  current_local=$(asdf local "$plugin" 2>/dev/null | awk '{print $1}')

  if [[ "$current_local" == "$version" ]]; then
    echo "✅ $plugin $version already set locally"
  else
    echo "📍 Setting $plugin $version locally..."
    asdf set "$plugin" "$version"
  fi
}

env::export_if_missing() {
  local var_name="$1"
  local var_value="$2"
  local label="${3:-}"

  if ! grep -q "^export $var_name=" ~/.zshrc; then
    echo "" >> ~/.zshrc
    [ -n "$label" ] && echo "# $label" >> ~/.zshrc
    echo "export $var_name=\"$var_value\"" >> ~/.zshrc
    echo "✅ Persisted $var_name to ~/.zshrc"
  else
    echo "✅ $var_name already exists in ~/.zshrc, skipping."
  fi
}

env::prepend_to_path_if_missing() {
  local dir="$1"
  local comment="${2:-}"
  local zshrc="${ZSHRC:-$HOME/.zshrc}"

  if [[ -z "$dir" ]]; then
    echo "❌ No directory passed to env::prepend_to_path_if_missing"
    return 1
  fi

  # Comprobamos si la ruta ya está presente en alguna línea activa de export PATH
  if grep -E '^\s*export PATH=.*'"$(printf '%s' "$dir" | sed 's/[]\/$*.^[]/\\&/g')" "$zshrc" > /dev/null; then
    echo "✅ $dir already present in PATH in $zshrc"
    return 0
  fi

  if grep -q '^\s*export PATH=' "$zshrc"; then
    echo "🔧 Prepending $dir to existing PATH in $zshrc..."
    # Añadir delante del PATH ya existente, sin romper variables
    sed -i '' -e "/^export PATH=/ s|PATH=\"*|PATH=\"$dir:|g" "$zshrc"
  else
    # Añadir nueva línea de export
    echo "" >> "$zshrc"
    [[ -n "$comment" ]] && echo "# $comment" >> "$zshrc"
    echo "export PATH=\"$dir:\$PATH\"" >> "$zshrc"
  fi

  echo "✅ Updated PATH with $dir in $zshrc"
}

# ===============================================================
# Install asdf (only if not already installed)
# ===============================================================
brew::install_if_missing asdf

# ===============================================================
# Persist asdf configuration in ~/.zshrc
# ===============================================================

# asdf environment variables
env::export_if_missing "ASDF_DATA_DIR" "\$HOME/.asdf" "asdf: Custom data directory (default)"
env::prepend_to_path_if_missing '${ASDF_DATA_DIR:-$HOME/.asdf}/shims' "asdf: Add shims to PATH"

# completions path for Zim (no need to run compinit manually)
COMPLETIONS_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
mkdir -p "$COMPLETIONS_DIR"
asdf completion zsh > "$COMPLETIONS_DIR/_asdf"

# ensure fpath is updated in .zshrc, before compinit runs (Zim already runs compinit)
if ! grep -q "${COMPLETIONS_DIR}" ~/.zshrc; then
  echo "" >> ~/.zshrc
  echo "# asdf completions" >> ~/.zshrc
  echo "fpath=(${COMPLETIONS_DIR} \$fpath)" >> ~/.zshrc
  echo "✅ Added asdf completions path to fpath"
else
  echo "✅ asdf completions path already configured in ~/.zshrc"
fi

# Ensure asdf is available in this script session
asdf::load

# ===============================================================
# Erlang dependencies. See: https://github.com/asdf-vm/asdf-erlang
# ===============================================================
echo "🔧 Installing Erlang dependencies..."

# autoconf is required to run ./configure when building Erlang from source
# openssl (v3) is required for Erlang >= 25.1 to enable SSL features
# wxwidgets is required to use :observer and GUI tools in Erlang
# libxslt and fop are used to generate Erlang documentation
brew::install_if_missing autoconf openssl wxwidgets libxslt fop

# Export KERL options for this session
OPENSSL_PREFIX=$(brew --prefix openssl)
export KERL_CONFIGURE_OPTIONS="--disable-debug --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-threads --enable-kernel-poll --enable-wx --enable-webview --enable-darwin-64bit --enable-gettimeofday-as-os-system-time --with-ssl=$OPENSSL_PREFIX"
export KERL_BUILD_DOCS="yes"
export KERL_INSTALL_HTMLDOCS="no"
export KERL_INSTALL_MANPAGES="no"

env::export_if_missing "KERL_CONFIGURE_OPTIONS" "$KERL_CONFIGURE_OPTIONS" "ASDF / Erlang settings"
env::export_if_missing "KERL_BUILD_DOCS" "$KERL_BUILD_DOCS"
env::export_if_missing "KERL_INSTALL_HTMLDOCS" "$KERL_INSTALL_HTMLDOCS"
env::export_if_missing "KERL_INSTALL_MANPAGES" "$KERL_INSTALL_MANPAGES"

# ===============================================================
# Add Erlang plugin
# ===============================================================
asdf::plugin_add_if_missing erlang https://github.com/asdf-vm/asdf-erlang.git

# ===============================================================
# Elixir dependencies. See: https://github.com/asdf-vm/asdf-elixir
# ===============================================================
echo "🔧 Installing Elixir dependencies..."
brew::install_if_missing unzip

# Add Elixir plugin
asdf::plugin_add_if_missing elixir https://github.com/asdf-vm/asdf-elixir.git

# ===============================================================
# Node.js dependencies. See: https://github.com/asdf-vm/asdf-nodejs.git
# ===============================================================
echo "🔧 Installing Node.js dependencies..."
brew::install_if_missing gpg gawk

# Add Node.js plugin
asdf::plugin_add_if_missing nodejs https://github.com/asdf-vm/asdf-nodejs.git

# Optional: support .nvmrc and .node-version
if ! grep -q "legacy_version_file" ~/.asdfrc 2>/dev/null; then
  echo "🔧 Enabling legacy version file support for Node.js..."
  echo "legacy_version_file = yes" >> ~/.asdfrc
fi

# ===============================================================
# Postgres dependencies
# ===============================================================
echo "🔧 Installing Postgres dependencies..."
brew::install_if_missing gcc readline zlib curl ossp-uuid icu4c pkg-config

# Export Postgres pkg-config path for this session
HOMEBREW_PREFIX=$(brew --prefix)
export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/bin/pkg-config:$(brew --prefix icu4c)/lib/pkgconfig:$(brew --prefix curl)/lib/pkgconfig:$(brew --prefix zlib)/lib/pkgconfig"

env::export_if_missing "PKG_CONFIG_PATH" "$PKG_CONFIG_PATH" "Postgres plugin build config"

# Add Postgres plugin
asdf::plugin_add_if_missing postgres https://github.com/smashedtoatoms/asdf-postgres

# ===============================================================
# Install Erlang & Elixir versions. 
# ===============================================================
asdf::install_if_missing erlang "$ERLANG_VERSION"
asdf::install_if_missing elixir "$ELIXIR_VERSION"
asdf::install_if_missing nodejs "$NODE_VERSION"
asdf::install_if_missing postgres "$POSTGRES_VERSION"

# ===============================================================
# Final steps: persist versions in .tool-versions (only if in a project)
# ===============================================================
echo "📝 Checking for project files to update .tool-versions..."

if [ -f mix.exs ] || [ -f package.json ] || [ -d .git ]; then
  echo "📦 Detected project files. Setting local versions with asdf..."

  asdf::set_local_if_missing erlang "$ERLANG_VERSION"
  asdf::set_local_if_missing elixir "$ELIXIR_VERSION"
  asdf::set_local_if_missing nodejs "$NODE_VERSION"
  asdf::set_local_if_missing postgres "$POSTGRES_VERSION"
else
  echo "⚠️ No mix.exs, package.json or .git directory found."
  echo "⏭️ Skipping .tool-versions creation."
fi

echo "📦 If a project was detected, .tool-versions now pins the tool versions used."

# ===============================================================
# Done
# ===============================================================
echo ""

if [[ $- == *i* ]]; then
  echo "🔄 Reloading ~/.zshrc in interactive shell..."
  source ~/.zshrc
else
  echo "ℹ️ Non-interactive shell detected. Please run 'source ~/.zshrc' manually."
fi

echo "🎉 Setup complete!"
