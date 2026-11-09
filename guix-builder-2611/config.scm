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
             (gnu packages fonts)
             (gnu packages xorg)
             (guix gexp)
             (guix modules)
             (ice-9 match)
             (srfi srfi-1))
(use-service-modules auditd
                     cups
                     desktop
                     networking
                     ssh
                     version-control
                     web
                     xorg)

;; FIXME: %default-issue is not exported from (gnu system)...
;; copied from guix/gnu/system.scm and renamed from %default-issue to %default-issue-copy
;; to avoid future conflict (if it will become exported)
(define %default-issue-copy
  ;; Default contents for /etc/issue.
  "
      This is the GNU system.  Welcome.
")

;; custom console font, grabbed from gnu/services/base.scm and fixed
;; Note: original package font-gnu-unifont contains only single font: /share/consolefonts/Unifont-APL8x16.psf.gz
;; so we have to use 'console-setup' package from (gnu packages xorg)
(define %my-console-font
  #~(string-append #+console-setup "/share/consolefonts/Uni1-VGA16.psf.gz"))

(define index-html-content
  (plain-file "index.html" "<h1>Welcome to Guix!</h1>
		 <p>Go to Git <a href='/git/'>/git/<a/>
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

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Berlin")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "guix-builder-2611")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "ansible")
                  (comment "Ansible")
                  (group "users")
                  (home-directory "/home/ansible")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))
  ;; FIXME: I wanted to print IP address, but mingetty does not support that...
  (issue (string-append %default-issue-copy "\nKernel: \\r \\v on \\m\n\n"))
  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
   (append (list
            ;; To configure OpenSSH, pass an 'openssh-configuration'
            ;; record as a second argument to 'service' below.
            (service openssh-service-type)
            (service dhcpcd-service-type)
            ;; Guix Home depends on elogind
            (service elogind-service-type)
            (service auditd-service-type)
            ;; create master /srv/http/index.html file for nginx
            (service index-html-service-type)
            ;; serve /srv/git over http
            ;; 1st part: FastCGI backend
            (service fcgiwrap-service-type)
            ;; 2nd part: nginx configuration
            ;; source: https://guix.gnu.org/manual/1.5.0/en/html_node/Version-Control-Services.html
            (service nginx-service-type
                     (nginx-configuration (server-blocks (list (nginx-server-configuration
                                                                (listen '("80"))
                                                                (server-name '
                                                                             ("guix-builder-2611.example.com"))
                                                                (locations (list
                                                                            (git-http-nginx-location-configuration
                                                                             (git-http-configuration
                                                                              (uri-path
                                                                               "/git")))))))))))

           (modify-services %base-services
             (console-font-service-type config =>
                                        (map (lambda (tty)
                                               (cons tty %my-console-font))
                                             '("tty1" "tty2" "tty3" "tty4"
                                               "tty5" "tty6"))))))
  ;; add audit utilities to system
  (packages (cons* audit %base-packages))

  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets (list "/dev/vda"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid "28100a89-65fb-4894-8c2f-0f858fe5504e")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid "f66ed6ac-3d98-4f79-a713-83f5a6aa5596"
                                       'btrfs))
                         (options "compress=zstd:3")
                         (type "btrfs")) %base-file-systems)))
