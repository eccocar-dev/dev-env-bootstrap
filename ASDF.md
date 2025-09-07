# 🛠️ Environment Bootstrap with `asdf` on macOS

This document describes how to install and configure **Erlang**, **Elixir**, **Node.js**, and **Postgres** using [asdf](https://asdf-vm.com) on macOS.

---

## 📦 Prerequisites

1. Install [Homebrew](https://brew.sh/).
2. Use macOS.

---

## 🔧 Step-by-step installation

### 1. Install `asdf`

```bash
brew install asdf
```

### 2. Configure `asdf` in your `~/.zshenv`

Add these lines to `~/.zshenv`:

```bash
# asdf: Custom data directory (default)
export ASDF_DATA_DIR="$HOME/.asdf"

# asdf: Add shims to PATH
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# asdf completions
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
```

Generate completions:

```bash
mkdir -p ${ASDF_DATA_DIR:-$HOME/.asdf}/completions
asdf completion zsh > ${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf
```

Reload your shell:

```bash
source ~/.zshrc
```

Finally, load `asdf` into the current shell session:

```bash
source $(brew --prefix asdf)/libexec/asdf.sh
```

---

### 3. Install Erlang dependencies

```bash
brew install autoconf openssl wxwidgets libxslt fop
```

Configure environment variables in `~/.zshrc`:

```bash
# ASDF / Erlang settings
export KERL_CONFIGURE_OPTIONS="--disable-debug --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-threads --enable-kernel-poll --enable-wx --enable-webview --enable-darwin-64bit --enable-gettimeofday-as-os-system-time --with-ssl=$(brew --prefix openssl)"
export KERL_BUILD_DOCS="yes"
export KERL_INSTALL_HTMLDOCS="no"
export KERL_INSTALL_MANPAGES="no"
```

---

### 4. Install Elixir dependencies

```bash
brew install unzip
```

---

### 5. Install Node.js dependencies

```bash
brew install gpg gawk
```

Enable compatibility with `.nvmrc` or `.node-version` in `~/.asdfrc`:

```bash
echo "legacy_version_file = yes" >> ~/.asdfrc
```

---

### 6. Install Postgres dependencies

```bash
brew install gcc readline zlib curl ossp-uuid icu4c pkg-config
```

Configure in `~/.zshrc`:

```bash
# Postgres plugin build config
export PKG_CONFIG_PATH="$(brew --prefix)/bin/pkg-config:$(brew --prefix icu4c)/lib/pkgconfig:$(brew --prefix curl)/lib/pkgconfig:$(brew --prefix zlib)/lib/pkgconfig"
```

---

### 7. Add `asdf` plugins

```bash
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add postgres https://github.com/smashedtoatoms/asdf-postgres
```

---

### 8. Install specific versions

```bash
asdf install erlang 28.0.2
asdf global erlang 28.0.2

asdf install elixir 1.18.4-otp-27
asdf global elixir 1.18.4-otp-27

asdf install nodejs 22.17.1
asdf global nodejs 22.17.1

asdf install postgres 17.5
asdf global postgres 17.5
```

---

### 9. Persist versions in a project

If you are working in a project with `mix.exs`, `package.json` or `.git`, set local versions:

```bash
asdf local erlang 28.0.2
asdf local elixir 1.18.4-otp-27
asdf local nodejs 22.17.1
asdf local postgres 17.5
```

This will create a `.tool-versions` file in your project directory.

---

### 10. Finalize installation

Reload your shell:

```bash
source ~/.zshrc
```

---

## ✅ Installation complete

You now have installed:

- **Erlang 28.0.2**
- **Elixir 1.18.4-otp-27**
- **Node.js 22.17.1**
- **Postgres 17.5**

---

## 🐞 Troubleshooting

### 1. Error compiling Erlang with OpenSSL
If you get an OpenSSL compilation error:
```bash
brew reinstall openssl
```
and make sure `KERL_CONFIGURE_OPTIONS` points to the correct path:
```bash
export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl)"
```

### 2. Issues with wxWidgets in `:observer`
If `:observer.start()` fails:
```bash
brew reinstall wxwidgets
```

### 3. Node.js doesn’t recognize `.nvmrc`
Verify that your `~/.asdfrc` contains:
```bash
legacy_version_file = yes
```

### 4. Postgres missing dependencies
If Postgres build fails due to missing libraries:
```bash
brew reinstall readline zlib curl icu4c
```

### 5. Changes in `.zshrc` not applied
Reload the file:
```bash
source ~/.zshrc
```
