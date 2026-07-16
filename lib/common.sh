#!/usr/bin/env bash

set -euo pipefail

########################################
# Colors
########################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

########################################
# Logging
########################################

banner() {
    echo
    echo "========================================"
    echo "      FastDeploy Docker"
    echo "========================================"
    echo
}

step() {
    echo
    echo -e "${BLUE}==> $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

########################################
# Root Check
########################################

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        error "Please run this script using sudo."
        exit 1
    fi
}

########################################
# Command Check
########################################

command_exists() {
    command -v "$1" >/dev/null 2>&1
}