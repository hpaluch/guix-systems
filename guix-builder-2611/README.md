# Guix builder VM

VM to build locally Guix binary packages (known as "substitutions").

To do that you need several services as shown in [config.scm](config.scm):
```scheme
;; generates index.html landing page
(service index-html-service-type)
;; serve /srv/git over http (for git clone over http)
;; 1st part: FastCGI backend
(service fcgiwrap-service-type)
;; nginx - serves git repositories over http (public on port 80)
(service nginx-service-type ...)
;; postgresql database - required by cuirass (or worker?)
(service postgresql-service-type
;; cuirass (build server for Guix), listening on localhost:8081 (I use ssh tunnel to access)
(service cuirass-service-type ...)
;; publisher - generates package metadata (known as "nar") - consumed by Guix client
;; listening on localhost:3000 (I use ssh tunnel to access)
(service guix-publish-service-type ...)
```

# Setting up mirrored repositories

Recommended: prepare my `clockres` repo - that is small enough to quickly test
NGINX and `git-http-backend` configuration:

To create mirrored repo for `clockres` run as regular user:
```shell
./prepare-clockres-mirror.sh
```

To verify that local mirror works, try this (again as regular user on this VM):
```shell
mkdir ~/local-projects
cd ~/local-projects

# WARNING! Command below will work only after reconfigure/reboot!
git clone http://localhost/git/clockres.git
```

Additionally you have to prepare local Guix mirror (consumed by my Cuirass server):
```shell
./prepare-guix-mirror.sh

# WARNING! Command below will work only after reconfigure/reboot!
git clone http://localhost/git/guix.git
```

# Prepare system

Merge provided [config.scm](config.scm) then issue:
```shell
sudo -i guix system reconfigure /etc/config.scm
sudo reboot
```

Note: after reboot the system will be eating CPU - setting up database
and Cuirass for 1st use.

You should watch logfile `/var/log/cuirass.log` until you see message
like:
```
evaluation 1 of jobset 'guix' registered 1 builds
building 1 derivations in batches of 200
building batch of 200 derivations (0/1)
done with 1 derivations
outputs:
/gnu/store/z41alj60i5a0jvbl56s0nj4h6gnrwn5v-hello-2.12.3
```

You can also watch progress on http://localhost:8081

WARNING! There will be always `error` status until 1st build is finished! Be patient!

Note: in case of any errors, try:
```shell
sudo -i herd status fcgiwrap
sudo tail /var/log/fcgiwrap.log
```

Now do same for Guix repository - use prepared script:
```shell
./prepare-guix-mirror.sh
```

