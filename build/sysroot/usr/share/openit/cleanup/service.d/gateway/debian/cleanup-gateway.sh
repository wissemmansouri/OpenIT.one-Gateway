#!/bin/bash

set -e

readonly OPEN_EXEC=openit-gateway
readonly OPEN_SERVICE=openit-gateway.service

OPEN_SERVICE_PATH=$(systemctl show ${OPEN_SERVICE} --no-pager  --property FragmentPath | cut -d'=' -sf2)
readonly OPEN_SERVICE_PATH

OPEN_CONF=$( grep -i ConditionFileNotEmpty "${OPEN_SERVICE_PATH}" | cut -d'=' -sf2)
if [[ -z "${OPEN_CONF}" ]]; then
    OPEN_CONF=/etc/openit/gateway.ini
fi

readonly aCOLOUR=(
    '\e[38;5;154m' # green  	| Lines, bullets and separators
    '\e[1m'        # Bold white	| Main descriptions
    '\e[90m'       # Grey		| Credits
    '\e[91m'       # Red		| Update notifications Alert
    '\e[33m'       # Yellow		| Emphasis
)

Show() {
    # OK
    if (($1 == 0)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]}  OK  $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    # FAILED
    elif (($1 == 1)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    # INFO
    elif (($1 == 2)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]} INFO $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    # NOTICE
    elif (($1 == 3)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[4]}NOTICE$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    fi
}

Warn() {
    echo -e "${aCOLOUR[3]}$1$COLOUR_RESET"
}

trap 'onCtrlC' INT
onCtrlC() {
    echo -e "${COLOUR_RESET}"
    exit 1
}

if [[ ! -x "$(command -v ${OPEN_EXEC})" ]]; then
    Show 2 "${OPEN_EXEC} is not detected, exit the script."
    exit 1
fi

Show 2 "Stopping ${OPEN_SERVICE}..."
systemctl disable --now "${OPEN_SERVICE}" || Show 3 "Failed to disable ${OPEN_SERVICE}"

rm -rvf "$(which ${OPEN_EXEC})" || Show 3 "Failed to remove ${OPEN_EXEC}"
rm -rvf "${OPEN_CONF}" || Show 3 "Failed to remove ${OPEN_CONF}"

rm -rvf /var/run/openit/gateway.pid
rm -rvf /var/run/openit/management.url
rm -rvf /var/run/openit/routes.json
rm -rvf /var/run/openit/static.url
rm -rvf /var/lib/openit/www
