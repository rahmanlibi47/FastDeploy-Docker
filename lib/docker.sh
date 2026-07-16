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
    # Remove Ubuntu Docker if present
    # --------------------------------------------------
    if dpkg -s docker.io >/dev/null 2>&1; then
        warning "Ubuntu Docker (docker.io) detected."
        info "Replacing with Docker CE..."

        apt-get purge -y docker.io
        apt-get autoremove -y
    fi

    # --------------------------------------------------
    # Install prerequisites
    # --------------------------------------------------
    apt-get update

    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # --------------------------------------------------
    # Add Docker GPG Key
    # --------------------------------------------------
    install -m 0755 -d /etc/apt/keyrings

    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    # --------------------------------------------------
    # Add Docker Repository
    # --------------------------------------------------
    if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then

        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list

    fi

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
    # Enable Docker (Only if systemd is available)
    # --------------------------------------------------
    if command_exists systemctl && \
       [[ "$(ps -p 1 -o comm=)" == "systemd" ]]; then

        systemctl enable docker
        systemctl start docker

    else
        warning "Systemd not detected. Skipping Docker service startup."
    fi

    success "Docker CE installed successfully."
}