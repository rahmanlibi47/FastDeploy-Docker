#!/usr/bin/env bash

registry_login() {

    step "Registry Authentication"

    if [[ -z "${REGISTRY_USERNAME:-}" ]] || [[ -z "${REGISTRY_PASSWORD:-}" ]]; then
        info "No registry credentials configured. Skipping login."
        return
    fi

    local REGISTRY_URL

    REGISTRY_URL=$(grep -m1 "image:" "$APP_PATH/docker-compose.yml" \
        | awk '{print $2}' \
        | cut -d'/' -f1)

    info "Logging into $REGISTRY_URL..."

    echo "$REGISTRY_PASSWORD" | docker login \
        "$REGISTRY_URL" \
        --username "$REGISTRY_USERNAME" \
        --password-stdin

    success "Registry login successful."
}