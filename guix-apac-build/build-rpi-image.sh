#!/usr/bin/env bash
set -xeuo pipefail
# find template
template=$( guix locate raspberry-pi-64.tmpl | head -1 | awk '{print $2}' )
[ -n "$template" -a -f "$template" -a -r "$template" ] || {
	echo "ERROR getting template '$template'" >&2
	exit 1
}
echo "Using template: '$template'"
time guix system image --system=aarch64-linux $template
exit 0
