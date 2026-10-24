;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu) (gnu packages fonts) (srfi srfi-1))
(use-service-modules cups desktop networking ssh xorg)

;; FIXME: %default-issue is not exported from (gnu system)...
;; copied from guix/gnu/system.scm and renamed from %default-issue to %default-issue-copy
;; to avoid future conflict (if it will become exported)
(define %default-issue-copy
    ;; Default contents for /etc/issue.
      "
      This is the GNU system.  Welcome.\n")

;; custom console font, grabbed from gnu/services/base.scm
(define %my-console-font
  ;; Note: the 'font-gnu-unifont' package cannot be cross-compiled (yet), but
  ;; its "psf" output is the same whether it's built natively or not, hence
  ;; 'ungexp-native'.
  #~(string-append #+font-gnu-unifont:psf
                   "/share/consolefonts/Uni1-VGA16.psf.gz"))

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Berlin")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "guix-cli-2610")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "ansible")
                  (comment "Ansible")
                  (group "users")
                  (home-directory "/home/ansible")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))
  ;; FIXME: I wanted to print IP address, but mingetty does not support that...
  (issue (string-append %default-issue-copy "\nKernel: \\r \\v on \\m\n\n" ))
  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
   (append (list
                 ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
                 (service dhcpcd-service-type))
	   (modify-services %base-services
             (console-font-service-type config =>
                              (map (lambda (tty) (cons tty %my-console-font))
                                '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6"))))
   )
  )
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets (list "/dev/vda"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "28100a89-65fb-4894-8c2f-0f858fe5504e")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "f66ed6ac-3d98-4f79-a713-83f5a6aa5596"
                                  'btrfs))
			 (options "compress=zstd:3")
                         (type "btrfs")) %base-file-systems)))
