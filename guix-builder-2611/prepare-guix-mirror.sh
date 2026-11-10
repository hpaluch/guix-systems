#!/usr/bin/env bash
# Prepare Guix mirror on builder VM to be served from localhost
set -xeuo pipefail
mkdir -p ~/mirrors
cd ~/mirrors
x=guix.git
git clone --mirror https://codeberg.org/guix/$x
tar cvzf $x.tar.gz $x
sudo tar -xv --no-same-owner -f $x.tar.gz -C /srv/git
sudo touch /srv/git/$x/git-daemon-export-ok
set +x
cat <<EOF
Now try this to verify that local mirror is ready:

mkdir -p ~/local-projects
cd ~/local-projects
git clone http://localhost/git/$x
EOF
exit 0

