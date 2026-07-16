#!/usr/bin/env bash

compose_up() {

    step "Deploying Application"

    cd "$APP_PATH" || {
        error "Application directory not found: $APP_PATH"
        exit 1
    }

    # --------------------------------------------------
    # Load FastDeploy environment
    # --------------------------------------------------
    set -a
    source "$ROOT_DIR/.env"
    set +a

    info "Current directory: $(pwd)"
    info "APP_PATH: $APP_PATH"

    echo
    echo "========== FastDeploy Environment =========="
    echo "AUTH_SECRET_KEY=$AUTH_SECRET_KEY"
    echo "SECRET_KEY=$SECRET_KEY"
    echo "AUTH_ALGORITHM=$AUTH_ALGORITHM"
    echo "==========================================="
    echo

    # --------------------------------------------------
    # Locate templates
    # --------------------------------------------------
    info "Searching for .env.docker.example files..."

    find . -type f -name ".env.docker.example"

    echo

    # --------------------------------------------------
    # Generate application environment files
    # --------------------------------------------------
    info "Generating environment files..."

    while IFS= read -r example; do

    echo "Example: $example"

    target="${example%.example}"

    echo "Target : $target"

    envsubst < "$example" > "$target"

    echo "Exit code: $?"

    ls -l "$target"

    done < <(find . -type f -name ".env.docker.example")

    echo
    info "Generated environment files:"
    find . -type f -name ".env.docker"
    echo

    # --------------------------------------------------
    # Pull latest images
    # --------------------------------------------------
    info "Pulling latest images..."

    docker compose pull || {
        error "Failed to pull Docker images."
        exit 1
    }

    # --------------------------------------------------
    # Start containers
    # --------------------------------------------------
    info "Starting containers..."

    docker compose up -d || {
        error "Failed to start Docker containers."
        exit 1
    }

    success "Application deployed successfully."
}