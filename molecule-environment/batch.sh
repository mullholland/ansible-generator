#!/usr/bin/env bash
set -e
set -u

function usage {
    echo "Usage of batch.sh"
    echo "Options are:"
    echo "  -s => scenarios"
    echo "    which scenarios should be tested, defaults to default"
    echo "  -p => platforms"
    echo "    which platforms should be tested, defaults to all"
    echo ""
    echo "Possible platform values are:"
    echo "ubuntu  => tests ubuntu1804, ubuntu2004, ubuntu2204"
    echo "debian  => tests debian10 and debian11"
    echo "centos  => tests centos7 and centos-stream8"
    echo "fedora  => tests fedora35 and fedora36"
    echo "rocky   => tests RockyLinux 8"
    echo "alma    => tests AlmaLinux 8"
    echo "amazon  => tests Amazon Linux 2"
    echo "all     => tests all of the above (is default and can be omitted)"
    echo "single platform like ubuntu1804 or list like 'ubuntu1804 centos7'"
    exit 0
}

### OPTIONS
##############################################################################

# ignore invalid flags
# shellcheck disable=SC2220
while getopts s:p: flag
do
    case "${flag}" in
        s) scenarios=${OPTARG};;
        p) platforms=${OPTARG};;
        ?) usage;;
    esac
done

### OPTIONS
##############################################################################
SCENARIOS=${scenarios:-default}
PLATFORMS=${platforms:-all}

### Variables
##############################################################################
TMPFILE="/tmp/batch.log"

PLATFORMS_UBUNTU="ubuntu1804
ubuntu2004
ubuntu2204"

PLATFORMS_DEBIAN="debian10
debian11"

PLATFORMS_CENTOS="
centos7
centos-stream8
"

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
echo "# Scenarios = ${SCENARIOS}"
echo "# Platforms = ${PLATFORMS}"
echo "##########################"
echo "" > "${TMPFILE}"


echo "Linting before long testing"
molecule lint --scenario-name default

for SCENARIO in ${SCENARIOS}
do

    # Ubuntu
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "ubuntu" ]; then
        for PLATFORM in ${PLATFORMS_UBUNTU}
        do
            echo "[$(date +"%m-%d-%Y %T")]  ${PLATFORM}"  >> "${TMPFILE}"
            if scenario="${SCENARIO}" platform="${PLATFORM}" molecule test --scenario-name "${SCENARIO}"; then
                echo "[$(date +"%m-%d-%Y %T")]    Success" >> "${TMPFILE}"
            else
                echo "[$(date +"%m-%d-%Y %T")]    Failure" >> "${TMPFILE}"
            fi
        done
    fi

    # Debian
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "debian" ]; then
        for PLATFORM in ${PLATFORMS_DEBIAN}
        do
            echo "[$(date +"%m-%d-%Y %T")]  ${PLATFORM}"  >> "${TMPFILE}"
            if scenario="${SCENARIO}" platform="${PLATFORM}" molecule test --scenario-name "${SCENARIO}"; then
                echo "[$(date +"%m-%d-%Y %T")]    Success" >> "${TMPFILE}"
            else
                echo "[$(date +"%m-%d-%Y %T")]    Failure" >> "${TMPFILE}"
            fi
        done
    fi

    # CentOS
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "centos" ]; then
        for PLATFORM in ${PLATFORMS_CENTOS}
        do
            echo "[$(date +"%m-%d-%Y %T")]  ${PLATFORM}"  >> "${TMPFILE}"
            if scenario="${SCENARIO}" platform="${PLATFORM}" molecule test --scenario-name "${SCENARIO}"; then
                echo "[$(date +"%m-%d-%Y %T")]    Success" >> "${TMPFILE}"
            else
                echo "[$(date +"%m-%d-%Y %T")]    Failure" >> "${TMPFILE}"
            fi
        done
    fi

    # Fedora
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "fedora" ]; then
        for PLATFORM in ${PLATFORMS_FEDORA}
        do
            echo "[$(date +"%m-%d-%Y %T")]  ${PLATFORM}"  >> "${TMPFILE}"
            if scenario="${SCENARIO}" platform="${PLATFORM}" molecule test --scenario-name "${SCENARIO}"; then
                echo "[$(date +"%m-%d-%Y %T")]    Success" >> "${TMPFILE}"
            else
                echo "[$(date +"%m-%d-%Y %T")]    Failure" >> "${TMPFILE}"
            fi
        done
    fi

    # RockyLinux
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "rocky" ]; then
        for PLATFORM in ${PLATFORMS_ROCKY}
        do
            echo "[$(date +"%m-%d-%Y %T")]  ${PLATFORM}"  >> "${TMPFILE}"
            if scenario="${SCENARIO}" platform="${PLATFORM}" molecule test --scenario-name "${SCENARIO}"; then
                echo "[$(date +"%m-%d-%Y %T")]    Success" >> "${TMPFILE}"
            else
                echo "[$(date +"%m-%d-%Y %T")]    Failure" >> "${TMPFILE}"
            fi
        done
    fi

    # AlmaLinux
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "alma" ]; then
        for PLATFORM in ${PLATFORMS_ALMA}
        do
            echo "[$(date +"%m-%d-%Y %T")]  ${PLATFORM}"  >> "${TMPFILE}"
            if scenario="${SCENARIO}" platform="${PLATFORM}" molecule test --scenario-name "${SCENARIO}"; then
                echo "[$(date +"%m-%d-%Y %T")]    Success" >> "${TMPFILE}"
            else
                echo "[$(date +"%m-%d-%Y %T")]    Failure" >> "${TMPFILE}"
            fi
        done
    fi

    # Amazon
    if [ "$PLATFORMS" = "all" ] || [ "$PLATFORMS" = "amazon" ]; then
        for PLATFORM in ${PLATFORMS_AMAZON}
        do
            echo "[$(date +"%m-%d-%Y %T")]  ${PLATFORM}"  >> "${TMPFILE}"
            if scenario="${SCENARIO}" platform="${PLATFORM}" molecule test --scenario-name "${SCENARIO}"; then
                echo "[$(date +"%m-%d-%Y %T")]    Success" >> "${TMPFILE}"
            else
                echo "[$(date +"%m-%d-%Y %T")]    Failure" >> "${TMPFILE}"
            fi
        done
    fi

    # Single test
    if [ "$PLATFORMS" != "all" ] && [ "$PLATFORMS" != "ubuntu" ] && [ "$PLATFORMS" != "debian" ] && [ "$PLATFORMS" != "centos" ] && [ "$PLATFORMS" != "fedora" ] && [ "$PLATFORMS" != "rocky" ] && [ "$PLATFORMS" != "alma" ] && [ "$PLATFORMS" != "amazon" ]; then
        for PLATFORM in ${PLATFORMS}
        do
            echo "[$(date +"%m-%d-%Y %T")]  ${PLATFORM}"  >> "${TMPFILE}"
            if scenario="${SCENARIO}" platform="${PLATFORM}" molecule test --scenario-name "${SCENARIO}"; then
                echo "[$(date +"%m-%d-%Y %T")]    Success" >> "${TMPFILE}"
            else
                echo "[$(date +"%m-%d-%Y %T")]    Failure" >> "${TMPFILE}"
            fi
        done
    fi
done

cat "${TMPFILE}"
