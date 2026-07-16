#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT_DIR/.env"

# --------------------------------------------------
# Load Environment
# --------------------------------------------------

if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ .env file not found."
    echo "Copy .env.example to .env and update the values."
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

# --------------------------------------------------
# Load Libraries
# --------------------------------------------------

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/docker.sh"
source "$ROOT_DIR/lib/git.sh"
source "$ROOT_DIR/lib/registry.sh"
source "$ROOT_DIR/lib/compose.sh"
source "$ROOT_DIR/lib/nginx.sh"
source "$ROOT_DIR/lib/ssl.sh"
source "$ROOT_DIR/lib/verify.sh"

# --------------------------------------------------
# Deployment
# --------------------------------------------------

banner

require_root

install_docker
clone_repository
registry_login
compose_up
configure_nginx
configure_ssl
verify_deployment

success "Deployment completed successfully!"