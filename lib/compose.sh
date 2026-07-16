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
    info "Loading deployment configuration..."

    set -a
    source "$SCRIPT_DIR/.env"
    set +a

    # --------------------------------------------------
    # Generate application environment files
    # --------------------------------------------------
    info "Generating environment files..."

    while IFS= read -r example; do

        target="${example%.example}"

        envsubst < "$example" > "$target"

        info "Generated $(realpath --relative-to="$APP_PATH" "$target")"

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