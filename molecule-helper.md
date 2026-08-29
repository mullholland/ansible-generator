# molecule-helper.sh

A shell helper to run `molecule test` on a local Ubuntu/Debian machine.
It checks all required dependencies, optionally installs them, optionally pre-pulls
Docker images, and then executes `molecule test`.

## Requirements

- Ubuntu / Debian (the `--install` step uses `apt-get`)
- `sudo` access for system package installation and Docker setup

## Usage

```
./molecule-helper.sh [OPTIONS]

Options:
  --install   Install system dependencies (Python 3, pip, venv, Docker) and
              create a Python venv at /opt/molecule-venv from requirements.txt
  --pull      Pull all configured Docker images before running molecule test
  --help      Show this help message
```

## Typical workflows

### Fresh Ubuntu machine — install everything, pull images, then test

```bash
./molecule-helper.sh --install --pull
```

### Already set up — just run tests

```bash
./molecule-helper.sh
```

### Already set up — refresh images and test

```bash
./molecule-helper.sh --pull
```

## What `--install` does

1. `sudo apt-get install python3 python3-pip python3-venv ca-certificates curl gnupg`
2. Installs Docker via the official [get.docker.com](https://get.docker.com) convenience
   script (skipped if Docker is already present) and adds the current user to the
   `docker` group.
3. Creates a Python venv at `/opt/molecule-venv`.
4. Installs packages from `requirements.txt` into the venv.

> **Note:** After Docker is installed for the first time you may need to log out and
> back in for the `docker` group membership to take effect, or run
> `newgrp docker` in the current shell.

## Python venv

The venv is created at `/opt/molecule-venv`. After `--install` completes you can
activate it manually:

```bash
source /opt/molecule-venv/bin/activate
```

The helper activates the venv automatically at the start of every run when it is
present, so `molecule` and `ansible` from the venv are on `PATH`.

## Docker images

The default image list covers the full set of supported distributions:

| Distribution   | Tags                  |
|----------------|-----------------------|
| AlmaLinux      | 8, 9, 10, latest      |
| Amazon Linux   | 2, 2023, latest       |
| Debian         | 12, 13, latest        |
| Fedora         | 42, 43, latest        |
| Ubuntu         | 22.04, 24.04, latest  |
| Red Hat        | 8, 9, 10, latest      |
| Rocky Linux    | 8, 9, 10, latest      |

Override the list by setting `MOLECULE_IMAGES` before calling the script:

```bash
MOLECULE_IMAGES="ghcr.io/mullholland/docker-debian-systemd:12 ghcr.io/mullholland/docker-ubuntu-systemd:2404" \
  ./molecule-helper.sh --pull
```

## requirements.txt

The `requirements.txt` next to this script defines the Python packages installed
into the venv:

```
ansible
molecule
molecule-plugins[docker]
docker
```

Extend it as needed before running `--install`.
