#!/usr/bin/env bash

#===
# root-certs.sh: Manage any custom root certificates if they exist.
# See shell coding standards for details of formatting.
# https://github.com/fieldsets/fieldsets/blob/main/docs/developer/coding-standards/shell.md
#
# @envvar VERSION | String
# @envvar ENVIRONMENT | String
#
#===

set -eEa -o pipefail

#===
# Variables
#===
CERTS_DIR=${1}

#===
# Functions
#===

##
# manage: Manage our certificates.
##
manage() {

    echo "Managing root certificates...."
    local f
    local certcount
    if [[ -e ${CERTS_DIR} ]]; then
        certcount=$(ls -1q ${CERTS_DIR}/*.crt | wc -l);
        if [[ certcount -eq 1 ]]; then
            mkdir -p /root/.certs
            for f in ${CERTS_DIR}*.crt; do
                if [ -f "${f}" ]; then
                    echo "Installing Root Certificate: ${f}"
                    cp "$f" "/root/.certs/ca-certificate.crt"
                    openssl x509 -in "${f}" -out "/root/.certs/ca-certificate.pem" -outform PEM
                    cp "${f}" "/usr/local/share/ca-certificates/ca-certificate.crt"
                    chmod 664 "/usr/local/share/ca-certificates/ca-certificate.crt"
                    cp "${f}" "/etc/ssl/certs/ca-certificate.crt"
                    chmod 664 "/etc/ssl/certs/ca-certificate.crt"
                    cp "${f}" "$(openssl version -d | cut -f2 -d \")/certs/ca-certificate.crt"
                    echo "ca_certificate=/root/.certs/ca-certificate.pem" >> /root/.wgetrc
                    echo "cacert=/root/.certs/ca-certificate.pem" >> /root/.curlrc
                    update-ca-certificates --fresh
                    pip3 config set global.cert /root/.certs
                    git config --global http.sslcainfo /root/.certs/ca-certificate.pem
                fi
            done
        elif [[ certcount -gt 1 ]]; then
            echo "The directory contains more than 1 root certificate. Please Bundle them."
            return 1
        else
            echo "No Root Certificates Found."
            return 0
        fi
    else
        echo "No Root Certificates Found."
        return 0
    fi

    echo "Root Certificate Setup Complete."
    return 0
}

#===
# Main
#===
manage