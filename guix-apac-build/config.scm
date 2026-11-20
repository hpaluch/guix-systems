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
(use-service-modules cups desktop networking ssh virtualization xorg)

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
		 ;; qemu-user to cross-build RPi image
            (service qemu-binfmt-service-type
                     (qemu-binfmt-configuration
                      (platforms
                       (lookup-qemu-platforms
                        "arm"
                        "aarch64"
                        )))))
          (modify-services (cons (service elogind-service-type) %base-services)
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
                        (target (uuid
                                 "a25a5b02-d16f-4436-bd68-df3e7e2a4164")))))

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
                         (device (uuid
                                  "65cf35e3-5b47-4172-b2db-e1f802d4fc4a"
                                  'btrfs))
                         (type "btrfs")) %base-file-systems)))
