;; Guix with Xfce4 on Lenovo Notebook on Samsung 1TB "SAMTB" SSD (additional storage)

;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu)
             (gnu packages package-management)
             (srfi srfi-1))
(use-service-modules cups
                     desktop
                     lightdm
                     networking
                     pm
                     sddm
                     ssh
                     virtualization
                     xorg)
(use-package-modules admin
                     bootloaders
                     fonts
                     linux
                     lsof
                     mc
                     package-management
                     password-utils
                     rsync
                     spice
                     texinfo
                     tmux
                     version-control
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
  (host-name "guix-samtb")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "aa")
                  (comment "Aa")
                  (group "users")
                  (home-directory "/home/aa")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))
  ;; avoid costly builds of apps
  (packages (append (list font-bitstream-vera efibootmgr) %base-packages))

  (services
   (cons* (service xfce-desktop-service-type)
          (service lightdm-service-type)
          (service openssh-service-type)
          (service cups-service-type)
          (service tlp-service-type)
          ;; qemu-user to cross-build RPi image
          (service qemu-binfmt-service-type
                   (qemu-binfmt-configuration (platforms (lookup-qemu-platforms
                                                          "arm" "aarch64"))))
          (modify-services %my-desktop-services
            (elogind-service-type config =>
                                  (elogind-configuration (inherit config)
                                                         (idle-action 'ignore)))
            (delete gdm-service-type)
            ;; (delete sddm-service-type)
            )))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (initrd-modules (append '("sym53c8xx") %base-initrd-modules))
  (swap-devices (list (swap-space
                        (target (uuid "75527ba5-a10f-4c7f-91a9-4f2484b97a0c")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid "6149a873-e739-4208-9ae4-3072e1c048fa"
                                       'ext4))
                         (type "ext4"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "5169-0059"
                                       'fat32))
                         (type "vfat")) %base-file-systems)))
