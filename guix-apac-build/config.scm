;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.

;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu)
             (gnu packages admin)
             (gnu packages databases)
             (guix modules))
(use-service-modules cuirass
                     cups
                     databases
                     desktop
                     networking
                     ssh
                     version-control
                     virtualization
                     web
                     xorg)

(define index-html-content
  (plain-file "index.html" "<h1>Welcome to Guix!</h1>
<p>Go to Git <a href='/git/'>/git/</a>
"))

(define index-html-activation
  (with-imported-modules (source-module-closure '((gnu build activation)))
                         #~(begin
                             (use-modules (gnu build activation))
                             (mkdir-p/perms "/srv/http"
                                            (getpwnam "root") 493)
                             (copy-file #$index-html-content
                                        "/srv/http/index.html"))))

(define index-html-service-type
  (service-type (name 'index-html)
                (extensions (list (service-extension activation-service-type
                                                     (const
                                                      index-html-activation))))
                (default-value #t)
                (description "Generate main index.html for nginx")))

;; based on: cuirass source examples
(define my-cuirass-specs
  #~(list (specification (name 'guix)
                         (build 'hello)
                         ;; from: maintenance/hydra/modules/sysadmin/services.scm
                         (channels (list (channel
                                           (inherit %default-guix-channel)
                                           ;; replace codeberg git repo with my localhost mirror
                                           (url
                                            "http://localhost/git/guix.git"))))
                         (priority 2)
                         (systems '("x86_64-linux")))))

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Berlin")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "guix-apac-build")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "ansible")
                  (comment "Ansible")
                  (group "users")
                  (home-directory "/home/ansible")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
   (append (list

                 ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
                 (service dhcpcd-service-type)

                 ;; create master /srv/http/index.html file for nginx
                 (service index-html-service-type)
                 ;; serve /srv/git over http
                 ;; 1st part: FastCGI backend
                 (service fcgiwrap-service-type)
                 ;; 2nd part: nginx configuration
                 ;; source: https://guix.gnu.org/manual/1.5.0/en/html_node/Version-Control-Services.html
                 (service nginx-service-type
                          (nginx-configuration (server-blocks (list (nginx-server-configuration
                                                                     (listen '
                                                                             ("80"))
                                                                     (server-name '
                                                                      ("guix-apac-build.example.com"))
                                                                     (locations
                                                                      (list (git-http-nginx-location-configuration
                                                                             (git-http-configuration
                                                                              (uri-path
                                                                               "/git"))))))))))
                 ;; from guix/gnu/tests/containers.scm
                 (service postgresql-service-type
                          (postgresql-configuration (postgresql postgresql)))
                 ;; from https://gofranz.com/blog/a-tiny-guix-build-farm-on-a-thinkpad/
                 (service cuirass-service-type
                          (cuirass-configuration (specifications
                                                  my-cuirass-specs)
                                                 (host "127.0.0.1")
                                                 (fallback? #t)))
                 (service guix-publish-service-type
                          (guix-publish-configuration (host "127.0.0.1")
                                                      (port 3000)
                                                      (compression '(("zstd"
                                                                      19)))
                                                      (cache
                                                       "/var/cache/publish")
                                                      (ttl (* 90 24 3600))))

                 ;; qemu-user to cross-build RPi image
                 (service qemu-binfmt-service-type
                          (qemu-binfmt-configuration (platforms (lookup-qemu-platforms
                                                                 "arm"
                                                                 "aarch64")))))
           (modify-services (cons (service elogind-service-type)
                                  %base-services)
             (elogind-service-type config =>
                                   (elogind-configuration (inherit config)
                                                          (idle-action 'ignore)))
             ;; (delete gdm-service-type)
             )))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid "a25a5b02-d16f-4436-bd68-df3e7e2a4164")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "5725-303C"
                                       'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (options "compress=zstd:3")
                         (device (uuid "65cf35e3-5b47-4172-b2db-e1f802d4fc4a"
                                       'btrfs))
                         (type "btrfs")) %base-file-systems)))
