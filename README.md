# ansible-generator

Generate documentation and continuous integration files for an Ansible Role.

The intention is to focus on writing or maintaining the Ansible role, and use this tool to generate chore-like-tasks.

## Overview

```text
+--- role ----------------------+                     +--- role -------------------------------+
| meta/main.yml                 |                     | README.md                              |
| molecule/default/converge.yml |                     | .gitignore                             |
| meta/preferences.yml          |                     | .pre-commit-config.yaml                |
| requirements.yml              |                     | .yamllint                              |
| molecule/default/prepare.yml  |                     | .ansible-lint                          |
| molecule/default/verify.yml   |                     | .semrelrc                              |
| defaults/main.yml             |                     | CONTRIBUTING.md                        |
+------------------------+------+                     | AGENTS.md                              |
                         |                            | LICENSE                                |
+--- this tool -----+    |                            | SECURITY.md                            |
| defaults/main.yml | ---+                            | requirements.txt                       |
| vars/main.yml     |    |                            | molecule/default/molecule.yml          |
| files/*           |    |                            | molecule/requirements.txt              |
| templates/*       |    |                            | .github/settings.yml                   |
+-------------------+    |    +--- this tool ---+     | .github/dependabot.yml                 |
                         +--> | generate.yml    | --> | .github/workflows/molecule.yml         |
+--- Galaxy ---+         |    +-----------------+     | .github/workflows/dependabot-automerge |
| galaxy_id    | --------+                            |   .yml                                 |
+--------------+                                      | .github/workflows/galaxy.yml           |
                                                       | .github/workflows/todo.yml             |
                                                       | .github/workflows/go-semantic-release  |
                                                       |   .yml                                 |
                                                       +----------------------------------------+
```

`.gitlab-ci.yml`, `.tox.ini` and `.github/workflows/requirements2png.yml` are actively removed if present, they're not generated.

## Usage

```bash
cd ansible-role-my_role
../path/to/generate.yml
```

## Configuration

In `defaults/main.yml` you can change these variable to customize the output.

### Settings to Docker containers

- `docker_namespace`
- `docker_image`
- `docker_tag`

### Your username on Galaxy

- `galaxy_namespace`

### Your username/organization name on GitHub

- `github_namespace`

### Your username/group on GitLab

- `gitlab_namespace`

### Your name and optionally email-address

- `author`

### The full URL to your website

- `author_website`

### Molecule CI

Molecule is run directly on the GitHub-hosted runner (pip-installed, not via a
third-party action), so we control the exact `ansible-core`/collection
versions instead of inheriting whatever a molecule action bundles.

- `molecule_python_version` - the Python version `actions/setup-python` installs.
- `molecule_pip_requirements` - list of pinned packages written to `molecule/requirements.txt` and installed before `molecule test` runs.

## meta/preferences.yml

This (optional) file describes how Molecule, the generated README and CI should behave.

|parameter               |type           |default|description                                                                                                                                              |
|------------------------|---------------|-------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
|github_variables_mapping|list           |not set|A list of `name` and `variable`, `name` refers to the GitHub exposed name, `variable` refers to the name you'd like to pass to molecule and Ansible.|
|custom_message          |string         |not set|Free-form text rendered into the generated README (e.g. deprecation notices, links to upstream docs).                                                    |
|extra_platforms         |list           |not set|Extra `meta/main.yml`-style platform entries (`name`/`versions`) to add to the CI matrix and README compatibility table, for platforms that aren't valid Galaxy schema values (e.g. `CentOS`, which Galaxy only recognizes under the `EL` umbrella).|

Any variable normally set in this generator's own `defaults/main.yml` (like `molecule_python_version` above) can also be overridden per-role here.

## Example

```yaml
---
github_variables_mapping:
  - name: secrets.VAULT_LICENSE
    variable: VAULT_LICENCE
  - name: secrets.MY_VAR
    variable: someTHING

custom_message: |
  **Note:** upstream project X was archived; this role is kept for
  historical purposes.

extra_platforms:
  - name: CentOS
    versions:
      - all
```
