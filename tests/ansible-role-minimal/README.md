# [Ansible role minimal](#minimal)

Install and configure minimal on your system.

|GitHub|Downloads|Version|
|------|---------|-------|
|[![github](https://github.com/mullholland/ansible-role-minimal/actions/workflows/molecule.yml/badge.svg)](https://github.com/mullholland/ansible-role-minimal/actions/workflows/molecule.yml)|[![downloads](https://img.shields.io/ansible/role/d/mullholland/minimal)](https://galaxy.ansible.com/mullholland/minimal)|[![Version](https://img.shields.io/github/release/mullholland/ansible-role-minimal.svg)](https://github.com/mullholland/ansible-role-minimal/releases/)|
## [Example Playbook](#example-playbook)

This example is taken from [`molecule/default/converge.yml`](https://github.com/mullholland/ansible-role-minimal/blob/master/molecule/default/converge.yml) and is tested on each push, pull request and release.

```yaml
---
- name: Converge
  hosts: all
  become: yes
  gather_facts: yes

  roles:
    - role: mullholland.minimal
```



## [Requirements](#requirements)

- pip packages listed in [requirements.txt](https://github.com/mullholland/ansible-role-minimal/blob/master/requirements.txt).


## [Context](#context)

This role is a part of many compatible roles. Have a look at [the documentation of these roles](https://mullholland.net) for further information.

## [Compatibility](#compatibility)

This role has been tested on these [container images](https://hub.docker.com/u/mullholland):

|container|tags|
|---------|----|
|[Alpine](https://hub.docker.com/r/mullholland/alpine)|all|
|[Amazon](https://hub.docker.com/r/mullholland/amazonlinux)|all|
|[Debian](https://hub.docker.com/r/mullholland/debian)|all|
|[EL](https://hub.docker.com/r/mullholland/enterpriselinux)|all|
|[Fedora](https://hub.docker.com/r/mullholland/fedora/)|all|
|[opensuse](https://hub.docker.com/r/mullholland/opensuse)|all|
|[Ubuntu](https://hub.docker.com/r/mullholland/ubuntu)|all|

The minimum version of Ansible required is 2.10, tests have been done to:

- The version before the previous version.
- The previous version.
- The current version.

If you find issues, please register them in [GitHub](https://github.com/mullholland/ansible-role-minimal/issues).

## [License](#license)

[Apache-2.0](https://github.com/mullholland/ansible-role-minimal/blob/master/LICENSE).

## [Author Information](#author-information)

[robertdebock](https://mullholland.net)
