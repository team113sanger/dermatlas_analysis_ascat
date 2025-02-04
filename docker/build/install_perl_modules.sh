#!/bin/bash
# Perl module installation script via cpanminus
# This script installs cpanminus and specified Perl modules.
#
# Run bash install_perl_modules.sh -h for usage information.

set -euo pipefail

# Global constants
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color
readonly CPANM_URL="https://cpanmin.us"
readonly DEFAULT_MODULES=(
    "strict"
    "warnings"
    "Getopt::Long"
    "File::Temp"
    "File::Basename"
)

# Print functions
function print_info() {
    echo -e "${GREEN}INFO: $1${NC}"
}

function print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

# Usage function
function usage() {
    echo "Usage: $0 [-m <MODULE1 MODULE2 ...>] [-h]"
    echo ""
    echo "Install cpanminus and specified Perl modules."
    echo ""
    echo "Options:"
    echo "  -m, --modules:   Space-separated list of Perl modules to install"
    local space_modules=$(IFS=" "; echo "${DEFAULT_MODULES[*]}")
    echo "                   (default: ${space_modules})"
    echo "  -h, --help:      Show this help message"
}

# Check for root privileges
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root or with sudo"
        exit 1
    fi
}

# Parse arguments
function parse_args() {
    MODULES=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--modules)
                shift
                while [[ $# -gt 0 && ! $1 =~ ^- ]]; do
                    MODULES+=("$1")
                    shift
                done
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    if [ ${#MODULES[@]} -eq 0 ]; then
        MODULES=("${DEFAULT_MODULES[@]}")
    fi
}

# Install cpanminus
function install_cpanminus() {
    print_info "Installing cpanminus"
    
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    if [[ ! "$temp_dir" || ! -d "$temp_dir" ]]; then
        print_error "Could not create temp dir"
        return 1
    fi
    
    # Download and install cpanminus
    curl -L "$CPANM_URL" -o "$temp_dir/cpanm_installer" || { print_error "Failed to download cpanminus"; return 1; }
    perl "$temp_dir/cpanm_installer" App::cpanminus || { print_error "Failed to install cpanminus"; return 1; }
    rm -rf "$temp_dir"
    
    print_info "cpanminus installed successfully"
}


# Install Perl modules
function install_modules() {
    local modules=("$@")
    print_info "Installing Perl modules: ${modules[*]}"
    cpanm "${modules[@]}"
    print_info "Perl modules installed successfully"
}

# Main function
function main() {
    install_cpanminus
    install_modules "${MODULES[@]}"
    print_info "All installations completed successfully"
}

# Script execution
parse_args "$@"
check_root
main