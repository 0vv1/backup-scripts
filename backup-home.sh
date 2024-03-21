#!/bin/sh
# file:    backup-home.sh
# brief:   writes the content of the home directory to a given location
# author:  (c) 2013 - 2021 Alexander Puls <https://0vv1.io>
# license: GPL v3 <https://opensource.org/licenses/GPL-3.0>
# -----------------------------------------------------------------------------
if [ -z "${BAK_DIR}" ] ; then
    if [ -z "${1}" ] ; then
        printf "no backup directory path supplied\n"
        printf "(either set \033[0;33m\BAK_DIR\033[0m"
        printf " or supply as an argument)\n"
        printf "\033[31mexiting\033[0m\n"
        printf "press \033[0;34mRETURN\033[0m"
        read -r REPLY
        exit 6
    else
        BAK_DIR="${1}"
    fi
fi

BAK_EXCLUDE="${XDG_DOCUMENTS_DIR}/listen/bak-excludes.txt"

if [ -w "${BAK_DIR}" ] ; then
    printf "processing backup from \033[0;33m%s\033[0m"     "${HOME}"
    printf " to \033[0;33m%s \033[0m\033[0;5m..\033[0m "    "${BAK_DIR}"
    tar --directory "${HOME}" --exclude-from="${BAK_EXCLUDE}" --create --gzip \
        --owner=26378 --group=26378 --preserve-permissions . |
        gpg --batch --pinentry-mode loopback \
            --passphrase-file "${KEY_DIR}"/backup \
            --symmetric > "${BAK_DIR}"/"$(date +%Y-%m-%d)".tar.gz.gpg.bak
        sync
    printf "\b\b\b\033[0;32mdone\033[0m\n"
else
    printf "destination not writable\n"
    printf "\033[31mexiting\033[0m\n"
    printf "press \033[0;34mRETURN\033[0m"
    read -r REPLY
    exit 6
fi

exit 0

# $HOME/.local/bin/backup-home.sh ---------------------------------------------
