#!/usr/bin/env bash

configure_nginx() {

    step "Configuring Nginx"

    if command_exists nginx; then
        info "Nginx already installed."
    else
        apt-get update
        apt-get install -y nginx
    fi

    info "Generating Nginx configuration..."

    envsubst \
        < "$ROOT_DIR/templates/nginx.conf" \
        > "/etc/nginx/sites-available/$APP_NAME"

    ln -sf \
        "/etc/nginx/sites-available/$APP_NAME" \
        "/etc/nginx/sites-enabled/$APP_NAME"

    rm -f /etc/nginx/sites-enabled/default

    info "Validating Nginx configuration..."

    nginx -t || {
        error "Nginx configuration test failed."
        exit 1
    }

    systemctl enable nginx
    systemctl restart nginx || {
        error "Failed to restart Nginx."
        exit 1
    }

    success "Nginx configured successfully."
}