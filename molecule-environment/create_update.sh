#!/usr/bin/env bash
set -e
set -u

### Variables
##############################################################################
MOLECULE_IMAGE="ghcr.io/mullholland/docker-molecule-shell"
BASE_IMAGES="ghcr.io/mullholland/docker-molecule-debian9
ghcr.io/mullholland/docker-molecule-debian10
ghcr.io/mullholland/docker-molecule-debian11
ghcr.io/mullholland/docker-molecule-ubuntu1804
ghcr.io/mullholland/docker-molecule-ubuntu2004
ghcr.io/mullholland/docker-molecule-ubuntu2204
ghcr.io/mullholland/docker-molecule-centos7
ghcr.io/mullholland/docker-molecule-centos-stream8
ghcr.io/mullholland/docker-molecule-centos-stream9
ghcr.io/mullholland/docker-molecule-ubi8
ghcr.io/mullholland/docker-molecule-fedora34
ghcr.io/mullholland/docker-molecule-fedora35
ghcr.io/mullholland/docker-molecule-fedora36
ghcr.io/mullholland/docker-molecule-rockylinux8
ghcr.io/mullholland/docker-molecule-almalinux8
ghcr.io/mullholland/docker-molecule-amazonlinux
"

PIPVIRTUALENVBASE="${HOME}/.virtualenvs/molecule"
PIPPACKAGES="yamllint ansible-lint molecule molecule-docker ansible-lint docker yamllint"
# Which ansible version to install
ANSIBLE_VERSIONS="previous
current
next"

SCRIPT_PATH="$(dirname "$0")"

### Update Images
##############################################################################
echo "Update Molecule Images"
docker pull "${MOLECULE_IMAGE}"
echo "==============================================="

echo "Update Molecule Platform Images"
for IMAGE in ${BASE_IMAGES}
do
  echo "Pull ${IMAGE}"
  docker pull "${IMAGE}"
  echo "==============================================="
done

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