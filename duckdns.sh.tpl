#!/usr/bin/env bash

LOGFILE="/tmp/duckdns.log"

echo -n "$(date --rfc-3339=seconds) " > "${LOGFILE}"
echo url="https://www.duckdns.org/update?domains=home-attilaolah-eu&token={{token}}&ip=" \
    | curl -k -o - -K - \
    >> "${LOGFILE}"
echo >> "${LOGFILE}"
