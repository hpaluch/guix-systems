# Guix builder VM

Goal: to have Git repository mirrors and Builder (to provide binary packages
known as "substitutions") on VM that can be consumed by other (air-gapped)
Guix client VMs...

# Setting up mirrored repositories

Recommended start: using my `clockres` repo - that is small enough to quickly test
NGINX and `git-http-backend` configuration:

To create mirrored repo for `clockres` do this (as regular user):
```shell
mkdir -p ~/mirrors
cd ~/mirrors
git clone --mirror https://github.com/hpaluch-pil/clockres.git
tar cvzf clockres.git.tar.gz ./clockres.git/
sudo tar -xv --no-same-owner -f clockres.git.tar.gz -C /srv/git
sudo touch /srv/git/clockres.git/git-daemon-export-ok
```

To verify that local mirror works, try this (again as regular user on this VM):
```shell
mkdir ~/local-projects
cd ~/local-projects
git clone http://localhost/git/clockres.git
# should work!
```

Note: in case of any errors, try:
```shell
sudo -i herd status fcgiwrap
sudo tail /var/log/fcgiwrap.log
```


Now do same for Guix repository - use prepared script:
```shell
./prepare-guix-mirror.sh
```

