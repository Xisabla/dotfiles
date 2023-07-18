#!/usr/bin/env bash

#
# A linux tool to create and manage proxy profiles.
#
# The primary purpose of this tool is to allow to easily switch between
# different proxies. Then it allows to create proxy profiles through
# `proxy create` and to switch to create profile through `proxy set`.
# It is also possible to delete old profiles with `proxy delete` and
# to list all avalaible profiles with `proxy list`.
#
# As different profiles may need to define only some specific proxy variables
# or trigger services or have any other secondary purpose this tool also allow
# to customize the created profiles with `proxy edit`.
#
# This tools also offers the possibility to check easily if a proxy is enabled
# or not by looking through the environment variables and listing their
# content with `proxy status`.
#
# For a detailed usage: `proxy help`.
#
# As `export` method doesn't work into normal script, it is necessary to source
# this file (`source proxy.sh`) to make it work or to copy/paste its content
# to your .bashrc, .zshrc, or .whateverrc.
#
# Local configuration (proxy profiles, default values, templates file) are
# store where $PXY_CONFIG_DIR is pointing to, default value is
# "$HOME/.config/pxy" but this value will be overwritten if $PXY_CONFIG_DIR
# is defined somewhere else in your environment variables before the script
# runs.
#
# Copyright (c) 2021 MIQUET Gautier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# - CONFIGURATION -------------------------------------------------------------

PXY_CONFIG_DIR="${PXY_CONFIG_DIR:-${HOME}/.config/pxy}"
PXY_CONFIG_FILE="${PXY_CONFIG_FILE:-${PXY_CONFIG_DIR}/proxy.conf}"
PXY_PROFILES_DIR="${PXY_PROFILES_DIR:-${PXY_CONFIG_DIR}/profiles}"
PXY_TEMPLATES_DIR="${PXY_TEMPLATES_DIR:-${PXY_CONFIG_DIR}/templates}"
PXY_VERSION="1.0.4"

# Set default config
_PXY_DEFAULT_EDITOR="vim"
_PXY_DEFAULT_PROXY="localhost:3128"
_PXY_DEFAULT_NO_PROXY="localhost,127.0.0.1"

# Ensure needed dirs
[[ ! -d "${PXY_CONFIG_DIR}" ]] && mkdir -p "${PXY_CONFIG_DIR}"
[[ ! -d "${PXY_PROFILES_DIR}" ]] && mkdir -p "${PXY_PROFILES_DIR}"
[[ ! -d "${PXY_TEMPLATES_DIR}" ]] && mkdir -p "${PXY_TEMPLATES_DIR}"

# Read config file or create it if it doens't exist
if [ -f "${PXY_CONFIG_FILE}" ]; then
    while IFS="=" read -r key value; do
        case "$key" in
            "DEFAULT_EDITOR") _PXY_DEFAULT_EDITOR="${value}" ;;
            "DEFAULT_PROXY") _PXY_DEFAULT_PROXY="${value}" ;;
            "DEFAULT_NO_PROXY") _PXY_DEFAULT_NO_PROXY="${value}" ;;
        esac
    done < "${PXY_CONFIG_FILE}"
else
    cat <<EOF > "${PXY_CONFIG_FILE}"
DEFAULT_EDITOR=${_PXY_DEFAULT_EDITOR}
DEFAULT_PROXY=${_PXY_DEFAULT_PROXY}
DEFAULT_NO_PROXY=${_PXY_DEFAULT_NO_PROXY}
EOF
fi

# - TEMLPATES -----------------------------------------------------------------

# - TEMLPATES/unset -----------------------------------------------------------

if [ ! -f "${PXY_TEMPLATES_DIR}/unset" ]; then
    cat <<EOF > "${PXY_TEMPLATES_DIR}/unset"
# Generated unset script

# http/https
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY

# ftp/ftps
unset ftp_proxy
unset ftps_proxy
unset FTP_PROXY
unset FTPS_PROXY

# no proxy
unset no_proxy

# Custom definitions
# systemctl stop my-running-proxy-service
EOF

    chmod +x "${PXY_TEMPLATES_DIR}/unset"
fi

# - TEMLPATES/status ----------------------------------------------------------

if [ ! -f "${PXY_TEMPLATES_DIR}/status" ]; then
    cat <<EOF > "${PXY_TEMPLATES_DIR}/status"
# Generated status script

# Check global status
[ -z "\$http_proxy" ] && [ -z "\$HTTP_PROXY" ] && [ -z "\$https_proxy" ] && [ -z "\$HTTPS_PROXY" ] && \
printf "\n> Proxy is disabled\n\n"
[ -n "\$http_proxy" ] && [ -n "\$HTTP_PROXY" ] && [ -n "\$https_proxy" ] && [ -n "\$HTTPS_PROXY" ] && \
printf "\n> Proxy is enabled\n\n"

# Print all variables status
[ -z "\$http_proxy" ] && echo " - http_proxy is not set" || echo " - http_proxy is set to \"\$http_proxy\""
[ -z "\$HTTP_PROXY" ] && echo " - HTTP_PROXY is not set" || echo " - HTTP_PROXY is set to \"\$HTTP_PROXY\""
[ -z "\$https_proxy" ] && echo " - https_proxy is not set" || echo " - https_proxy is set to \"\$https_proxy\""
[ -z "\$HTTPS_PROXY" ] && echo " - HTTPS_PROXY is not set" || echo " - HTTPS_PROXY is set to \"\$HTTPS_PROXY\""
[ -z "\$no_proxy" ] && echo " - no_proxy is not set" || echo " - no_proxy is set to \"\$no_proxy\""

# Custom definitions
# systemctl show docker | grep 'Environment=HTTP_PROXY=[0-9a-zA-Z:/.-_ ]*' > /dev/null && echo " - Docker proxy service is running"
EOF

    chmod +x "${PXY_TEMPLATES_DIR}/status"
fi

# - TEMLPATES/profile ---------------------------------------------------------

if [ ! -f "${PXY_TEMPLATES_DIR}/profile" ]; then
    cat <<EOF > "${PXY_TEMPLATES_DIR}/profile"
# Generated proxy profile: "{{profile}}"

# http/https
export http_proxy="{{proxy}}"
export https_proxy="{{proxy}}"
export HTTP_PROXY="{{proxy}}"
export HTTPS_PROXY="{{proxy}}"

# ftp/ftps
export ftp_proxy="{{proxy}}"
export ftps_proxy="{{proxy}}"
export FTP_PROXY="{{proxy}}"
export FTPS_PROXY="{{proxy}}"

# no proxy
export no_proxy="{{no_proxy}}"

# Custom definitions
# export no_proxy="\${no_proxy},192.168.0.1"
EOF

    chmod +x "${PXY_TEMPLATES_DIR}/profile"
fi

# - SCRIPTS -------------------------------------------------------------------

if [ ! -f "${PXY_CONFIG_DIR}/unset" ]; then
    ln -s "${PXY_TEMPLATES_DIR}/unset" "${PXY_CONFIG_DIR}/unset"
    chmod +x "${PXY_CONFIG_DIR}/unset"
fi

if [ ! -f "${PXY_CONFIG_DIR}/status" ]; then
    ln -s "${PXY_TEMPLATES_DIR}/status" "${PXY_CONFIG_DIR}/status"
    chmod +x "${PXY_CONFIG_DIR}/status"
fi

# - FUNCTIONS -----------------------------------------------------------------

#######################################
# Show proxy command usage
# GLOBALS:
#   PXY_VERSION
#   PXY_CONFIG_DIR
#   PXY_CONFIG_FILE
#   PXY_PROFILES_DIR
#   PXY_TEMPLATES_DIR
#   EDITOR
#
# ARGUMENTS:
#   Current script name
#
# OUTPUTS:
#   Write usage to stdout
#
# RETURN:
#   0
#######################################
function _pxy_usage() {
    EDITOR="${EDITOR:-${_PXY_DEFAULT_EDITOR}}"

    printf "\n    pxy - proxy v%s\n" "${PXY_VERSION}"
    printf "\nA small utily to manage proxy profiles easily\n\n"
    echo "  proxy create <name> [proxy]         Create a proxy profile"
    echo "    (aliases: add, new)"
    echo "  proxy delete <name>                 Delete a proxy profile"
    echo "    (aliases: remove)"
    echo "  proxy edit <name>                   Edit a proxy profile (open with EDITOR (${EDITOR}) program)"
    echo "    (aliases: modify)"
    echo "  proxy set <name>                    Set proxy to the given profile"
    echo "    (aliases: use)"
    echo "  proxy unset                         Unset proxy variable and services"
    echo "    (aliases: clear, off)"
    echo "  proxy list                          List all available profiles"
    echo "    (aliases: ls)"
    echo "  proxy status                        Get proxy status"
    echo "  proxy autorun [(off|set <name>)]    See or set a profile to load by default"
    echo "    (aliases: auto)"
    echo "  proxy help                          Show this help"
    printf "\n  VARIABLES\n\n"
    echo "PXY_CONFIG_DIR    ${PXY_CONFIG_DIR}"
    echo "PXY_CONFIG_FILE   ${PXY_CONFIG_FILE}"
    echo "PXY_PROFILES_DIR  ${PXY_PROFILES_DIR}"
    echo "PXY_TEMPLATES_DIR ${PXY_TEMPLATES_DIR}"

    return 0
}

#######################################
# Create a new proxy profile
# GLOBALS:
#   PXY_PROFILES_DIR
#   PXY_TEMPLATES_DIR
#   _PXY_DEFAULT_NO_PROXY
#
# ARGUMENTS:
#   Profile name
#   Profile proxy address
#
# OUTPUTS:
#   File copied to $PXY_PROFILES_DIR/$1
#
# RETURN:
#   0 if the profile has been succesfully created
#   1 if the profile already exist and the user doesn't want to overwrite it
#######################################
function _pxy_new_profile() {
    profile="$1"
    proxy="$2"
    profile_file="${PXY_PROFILES_DIR}/${profile}"
    no_proxy="${_PXY_DEFAULT_NO_PROXY}"

    # Check for already existing profile
    if [ -f "${profile_file}" ]; then
        echo "${profile_file} already exists, overwrite ?"

        select yn in "Yes" "No"; do
            case $yn in
                Yes ) break ;;
                No ) return 1 ;;
            esac
        done
    fi

    # Apply profile from template
    cp -f "${PXY_TEMPLATES_DIR}/profile" "${profile_file}"
    sed -i "s+{{profile}}+${profile}+g" "${profile_file}"
    sed -i "s+{{proxy}}+${proxy}+g" "${profile_file}"
    sed -i "s+{{no_proxy}}+${no_proxy}+g" "${profile_file}"

    echo "Profile \"${profile}\" created."

    return 0
}

#######################################
# Delete an existing proxy profile
# GLOBALS:
#   PXY_PROFILES_DIR
#
# ARGUMENTS:
#   Profile name
#
# OUTPUTS:
#   File $PXY_PROFILES_DIR/$1 removed
#
# RETURN:
#   0
#######################################
function _pxy_delete_profile() {
    profile="$1"
    profile_file="${PXY_PROFILES_DIR}/${profile}"

    # Remove profile file if found
    [[ -f "${profile_file}" ]] && rm -f "${profile_file}"

    echo "Profile \"${profile}\" removed."

    return 0
}

#######################################
# Delete an existing proxy profile
# GLOBALS:
#   PXY_PROFILES_DIR
#   _PXY_DEFAULT_EDITOR
#   EDITOR
#
# ARGUMENTS:
#   Profile name
#
# OUTPUTS:
#   File $PXY_PROFILES_DIR/$1 modified
#
# RETURN:
#   0 if the profile has been succesfully edited
#   1 if the profile doesn't exists and the user doesn't want to create an empty one
#######################################
function _pxy_edit_profile() {
    profile="$1"
    profile_file="${PXY_PROFILES_DIR}/${profile}"

    EDITOR="${EDITOR:-${_PXY_DEFAULT_EDITOR}}"

    # Check if profile exists
    if [ ! -f "${profile_file}" ]; then
        echo "Profile \"${profile}\" not found, create empty profile ?"

        select yn in "Yes" "No"; do
            case $yn in
                Yes ) touch "${profile_file}" ; break ;;
                No ) return 1 ;;
            esac
        done
    fi

    # Open profile file with $EDITOR
    [[ -f "$(which "${EDITOR}")" ]] || [[ -f "${EDITOR}" ]] && $EDITOR "${profile_file}"

    return 0
}

#######################################
# Execute profile instruction
# GLOBALS:
#   PXY_PROFILES_DIR
#
# ARGUMENTS:
#   Profile name
#
# OUTPUTS:
#   File $PXY_PROFILES_DIR/$1 modified
#
# RETURN:
#   0
#######################################
function _pxy_set_profile() {
    profile="$1"
    profile_file="${PXY_PROFILES_DIR}/${profile}"

    # Check if profile exists
    [[ ! -f "${profile_file}" ]] && (echo "Profile ${profile} not found." ; return 1)

    # Run profile script
    source "${profile_file}"

    echo "Now using \"${profile}\" profile."

    return 0
}

#######################################
# Set the autorun profile
# GLOBALS:
#   PXY_CONFIG_DIR
#
# ARGUMENTS:
#   Profile name
#
# OUTPUTS:
#   File $PXY_CONFIG_DIR/autorun modified/created
#
# RETURN:
#   0
#######################################
function _pxy_set_autorun() {
    profile="$1"

    echo "${profile}" > "${PXY_CONFIG_DIR}/autorun"

    return 0
}

#######################################
# Get the current autorun profile
# GLOBALS:
#   PXY_CONFIG_DIR
#
# ARGUMENTS:
#
# OUTPUTS:
#   Write autorun profile to stdout
#
# RETURN:
#   0
#######################################
function _pxy_get_autorun() {
    if [ -f "${PXY_CONFIG_DIR}/autorun" ]; then
        echo "Autorun profile is \"$(cat "${PXY_CONFIG_DIR}/autorun")\""
    else
        echo "No autorun profile set"
    fi

    return 0
}

# - MAIN ----------------------------------------------------------------------

# Create default config if missing
[[ ! -f "${PXY_PROFILES_DIR}/default" ]] && _pxy_new_profile "default" "${_PXY_DEFAULT_PROXY}"

# Trigger autorun if autorun file exists
[[ -f "${PXY_CONFIG_DIR}/autorun" ]] && _pxy_set_profile "$(cat "${PXY_CONFIG_DIR}/autorun")"

#######################################
# Handles user command
# GLOBALS:
#   PXY_CONFIG_DIR
#   PXY_PROFILES_DIR
#   _PXY_DEFAULT_PROXY
#######################################
function pxy {
    # If no argument given, show usage
    if [ "$#" -eq 0 ]; then
        source "${PXY_CONFIG_DIR}/status"
        return 0
    fi

    # Parse main argument
    case "$1" in
        "help" | "-h" | "--help" ) _pxy_usage "$0" ; return 0 ;;

        "create" | "new" | "add" )
            if [ ! "$#" -eq 3 ] && [ ! "$#" -eq 2 ]; then
                echo "Usage: $0 create <name> [proxy]"
                return 1
            fi

            if [ "$#" -eq 3 ]; then
                _pxy_new_profile "$2" "$3"
            else
                _pxy_new_profile "$2" "${_PXY_DEFAULT_PROXY}"
            fi

            return 0 ;;

        "delete" | "remove" )
            if [ ! "$#" -eq 2 ]; then
                echo "Usage: $0 delete <name>"
                return 1
            fi

            _pxy_delete_profile "$2"

            return 0 ;;

        "edit" | "modify" )
            if [ ! "$#" -eq 2 ]; then
                echo "Usage: $0 edit <name>"
                return 1
            fi

            _pxy_edit_profile "$2"

            return 0 ;;

        "set" | "use" )
            if [ ! "$#" -eq 2 ]; then
                echo "Usage: $0 set <name>"
                return 1
            fi

            _pxy_set_profile "$2"

            return 0 ;;

        "unset" | "clear" | "off" )
            if [ ! "$#" -eq 1 ]; then
                echo "Usage: $0 unset"
                return 1
            fi

            source "${PXY_CONFIG_DIR}/unset"

            return 0 ;;

        "list" | "ls" )
            if [ ! "$#" -eq 1 ]; then
                echo "Usage: $0 list"
                return 1
            fi

            ls "${PXY_PROFILES_DIR}" -1 | sed -e 's/^/- /;'

            return 0 ;;

        "autorun" | "auto" )
            if [ "$#" -ge 4 ] || \
                ( ([ "$#" -eq 2 ] && [ ! "$2" = "off" ]) || ([ "$#" -eq 3 ] && [ ! "$2" = "set" ]) ); then
                echo "Usage: autorun"
                echo "       autorun off"
                echo "       autorun set <profile>"

                return 1
            fi

            if [ "$#" -eq 1 ]; then
                _pxy_get_autorun
            fi

            if [ "$#" -eq 2 ]; then
                rm -f "${PXY_CONFIG_DIR}/autorun"
                echo "Autorun removed."
            fi

            if [ "$#" -eq 3 ]; then
                _pxy_set_autorun "$3"
            fi

            return 0 ;;

        "status")
            if [ ! "$#" -eq 1 ]; then
                echo "Usage: $0 status"
                return 1
            fi

            source "${PXY_CONFIG_DIR}/status"

            return 0 ;;

        *) _pxy_usage ; return 1 ;;

    esac

}

# - ALIASES -------------------------------------------------------------------
alias proxy="pxy"
