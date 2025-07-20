#!/usr/bin/env zsh

# ==============================================================================
# mise environment bootstrap script for macOS
# ------------------------------------------------------------------------------
# Description : Installs Erlang, Elixir, Node.js, and PostgreSQL using mise.
# Target OS   : macOS
# Dependencies: Homebrew
# ==============================================================================

set -e  # Abort on error

# ------------------------------------------------------------------------------
# 1. OS & dependency check
# ------------------------------------------------------------------------------

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This script is intended for macOS only."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew is not installed. Please install it first: https://brew.sh/"
  exit 1
fi

# ------------------------------------------------------------------------------
# 2. Versions
# ------------------------------------------------------------------------------

ERLANG_VERSION="28.0.2"
ELIXIR_VERSION="1.18.4-otp-27"
NODE_VERSION="22.17.1"
POSTGRES_VERSION="17.5"

# ------------------------------------------------------------------------------
# 3. Helper functions
# ------------------------------------------------------------------------------

# Install missing Homebrew packages
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

# Install a tool globally via mise
mise::install_tool_global() {
  local tool="$1"
  local version="$2"
  echo "📦 Installing $tool@$version globally via mise..."
  mise use --global "$tool@$version"
}

# Set a tool version locally in the project via mise
mise::install_tool_local() {
  local tool="$1"
  local version="$2"
  echo "📍 Setting $tool@$version locally in this project via mise..."
  mise use "$tool@$version"
}

# Ensure mise activation is present in ~/.zshrc
mise::ensure_activation_in_zshrc() {
  local line='eval "$(mise activate zsh)"'
  if ! grep -Fq "$line" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# mise activation" >> ~/.zshrc
    echo "$line" >> ~/.zshrc
    echo "✅ Added mise activation to ~/.zshrc"
  else
    echo "✅ mise activation already present in ~/.zshrc"
  fi
}

# Persist environment variable to ~/.zshrc if not present
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

# ------------------------------------------------------------------------------
# 4. Install mise and configure environment
# ------------------------------------------------------------------------------

brew::install_if_missing mise
mise::ensure_activation_in_zshrc
eval "$(mise activate zsh)"

# Enable idiomatic version file support (e.g. .python-version)
echo "🧠 Enabling idiomatic version file support for Python..."
mise settings add idiomatic_version_file_enable_tools python

# ------------------------------------------------------------------------------
# 5. Install development tools
# ------------------------------------------------------------------------------

echo "🔧 Installing Erlang dependencies..."

# autoconf is required to run ./configure when building Erlang from source
# openssl (v3) is required for Erlang >= 25.1 to enable SSL features
# wxwidgets is required to use :observer and GUI tools in Erlang
# libxslt and fop are used to generate Erlang documentation
brew::install_if_missing autoconf openssl wxwidgets libxslt fop

# Setup KERL options
OPENSSL_PREFIX=$(brew --prefix openssl)
export KERL_CONFIGURE_OPTIONS="--disable-debug --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-threads --enable-kernel-poll --enable-wx --enable-webview --enable-darwin-64bit --enable-gettimeofday-as-os-system-time --with-ssl=$OPENSSL_PREFIX"
export KERL_BUILD_DOCS="yes"
export KERL_INSTALL_HTMLDOCS="no"
export KERL_INSTALL_MANPAGES="no"

# Persist KERL options to ~/.zshrc
env::export_if_missing "KERL_CONFIGURE_OPTIONS" "$KERL_CONFIGURE_OPTIONS" "ASDF / Erlang settings"
env::export_if_missing "KERL_BUILD_DOCS" "$KERL_BUILD_DOCS"
env::export_if_missing "KERL_INSTALL_HTMLDOCS" "$KERL_INSTALL_HTMLDOCS"
env::export_if_missing "KERL_INSTALL_MANPAGES" "$KERL_INSTALL_MANPAGES"

mise::install_tool_global erlang "$ERLANG_VERSION"

echo "🔧 Installing Elixir dependencies..."
brew::install_if_missing unzip
mise::install_tool_global elixir "$ELIXIR_VERSION"

echo "🔧 Installing Node.js dependencies..."
brew::install_if_missing gpg gawk
mise::install_tool_global node "$NODE_VERSION"

echo "🔧 Installing PostgreSQL dependencies..."
brew::install_if_missing gcc readline zlib curl ossp-uuid icu4c pkg-config

# Setup and persist PKG_CONFIG_PATH for PostgreSQL
HOMEBREW_PREFIX=$(brew --prefix)
export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/bin/pkg-config:$(brew --prefix icu4c)/lib/pkgconfig:$(brew --prefix curl)/lib/pkgconfig:$(brew --prefix zlib)/lib/pkgconfig"
env::export_if_missing "PKG_CONFIG_PATH" "$PKG_CONFIG_PATH" "Postgres plugin build config"

mise::install_tool_global postgres "$POSTGRES_VERSION"

# ------------------------------------------------------------------------------
# 6. Set local versions if inside a project
# ------------------------------------------------------------------------------

echo "📝 Checking for project files to set local versions..."
if [ -f mix.exs ] || [ -f package.json ] || [ -d .git ]; then
  echo "📦 Project detected. Setting local tool versions via mise..."
  mise::install_tool_local erlang "$ERLANG_VERSION"
  mise::install_tool_local elixir "$ELIXIR_VERSION"
  mise::install_tool_local node "$NODE_VERSION"
  mise::install_tool_local postgres "$POSTGRES_VERSION"
else
  echo "⚠️ No project files found (mix.exs, package.json, or .git)."
  echo "⏭️ Skipping local version configuration."
fi

# ------------------------------------------------------------------------------
# 7. Final message and shell reload
# ------------------------------------------------------------------------------

echo ""
if [[ $- == *i* ]]; then
  echo "🔄 Reloading ~/.zshrc in interactive shell..."
  source ~/.zshrc
else
  echo "ℹ️ Non-interactive shell detected. Please run 'source ~/.zshrc' manually."
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📄 Notes:"
echo "→ Tools are now available globally via mise."
echo "→ In projects, mise will automatically use versions defined in .mise.toml or .tool-versions."
