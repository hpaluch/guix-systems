;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu))
(use-service-modules cups desktop lightdm networking ssh virtualization xorg)
;; NOTE: We don't install global system-wise packages (unless necessary) to make System updates faster/more reliable
(use-package-modules fonts)

;; services needed only when running as specific Guest VM
(define %guest-services
  (if (file-exists? "/dev/virtio-ports/org.qemu.guest_agent.0")
      (list (service qemu-guest-agent-service-type))
      (list)))
(define %my-desktop-services
  (append %guest-services %desktop-services))

;; custom console font, original from gnu/services/base.scm
(define %my-console-font
  #~(string-append #+font-gnu-unifont:psf
                   "/share/consolefonts/Uni1-VGA16.psf.gz"))


(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Berlin")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "guix-home")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "aa")
                  (comment "Aa")
                  (group "users")
                  (home-directory "/home/aa")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
   (cons* (service xfce-desktop-service-type)
          (service lightdm-service-type)
          ;; To configure OpenSSH, pass an 'openssh-configuration'
          ;; record as a second argument to 'service' below.
          (service openssh-service-type)
          (service cups-service-type)
          (modify-services %my-desktop-services
            (console-font-service-type config =>
                                       (map (lambda (tty)
                                              (cons tty %my-console-font))
                                            '("tty1" "tty2" "tty3" "tty4"
                                              "tty5" "tty6")))
            (elogind-service-type config =>
                                  (elogind-configuration (inherit config)
                                                         (idle-action 'ignore)))
            (delete gdm-service-type))))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "31a16b2b-5001-4abe-a56b-8a69055abf18")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "66522719-65c6-441a-8eca-436cb72483f4"
                                  'btrfs))
                         (options "compress=zstd:3")
                         (type "btrfs"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "3392-4596"
                                       'fat32))
                         (type "vfat")) %base-file-systems)))
