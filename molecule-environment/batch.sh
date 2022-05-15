#!/usr/bin/env bash
set -e
set -u

### OPTIONS
##############################################################################

while getopts a:s:p: flag
do
    case "${flag}" in
        a) ansibles=${OPTARG};;
        s) scenarios=${OPTARG};;
        p) platforms=${OPTARG};;
    esac
done

### OPTIONS
##############################################################################
ANSIBLES=${ansibles:-current}
SCENARIOS=${scenarios:-default}
PLATFORMS=${platforms:-all}

### Variables
##############################################################################
TMPFILE="/tmp/batch.log"

PIPVIRTUALENVBASE="${HOME}/.virtualenvs/molecule"

PLATFORMS_DEBIAN="debian9
debian10
debian11"

PLATFORMS_UBUNTU="ubuntu1804
ubuntu2004
ubuntu2204"

PLATFORMS_CENTOS="
centos7
centos-stream8
centos-stream9
ubi8"

PLATFORMS_FEDORA="fedora34
fedora35
fedora36"

PLATFORMS_ROCKY="rockylinux8"

PLATFORMS_ALMA="almalinux8"

PLATFORMS_AMAZON="amazonlinux"


### Main
##############################################################################
echo "##########################"
echo "# Testing with:"
echo "# Ansible   = ${ANSIBLES}"
echo "# Scenarios = ${SCENARIOS}"
echo "# Platforms = ${PLATFORMS}"
echo "##########################"
echo "" > "${TMPFILE}"


echo "Linting before long testing"
for ANSIBLE_VERSION in ${ANSIBLES}
do
    echo "Using PENV => ${PIPVIRTUALENVBASE}/${ANSIBLE_VERSION}/bin/activate"
    source "${PIPVIRTUALENVBASE}/${ANSIBLE_VERSION}/bin/activate"

    # echo "Linting with Ansible ${ANSIBLE_VERSION}"
    molecule lint --scenario-name default
    # echo "[$(date +"%m-%d-%Y %T")] Testing" >> ${TMPFILE}
done


for SCENARIO in ${SCENARIOS}
do
  echo "[$(date +"%m-%d-%Y %T")] ${SCENARIO}" >> ${TMPFILE}
  for ANSIBLE_VERSION in ${ANSIBLES}
  do

    echo "[$(date +"%m-%d-%Y %T")]   ${ANSIBLE_VERSION}" >> ${TMPFILE}
    #echo "  source Virtual ENV ${VENVBASE}/${ANSIBLE}" >> ${TMPFILE}
    #source "${VENVBASE}/${ANSIBLE}/bin/activate"
    # Debian
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "debian" ]; then
      for PLATFORM in ${PLATFORMS_DEBIAN}
      do
          echo "[$(date +"%m-%d-%Y %T")]     ${PLATFORM}"  >> ${TMPFILE}
          if ansible=${ANSIBLE_VERSION} scenario=${SCENARIO} platform=${PLATFORM} molecule test --scenario-name ${SCENARIO}; then
            echo "[$(date +"%m-%d-%Y %T")]       Success" >> ${TMPFILE}
          else
            echo "[$(date +"%m-%d-%Y %T")]       Failure" >> ${TMPFILE}
          fi
      done
    fi

    # Ubuntu
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "ubuntu" ]; then
      for PLATFORM in ${PLATFORMS_UBUNTU}
      do
          echo "[$(date +"%m-%d-%Y %T")]     ${PLATFORM}"  >> ${TMPFILE}
          if ansible=${ANSIBLE_VERSION} scenario=${SCENARIO} platform=${PLATFORM} molecule test --scenario-name ${SCENARIO}; then
            echo "[$(date +"%m-%d-%Y %T")]       Success" >> ${TMPFILE}
          else
            echo "[$(date +"%m-%d-%Y %T")]       Failure" >> ${TMPFILE}
          fi
      done
    fi

    # CentOS
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "centos" ]; then
      for PLATFORM in ${PLATFORMS_CENTOS}
      do
          echo "[$(date +"%m-%d-%Y %T")]     ${PLATFORM}"  >> ${TMPFILE}
          if ansible=${ANSIBLE_VERSION} scenario=${SCENARIO} platform=${PLATFORM} molecule test --scenario-name ${SCENARIO}; then
            echo "[$(date +"%m-%d-%Y %T")]       Success" >> ${TMPFILE}
          else
            echo "[$(date +"%m-%d-%Y %T")]       Failure" >> ${TMPFILE}
          fi
      done
    fi

    # Fedora
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "fedora" ]; then
      for PLATFORM in ${PLATFORMS_FEDORA}
      do
          echo "[$(date +"%m-%d-%Y %T")]     ${PLATFORM}"  >> ${TMPFILE}
          if ansible=${ANSIBLE_VERSION} scenario=${SCENARIO} platform=${PLATFORM} molecule test --scenario-name ${SCENARIO}; then
            echo "[$(date +"%m-%d-%Y %T")]       Success" >> ${TMPFILE}
          else
            echo "[$(date +"%m-%d-%Y %T")]       Failure" >> ${TMPFILE}
          fi
      done
    fi

    # Rockylinux
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "rocky" ]; then
      for PLATFORM in ${PLATFORMS_ROCKY}
      do
          echo "[$(date +"%m-%d-%Y %T")]     ${PLATFORM}"  >> ${TMPFILE}
          if ansible=${ANSIBLE_VERSION} scenario=${SCENARIO} platform=${PLATFORM} molecule test --scenario-name ${SCENARIO}; then
            echo "[$(date +"%m-%d-%Y %T")]       Success" >> ${TMPFILE}
          else
            echo "[$(date +"%m-%d-%Y %T")]       Failure" >> ${TMPFILE}
          fi
      done
    fi


    # Almalinux
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "alma" ]; then
      for PLATFORM in ${PLATFORMS_ALMA}
      do
          echo "[$(date +"%m-%d-%Y %T")]     ${PLATFORM}"  >> ${TMPFILE}
          if ansible=${ANSIBLE_VERSION} scenario=${SCENARIO} platform=${PLATFORM} molecule test --scenario-name ${SCENARIO}; then
            echo "[$(date +"%m-%d-%Y %T")]       Success" >> ${TMPFILE}
          else
            echo "[$(date +"%m-%d-%Y %T")]       Failure" >> ${TMPFILE}
          fi
      done
    fi

    # Amazon
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "amazon" ]; then
      for PLATFORM in ${PLATFORMS_AMAZON}
      do
          echo "[$(date +"%m-%d-%Y %T")]     ${PLATFORM}"  >> ${TMPFILE}
          if ansible=${ANSIBLE_VERSION} scenario=${SCENARIO} platform=${PLATFORM} molecule test --scenario-name ${SCENARIO}; then
            echo "[$(date +"%m-%d-%Y %T")]       Success" >> ${TMPFILE}
          else
            echo "[$(date +"%m-%d-%Y %T")]       Failure" >> ${TMPFILE}
          fi
      done
    fi

    # Single test
    if [ "$PLATFORMS" != "all" ] && [ "$PLATFORMS" != "debian" ] && [ "$PLATFORMS" != "ubuntu" ] && [ "$PLATFORMS" != "centos" ] && [ "$PLATFORMS" != "fedora" ] && [ "$PLATFORMS" != "rocky" ] && [ "$PLATFORMS" != "alma" ] && [ "$PLATFORMS" != "amazon" ]; then
      for PLATFORM in ${PLATFORMS}
      do
          echo "[$(date +"%m-%d-%Y %T")]     ${PLATFORM}"  >> ${TMPFILE}
          if ansible=${ANSIBLE_VERSION} scenario=${SCENARIO} platform=${PLATFORM} molecule test --scenario-name ${SCENARIO}; then
            echo "[$(date +"%m-%d-%Y %T")]       Success" >> ${TMPFILE}
          else
            echo "[$(date +"%m-%d-%Y %T")]       Failure" >> ${TMPFILE}
          fi
      done
    fi

  done
done


cat ${TMPFILE}
