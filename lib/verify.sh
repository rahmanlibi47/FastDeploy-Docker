#!/usr/bin/env bash

verify_deployment() {

    step "Verifying Deployment"

    cd "$APP_PATH"

    info "Checking Docker service..."

    systemctl is-active --quiet docker \
        || { error "Docker service is not running."; exit 1; }

    info "Checking running containers..."

    docker compose ps

    FAILED=$(docker compose ps --status exited --quiet)

    if [[ -n "$FAILED" ]]; then
        error "One or more containers exited unexpectedly."
        docker compose logs
        exit 1
    fi

    success "All containers are running."

    info "Checking Nginx..."

    nginx -t

    success "Nginx configuration is valid."

    echo
    echo "========================================"
    echo " Deployment Successful"
    echo "========================================"
    echo
    echo "Application : $APP_NAME"
    echo "Repository  : $APP_REPO"
    echo "Location    : $APP_PATH"
    echo "Domain      : $DOMAIN"
    echo
}