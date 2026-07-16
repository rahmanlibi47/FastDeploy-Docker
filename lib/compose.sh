#!/usr/bin/env bash

compose_up() {

    step "Deploying Application"

    cd "$APP_PATH" || {
        error "Application directory not found: $APP_PATH"
        exit 1
    }

    # --------------------------------------------------
    # Prepare environment files
    # --------------------------------------------------
    info "Preparing environment files..."

    while IFS= read -r example; do

        target="${example%.example}"

        if [[ ! -f "$target" ]]; then
            cp "$example" "$target"
            info "Created $(realpath --relative-to="$APP_PATH" "$target")"
        fi

    done < <(find . -type f -name ".env.docker.example")

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