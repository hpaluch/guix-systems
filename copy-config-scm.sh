#!/usr/bin/env bash
# copy system-wide /etc/config.scm to this Git repository
set -euo pipefail

errx () { echo "ERROR: $*" >&2; exit 1; }

cd $( dirname $0 )
td=`hostname`

[ -d "$td" ] || errx "Directory '$td' does not exist - do you have proper hostname?"
dst=$td/config.scm
[ -f "$dst" ] || errx "Destination config '$dst' does not exist"
src=/etc/config.scm
[ -r "$src" ] || errx "Unable to read '$src'"

if diff -u $dst $src; then
	echo "INFO: Config files $dst and $src are identical - nothing to do"
else
	echo -n "Copy new config to Git [y/N]? "
	read ans
	case "$ans" in
		[yY]|[yY][eE][sS])
			cp -v $src $dst ;;
		*)	echo "WARN: copy canceled on user request" ;;
	esac
fi
exit 0

