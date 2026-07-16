#!/usr/bin/env bash

configure_ssl() {

    step "Configuring SSL"

    if [[ -z "${DOMAIN:-}" ]] || [[ -z "${EMAIL:-}" ]]; then
        warning "DOMAIN or EMAIL not configured. Skipping SSL."
        return
    fi

    if ! command_exists certbot; then
        info "Installing Certbot..."

        apt-get update

        apt-get install -y \
            certbot \
            python3-certbot-nginx
    fi

    info "Obtaining SSL certificate..."

    certbot \
        --nginx \
        --non-interactive \
        --agree-tos \
        --redirect \
        --email "$EMAIL" \
        -d "$DOMAIN"

    success "SSL configured successfully."
}