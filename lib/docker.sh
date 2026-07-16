#!/usr/bin/env bash

install_docker() {

    step "Installing Docker"

    # --------------------------------------------------
    # Docker CE already installed
    # --------------------------------------------------
    if dpkg -s docker-ce >/dev/null 2>&1 && \
       docker compose version >/dev/null 2>&1; then
        success "Docker CE and Docker Compose are already installed."
        return
    fi

    # --------------------------------------------------
    # Detect Linux Distribution
    # --------------------------------------------------
    . /etc/os-release

    case "$ID" in
        ubuntu|debian)
            DOCKER_REPO="$ID"
            ;;
        *)
            error "Unsupported Linux distribution: $ID"
            exit 1
            ;;
    esac

    info "Detected $PRETTY_NAME"

    # --------------------------------------------------
    # Remove old Docker packages
    # --------------------------------------------------
    apt-get remove -y \
        docker \
        docker-engine \
        docker.io \
        containerd \
        runc \
        >/dev/null 2>&1 || true

    # --------------------------------------------------
    # Install prerequisites
    # --------------------------------------------------
    apt-get update

    apt-get install -y \
        ca-certificates \
        curl \
        gnupg

    # --------------------------------------------------
    # Remove old Docker repository & GPG key
    # --------------------------------------------------
    rm -f /etc/apt/sources.list.d/docker*.list
    rm -f /etc/apt/keyrings/docker.gpg

    # --------------------------------------------------
    # Docker GPG Key
    # --------------------------------------------------
    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL "https://download.docker.com/linux/${DOCKER_REPO}/gpg" \
        | gpg --dearmor \
        -o /etc/apt/keyrings/docker.gpg

    chmod a+r /etc/apt/keyrings/docker.gpg

    # --------------------------------------------------
    # Docker Repository
    # --------------------------------------------------
    cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DOCKER_REPO} ${VERSION_CODENAME} stable
EOF

    apt-get update

    # --------------------------------------------------
    # Install Docker CE
    # --------------------------------------------------
    apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    # --------------------------------------------------
    # Enable and start Docker (systemd only)
    # --------------------------------------------------
    if command_exists systemctl && \
       [[ "$(ps -p 1 -o comm=)" == "systemd" ]]; then

        systemctl enable docker
        systemctl start docker

    else
        warning "Systemd not detected. Skipping Docker service startup."
    fi

    # --------------------------------------------------
    # Verify installation
    # --------------------------------------------------
    if ! docker --version >/dev/null 2>&1; then
        error "Docker installation failed."
        exit 1
    fi

    if ! docker compose version >/dev/null 2>&1; then
        error "Docker Compose installation failed."
        exit 1
    fi

    success "Docker installed successfully."
}