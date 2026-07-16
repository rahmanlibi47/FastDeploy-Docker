#!/usr/bin/env bash

configure_nginx() {

    step "Configuring Nginx"

    if command_exists nginx; then
        info "Nginx already installed."
    else
        apt-get update
        apt-get install -y nginx
    fi

    if [[ "${SSL_ENABLED}" == "true" ]]; then
        info "Generating HTTPS Nginx configuration..."
        TEMPLATE="$ROOT_DIR/templates/nginx-ssl.conf"
        ENV_VARS='${DOMAIN} ${FRONTEND_PORT} ${AUTH_PORT} ${APPLICATION_PORT}'
    else
        info "Generating HTTP Nginx configuration..."
        TEMPLATE="$ROOT_DIR/templates/nginx.conf"
        ENV_VARS='${DOMAIN} ${FRONTEND_PORT} ${AUTH_PORT} ${APPLICATION_PORT}'
    fi

    envsubst "$ENV_VARS" \
        < "$TEMPLATE" \
        > "/etc/nginx/sites-available/$APP_NAME"

    ln -sf \
        "/etc/nginx/sites-available/$APP_NAME" \
        "/etc/nginx/sites-enabled/$APP_NAME"

    rm -f /etc/nginx/sites-enabled/default

    nginx -t || {
        error "Nginx configuration test failed."
        exit 1
    }

    systemctl enable nginx
    systemctl restart nginx || {
        error "Failed to restart Nginx."
        exit 1
    }

    success "Nginx configured."
}