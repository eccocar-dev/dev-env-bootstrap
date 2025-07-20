# dev-env-bootstrap

This project provides two alternatives for managing your development environment: using **asdf** or **pkgx**. Each tool has its own setup and teardown scripts.

## Environment Management Alternatives

### 1. Using asdf

- **asdf** is a versatile version manager that allows you to manage multiple versions of programming languages and tools in your local environment.
- **Pros:** Wide plugin ecosystem, supports many languages, easy to use.
- **Cons:** Requires shell integration, plugins may need manual updates.

#### Scripts

- **Bootstrap:** Installs and configures asdf.
- **Teardown:** Removes asdf and its configuration.

**Run bootstrap with curl:**
```sh
curl -sSL https://raw.githubusercontent.com/eccocar-dev/dev-env-bootstrap/main/bootstrap-asdf.sh | zsh
```

**Run teardown with curl:**
```sh
curl -sSL https://raw.githubusercontent.com/eccocar-dev/dev-env-bootstrap/main/teardown-asdf.sh | zsh
```

---

### 2. Using pkgx

- **pkgx** is a modern package manager that installs and runs tools in isolated environments, focusing on simplicity and speed.
- **Pros:** No shell integration required, fast installations, ephemeral environments.
- **Cons:** Smaller ecosystem, less granular version control compared to asdf.

#### Scripts

- **Bootstrap:** Installs and configures pkgx.
- **Teardown:** Removes pkgx and its configuration.

**Run bootstrap with curl:**
```sh
curl -sSL https://raw.githubusercontent.com/eccocar-dev/dev-env-bootstrap/main/bootstrap-pkgx.sh | zsh
```

**Run teardown with curl:**
```sh
curl -sSL https://raw.githubusercontent.com/eccocar-dev/dev-env-bootstrap/main/teardown-pkgx.sh | zsh
```

---

## Comparison Table

| Feature                | asdf                              | pkgx                          |
|------------------------|-----------------------------------|-------------------------------|
| Language Support       | Extensive (via plugins)           | Limited but growing           |
| Version Management     | Granular, per-tool                | Global, less granular         |
| Shell Integration      | Required                          | Not required                  |
| Installation Speed     | Moderate                          | Fast                          |
| Ecosystem              | Mature, large community           | Newer, smaller community      |

## Requirements

- You must have `curl` and `zsh` installed.

## References

For further reading and professional guides on setting up Elixir and Phoenix development environments, consider the following resources:

- [Setting up Elixir & Phoenix](https://aswinmohan.me/setup-elixir-phoenix) by Aswin Mohan  
  A comprehensive guide for configuring Elixir and Phoenix on your system.

- [Preparing the Elixir Development Environment](https://dev.to/muzhawir/preparing-the-elixir-development-environment-39ep) by Muzhawir  
  Step-by-step instructions for preparing your machine for Elixir development.

- [Perfect Elixir Environment Setup](https://dev.to/jonlauridsen/perfect-elixir-environment-setup-1145) by Jon Lauridsen  
  Best practices and tips for creating an optimal Elixir development environment.

- [Elixir and Phoenix Setup Gist](https://gist.github.com/sstrecker/9de2f970be4f779395d832cfcd331e25) by sstrecker  
  A curated gist with commands and notes for installing Elixir and Phoenix.
