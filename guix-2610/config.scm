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
(use-modules (gnu)
             (gnu packages package-management)
             (srfi srfi-1))
(use-service-modules cups
                     desktop
                     lightdm
                     networking
                     sddm
                     ssh
                     virtualization
                     xorg)
(use-package-modules admin
                     bootloaders
                     fonts
                     chromium
                     gnuzilla
                     linux
                     lsof
                     mc
                     music
                     ncdu
                     package-management
                     password-utils
                     rsync
                     spice
                     texinfo
                     tmux
                     version-control
                     video
                     vim
                     wine
                     xdisorg
                     xfce
                     xorg)

;; services needed only when running as specific Guest VM
(define %guest-services
  (if (file-exists? "/dev/virtio-ports/org.qemu.guest_agent.0")
      (list (service qemu-guest-agent-service-type))
      (list)))
(define %my-desktop-services
  (append %guest-services %desktop-services))

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Berlin")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "guix-2610")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "ansible")
                  (comment "Ansible")
                  (group "users")
                  (home-directory "/home/ansible")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                ;; test user
                (user-account
                  (name "ansible2")
                  (comment "Ansible2")
                  (group "users")
                  (home-directory "/home/ansible2")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))

                %base-user-accounts))

  (services
   (cons* (service xfce-desktop-service-type)
          (service lightdm-service-type)

          ;; To configure OpenSSH, pass an 'openssh-configuration'
          ;; record as a second argument to 'service' below.
          (service openssh-service-type)
          (service cups-service-type)
          (service elogind-service-type
                   (elogind-configuration (idle-action 'ignore)))
          ;; (set-xorg-configuration (xorg-configuration (keyboard-layout keyboard-layout)))
          ;; from gnu/system/examples/plasma.tmpl
          ;; Note: elogind is NOT actually removed,
          ;; but already added in above 'service elogind-service-type line!)
          ;; because adding same service twice is error.
          (remove (lambda (service)
                    (memq (service-kind service)
                          (list gdm-service-type sddm-service-type
                                elogind-service-type))) %my-desktop-services)))

  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets (list "/dev/vda"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid "e4cf17f0-f891-43e8-be1a-8665ebefe93d")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid "30822041-0466-42f4-a52a-b9d818ee840d"
                                       'ext4))
                         (type "ext4")) %base-file-systems)))
