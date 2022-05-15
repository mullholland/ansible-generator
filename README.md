# Ansible Generator

Collection of helper scripts for me to test ansible roles.

## molecule-envrionment

### create_update.sh

Downloads all docker images for the role testing and sets up the needed python virtual environments for testing.

### batch.sh

Wrapper for "molecule test" to test different variations of platforms.

## role-generator
based on/onspired by [ansible-generator by Robert de Bock](https://github.com/robertdebock/ansible-generator)

### Usage "role-generator"

The "role-generator" ist a helper tool to ease the ansible role development.
It is heavily opiononated and primarily used be me.
Feel free to use it, fork it or do anything else with it.

#### Generate empty role

To generate an empty role with the generator, switch in the empty git directory of the new role an execute `generate_empty.yml` from the "role-generator".
You HAVE to be in the directory of the new role, because the "role-generator" used its path to generate some settings.

Be careful to only execute `generate_empty`once, for it will overwrite your changes.

#### Update a role and create documentation
If you ar done writing your role or testing your changes you should call `generate_doc.yml` from th "role-generator".
As for `generate_empty`you HAVE to be in the role directory, as it reads some of your role file to generate the `README.md` and the CI Files.

#### molecule.config
The non-standard molecule file in `molecule/molecule.config`is used by me to configure the molecule tests. It allows an easy way to define multiple scenarios with different platforms to be testet and to generate the needed CI config.


# Ansible Versions

The really used ansibel Version can found in the Container [docker-molecule-shell](https://github.com/mullholland/docker-molecule-shell/files) and there you find the `requirements` files.
