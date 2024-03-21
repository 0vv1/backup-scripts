#!/bin/sh
# file:    $HOME/.local/bin/backup-pwd.sh
# brief:   Writes Whitelisted Content (Either
#          with Absolute Path or Relative to $PWD)
#          Encrypted to a Selectable Location
# author:  (c) 2013-2024 Alexander Puls
#          <https://git.0vv1.net/backup-scripts/>
# license: GPL v3 <https://0vv1.net/gpl.v3.txt>
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

# variables ______________________________________
if [ -z "${BAK_DIR}" ] && [ -z "${1}" ] ;then
	# no variable has non-zero length (AKA empty)?
	printf "\n"
	printf "no backup directory path supplied\n\n"
	printf "(either set "
	printf "\033[0;33m\$BAK_DIR\033[0m or \n"
	printf "supply a path as an argument)\n\n"
	printf "\033[5;31mexiting\033[0m with "
	printf "code \033[0;31m6\033[0m (error)\n\n"
	printf "press \033[1;34mRETURN\033[0m: "
	read -r REPLY
	exit 6

elif [ -n "${1}" ]; then
	
	# check if we already had a pre-set path
	if [ -n "${BAK_DIR}" ]; then
		PRE_SET='true'; fi

	# always choose CLI parameter over pre-set
	BAK_DIR=${1}; fi

PHRS="${SEC_DIR}/keys.priv/2024-03-01_backup.key"
DATE="$(date +%Y-%m-%d)"
FLDR="$(basename "$PWD")"
TRGT="${BAK_DIR}/${DATE}_${FLDR}_bak.tar.gz.asc"
#TRGT="${BAK_DIR}/${DATE}_${FLDR}_bak.tar.gz.gpg"

# check if path is available and
# provide an opening message _____________________
if [ -w "${BAK_DIR}" ]; then
	printf "\n"
	if [ "${PRE_SET}" = true ]; then
		printf "provided path is chosen over "
		printf "pre-set variable "
		printf "\033[32m\$BAK_DIR\033[0m:\n\n"; fi

	printf "processing backup from "
	printf "\033[0;33m%s\033[0m"     "${PWD}"
	printf " to "
	printf "\033[0;33m%s/\033[0m "   "${BAK_DIR}"
	printf "\033[0;5m..\033[0m\n\n"

	# packing whitelisted data ______
	tar cf - \
		"./.profile"                \
		"./.davfs2/"                \
		"./.gnupg/"                 \
		"./.local/bin/"             \
		"./.config/"                \
		"./.local/etc/"             \
		"./.local/lib/"             \
		"./.local/share/"           \
		"./.local/var/log/"         \
		"./.mozilla/"               \
		"./.ssh/"                   \
		"./.themes/"                \
		"./.thunderbird/"           \
		"./.vim/"                   \
		"./audio/"                  \
		"./docs/"                   \
		"./pics/"                   \
		"./tx/0vv1.net.sshfs/"      \
		"./tx/docs-mobile.sync/"    \
		"./tx/WhatsApp.sync/"       \
		"./vc/"                     \
		"./work"                    |

	# compressing
	gzip --best                     |

	# encrypting (opt.: signed with
	# a GPG key or output in ASCII)
	gpg \
		--armor                     \
		--batch                     \
		--passphrase-file "${PHRS}" \
		--sign                      \
		--symmetric > "${TRGT}"

	sync

	# success message + code 0 ____
	printf "\n"
	printf "\033[0;32mDONE\033[0m "
	printf "(code %s)" "${?}"
	exit 0

else
	# error catching if path is invalid ______
	printf "\n"
	printf "destination is not writable\n\n"
	printf "\033[5;31mexiting\033[0m with "
	printf "code \033[31m6\033[0m (error)\n\n"
	printf "press \033[34mRETURN\033[0m: "
	read -r REPLY; 
	exit 6; fi

# EOF backup-pwd.sh #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

