#!/usr/bin/env bash

clone_repository() {

    step "Cloning Application"

    if ! command_exists git; then
        error "Git is not installed."
        exit 1
    fi

    DEPLOY_USER="${SUDO_USER:-$USER}"
    DEPLOY_HOME="$(eval echo "~$DEPLOY_USER")"

    APP_PATH="$DEPLOY_HOME/$APP_NAME"

    if [[ -d "$APP_PATH/.git" ]]; then
        info "Repository already exists. Updating..."

        git -C "$APP_PATH" fetch origin

        if [[ -n "${APP_BRANCH:-}" ]]; then
            git -C "$APP_PATH" checkout "$APP_BRANCH"
            git -C "$APP_PATH" pull origin "$APP_BRANCH"
        else
            CURRENT_BRANCH=$(git -C "$APP_PATH" branch --show-current)
            git -C "$APP_PATH" pull origin "$CURRENT_BRANCH"
        fi

        success "Repository updated."

    else
        info "Cloning repository..."

        if [[ -n "${APP_BRANCH:-}" ]]; then
            git clone \
                --branch "$APP_BRANCH" \
                "$APP_REPO" \
                "$APP_PATH"
        else
            git clone \
                "$APP_REPO" \
                "$APP_PATH"
        fi

        success "Repository cloned."
    fi

    export APP_PATH
}