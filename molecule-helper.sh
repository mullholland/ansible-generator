#!/usr/bin/env bash

set -u

# Default image list for local pre-pull. Override with MOLECULE_IMAGES.
DEFAULT_IMAGES="ghcr.io/mullholland/docker-almalinux-systemd:8
ghcr.io/mullholland/docker-almalinux-systemd:9
ghcr.io/mullholland/docker-almalinux-systemd:10
ghcr.io/mullholland/docker-almalinux-systemd:latest
ghcr.io/mullholland/docker-amazonlinux-systemd:2
ghcr.io/mullholland/docker-amazonlinux-systemd:2023
ghcr.io/mullholland/docker-amazonlinux-systemd:latest
ghcr.io/mullholland/docker-debian-systemd:12
ghcr.io/mullholland/docker-debian-systemd:13
ghcr.io/mullholland/docker-debian-systemd:latest
ghcr.io/mullholland/docker-fedora-systemd:42
ghcr.io/mullholland/docker-fedora-systemd:43
ghcr.io/mullholland/docker-fedora-systemd:latest
ghcr.io/mullholland/docker-ubuntu-systemd:2204
ghcr.io/mullholland/docker-ubuntu-systemd:2404
ghcr.io/mullholland/docker-ubuntu-systemd:latest
ghcr.io/mullholland/docker-redhat-systemd:8
ghcr.io/mullholland/docker-redhat-systemd:9
ghcr.io/mullholland/docker-redhat-systemd:10
ghcr.io/mullholland/docker-redhat-systemd:latest
ghcr.io/mullholland/docker-rockylinux-systemd:8
ghcr.io/mullholland/docker-rockylinux-systemd:9
ghcr.io/mullholland/docker-rockylinux-systemd:10
ghcr.io/mullholland/docker-rockylinux-systemd:latest"
MOLECULE_IMAGES="${MOLECULE_IMAGES:-$DEFAULT_IMAGES}"

print_header() {
	echo ""
	echo "==> $1"
}

check_command() {
	local cmd="$1"
	local hint="$2"

	if command -v "$cmd" >/dev/null 2>&1; then
		echo "[ok] $cmd"
		return 0
	fi

	echo "[missing] $cmd"
	echo "         $hint"
	return 1
}

# Venv location and requirements file
VENV_DIR="/opt/molecule-venv"
REQUIREMENTS_FILE="$(cd "$(dirname "$0")" && pwd)/requirements.txt"

check_python_module() {
	local module="$1"
	local display="$2"

	if python3 -c "import $module" >/dev/null 2>&1; then
		echo "[ok] python module: $display"
		return 0
	fi

	echo "[missing] python module: $display"
	echo "          Re-run with --install to install dependencies via pip."
	return 1
}

install_system_dependencies() {
	print_header "Installing system dependencies (Python + Docker) via apt-get"

	if ! command -v apt-get >/dev/null 2>&1; then
		echo "[error] apt-get not found. This step requires an Ubuntu/Debian system."
		return 1
	fi

	echo "Running: sudo apt-get update"
	if ! sudo apt-get update -qq; then
		echo "[error] apt-get update failed."
		return 1
	fi

	echo "Running: sudo apt-get install -y python3 python3-pip python3-venv ca-certificates curl gnupg"
	if ! sudo apt-get install -y python3 python3-pip python3-venv ca-certificates curl gnupg; then
		echo "[error] apt-get install failed."
		return 1
	fi

	if ! command -v docker >/dev/null 2>&1; then
		echo "Docker not found, installing via official convenience script..."
		if ! curl -fsSL https://get.docker.com | sudo sh; then
			echo "[error] Docker installation failed."
			return 1
		fi
		echo "Adding current user to docker group..."
		sudo usermod -aG docker "$USER"
		echo "[ok] Docker installed. You may need to log out and back in for group membership to take effect."
	else
		echo "[ok] docker already installed, skipping."
	fi
}

install_python_dependencies() {
	print_header "Installing Python dependencies into venv"

	if ! command -v python3 >/dev/null 2>&1; then
		echo "[error] python3 not found. Run with --install to install system dependencies first."
		return 1
	fi

	if [ ! -f "$REQUIREMENTS_FILE" ]; then
		echo "[error] requirements.txt not found at $REQUIREMENTS_FILE"
		return 1
	fi

	echo "Creating venv at $VENV_DIR"
	if ! sudo python3 -m venv "$VENV_DIR"; then
		echo "[error] Failed to create venv at $VENV_DIR"
		return 1
	fi

	sudo chown -R "$USER" "$VENV_DIR"

	echo "Running: $VENV_DIR/bin/pip install -r $REQUIREMENTS_FILE"
	if ! "$VENV_DIR/bin/pip" install -r "$REQUIREMENTS_FILE"; then
		echo "[error] pip install failed."
		return 1
	fi

	echo "[ok] Python dependencies installed into $VENV_DIR"
	echo "     Activate with: source $VENV_DIR/bin/activate"
}

install_dependencies() {
	if ! install_system_dependencies; then
		return 1
	fi
	if ! install_python_dependencies; then
		return 1
	fi
}

activate_venv() {
	if [ -f "$VENV_DIR/bin/activate" ]; then
		# shellcheck disable=SC1090
		source "$VENV_DIR/bin/activate"
		echo "[ok] venv activated: $VENV_DIR"
		return 0
	fi
	return 1
}

check_dependency_versions() {
	print_header "Detected versions"
	python3 --version 2>/dev/null || true
	"${VENV_DIR}/bin/molecule" --version 2>/dev/null || molecule --version 2>/dev/null || true
	"${VENV_DIR}/bin/ansible" --version 2>/dev/null | head -n 1 || ansible --version 2>/dev/null | head -n 1 || true
	docker --version 2>/dev/null || true
}

pull_images() {
	print_header "Docker images"
	echo "Configured MOLECULE_IMAGES:"
	for image in $MOLECULE_IMAGES; do
		echo " - $image"
	done

	for image in $MOLECULE_IMAGES; do
		echo "Pulling $image"
		if ! docker pull "$image"; then
			echo "Failed to pull $image"
			return 1
		fi
	done

	return 0
}

show_images_info() {
	print_header "Docker images"
	echo "The following images are configured (not downloaded)."
	echo "Re-run with --pull to download them before testing."
	echo "Configured MOLECULE_IMAGES:"
	for image in $MOLECULE_IMAGES; do
		echo " - $image"
	done
}

run_molecule_test() {
	print_header "Run molecule"

	local molecule_bin
	if [ -f "$VENV_DIR/bin/molecule" ]; then
		molecule_bin="$VENV_DIR/bin/molecule"
	else
		molecule_bin="molecule"
	fi

	echo "Executing: $molecule_bin test"
	"$molecule_bin" test
}

usage() {
	echo "Usage: $(basename "$0") [OPTIONS]"
	echo ""
	echo "Options:"
	echo "  --install  Install system deps (Python, Docker via apt-get) and create venv in $VENV_DIR"
	echo "  --pull     Pull configured Docker images before running molecule test"
}

main() {
	local missing=0
	local do_pull=0
	local do_install=0

	for arg in "$@"; do
		case "$arg" in
			--install) do_install=1 ;;
			--pull) do_pull=1 ;;
			--help|-h) usage; exit 0 ;;
			*) echo "Unknown option: $arg"; usage; exit 1 ;;
		esac
	done

	if [ "$do_install" -eq 1 ]; then
		if ! install_dependencies; then
			exit 1
		fi
	fi

	# Activate venv if available so molecule/ansible are on PATH
	if [ -f "$VENV_DIR/bin/activate" ]; then
		# shellcheck disable=SC1090
		source "$VENV_DIR/bin/activate"
		echo "[ok] venv activated: $VENV_DIR"
	fi

	print_header "Checking Molecule dependencies"

	check_command "python3" "Run with --install to install Python and Docker via apt-get." || missing=1
	check_command "pip3" "Run with --install to install Python and Docker via apt-get." || missing=1
	check_command "molecule" "Run with --install to create $VENV_DIR and install from requirements.txt." || missing=1
	check_command "ansible" "Run with --install to create $VENV_DIR and install from requirements.txt." || missing=1
	check_command "docker" "Run with --install to install Docker via the official convenience script." || missing=1

	if command -v python3 >/dev/null 2>&1; then
		check_python_module "molecule" "molecule" || missing=1
		check_python_module "ansible" "ansible" || missing=1
	fi

	if command -v docker >/dev/null 2>&1; then
		if docker info >/dev/null 2>&1; then
			echo "[ok] docker daemon reachable"
		else
			echo "[missing] docker daemon unreachable"
			echo "          Start Docker Desktop and retry."
			missing=1
		fi
	fi

	if [ "$missing" -ne 0 ]; then
		print_header "Dependency check failed"
		echo "One or more dependencies are missing or unavailable."
		echo "Nothing was installed by this helper."
		exit 1
	fi

	check_dependency_versions

	if [ "$do_pull" -eq 1 ]; then
		if ! pull_images; then
			echo "Stopping because image pull failed."
			exit 1
		fi
	else
		show_images_info
	fi

	run_molecule_test
}

main "$@"
