# dev-env-bootstrap

This project provides two alternatives for managing your development environment: using **asdf** or **mise**. Each tool has its own setup and teardown scripts.  
**Note:** We recommend using **asdf** for its transparency and control.

## Environment Management Alternatives

### 1. Using asdf (Recommended)

- **asdf** is a versatile version manager that allows you to manage multiple versions of programming languages and tools in your local environment.
- **Pros:** Wide plugin ecosystem, supports many languages, clear and explicit configuration, easy to debug and customize.
- **Cons:** Requires manual shell integration and configuration, plugins may need manual updates.

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

### 2. Using mise

- **mise** is a modern version manager that aims for simplicity and speed. Internally, it uses asdf for many operations but hides configuration details, making it less transparent.
- **Pros:** Fast installations, minimal manual setup, modern CLI.
- **Cons:** Configuration is more opaque, hides underlying mechanisms (often asdf), less control for advanced users.

#### Scripts

- **Bootstrap:** Installs and configures mise.
- **Teardown:** Removes mise and its configuration.

**Run bootstrap with curl:**
```sh
curl -sSL https://raw.githubusercontent.com/eccocar-dev/dev-env-bootstrap/main/bootstrap-mise.sh | zsh
```

**Run teardown with curl:**
```sh
curl -sSL https://raw.githubusercontent.com/eccocar-dev/dev-env-bootstrap/main/teardown-mise.sh | zsh
```

---

## Comparison Table

| Feature                | asdf                              | mise                          |
|------------------------|-----------------------------------|-------------------------------|
| Language Support       | Extensive (via plugins)           | Extensive (via asdf plugins)  |
| Version Management     | Granular, per-tool                | Granular, per-tool            |
| Shell Integration      | Required, manual                  | Minimal, mostly automatic     |
| Transparency          | High (explicit config)             | Low (hidden config, uses asdf)|
| Installation Speed     | Moderate                          | Fast                          |
| Ecosystem              | Mature, large community           | Newer, growing community      |

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
