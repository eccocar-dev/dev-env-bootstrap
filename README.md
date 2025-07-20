# dev-env-bootstrap

This project includes two main scripts: `bootstrap-asdf` and `teardown-asdf`.

## What are they used for?

- **bootstrap-asdf**: Installs and configures the [asdf](https://asdf-vm.com/) version manager on your local environment, allowing you to manage multiple versions of tools and programming languages.
- **teardown-asdf**: Removes the configuration and uninstalls asdf from your local environment.

## How to run with `curl`

You can run the scripts directly from the terminal using `curl`:

### Run bootstrap-asdf

```sh
curl -sSL https://github.com/eccocar-dev/dev-env-bootstrap | bash
```

### Run teardown-asdf

```sh
curl -sSL https://github.com/eccocar-dev/dev-env-bootstrap | bash
```

## Requirements

- You must have `curl` and `bash` installed.
