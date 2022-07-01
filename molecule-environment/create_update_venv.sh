#!/usr/bin/env bash
set -e
set -u

PIPVIRTUALENVBASE="${HOME}/.virtualenvs/molecule"
PIPPACKAGES="yamllint ansible-lint molecule molecule-docker ansible-lint docker yamllint"
# Which ansible version to install
ANSIBLE_VERSIONS="previous
current
development"

SCRIPT_PATH="$(dirname "$0")"

### Prepare Python ENVs
##############################################################################
echo "Prepare Virtual Environments"
for ANSIBLE in ${ANSIBLE_VERSIONS}
do
  echo "Check virtualenv"
  if [ -d "${PIPVIRTUALENVBASE}/${ANSIBLE}" ]; then
    echo "Virtualenv already exists"
  else
    echo "Creating virtualenv ${PIPVIRTUALENVBASE}/${ANSIBLE}"
    python3 -m venv "${PIPVIRTUALENVBASE}/${ANSIBLE}"
  fi

  echo "activate virtualenv under ${PIPVIRTUALENVBASE}/${ANSIBLE}"
  # Source is always variable
  # shellcheck disable=SC1090 
  source "${PIPVIRTUALENVBASE}/${ANSIBLE}/bin/activate"
  echo "upgrading PIP"
  python -m pip install --upgrade pip
  echo "install python packages"
  pip3 install --no-cache-dir --no-compile -r "$SCRIPT_PATH/requirements.${ANSIBLE}.txt"
done

echo "Show Ansible Versions"
for ANSIBLE in ${ANSIBLE_VERSIONS}
do
  echo "==============================================="
  # Source is always variable
  # shellcheck disable=SC1090 
  source "${PIPVIRTUALENVBASE}/${ANSIBLE}/bin/activate"
  echo "${ANSIBLE}"
  ansible --version
done