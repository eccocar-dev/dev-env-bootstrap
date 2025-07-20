# dev-env-bootstrap

This project includes two main scripts: `bootstrap-asdf` and `teardown-asdf`.

## What are they used for?

- **bootstrap-asdf**: Installs and configures the [asdf](https://asdf-vm.com/) version manager on your local environment, allowing you to manage multiple versions of tools and programming languages.
- **teardown-asdf**: Removes the configuration and uninstalls asdf from your local environment.

## How to run with `curl`

You can run the scripts directly from the terminal using `curl`:

### Run bootstrap-asdf

```sh
curl -sSL https://raw.githubusercontent.com/eccocar-dev/dev-env-bootstrap/main/bootstrap-asdf.sh | zsh
```

### Run teardown-asdf

```sh
curl -sSL https://raw.githubusercontent.com/eccocar-dev/dev-env-bootstrap/main/teardown-asdf.sh | zsh
```

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
