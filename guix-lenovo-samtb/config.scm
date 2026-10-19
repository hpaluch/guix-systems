;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu) (gnu packages package-management) (srfi srfi-1))
(use-service-modules cups desktop lightdm networking sddm ssh virtualization xorg)
(use-package-modules admin bootloaders fonts chromium gnuzilla linux lsof mc music ncdu
                     package-management password-utils rsync spice texinfo tmux version-control
		     video vim wine xdisorg xfce xorg)

(define %cli-packages (list fastfetch-minimal git lsof mc ncdu pinfo rsync strace tmux vim))
(define %gui-packages (list audacious keepass icedove icecat mpv ungoogled-chromium virt-viewer vlc wine))
(define %xfce-plugins (list xfce4-cpufreq-plugin xfce4-cpugraph-plugin
           xfce4-diskperf-plugin xfce4-netload-plugin xfce4-xkb-plugin))
;; services needed only when running as specific Guest VM
(define %guest-services (if (file-exists? "/dev/virtio-ports/org.qemu.guest_agent.0")
                            (list (service qemu-guest-agent-service-type))
                            (list )))
(define %my-desktop-services (append %guest-services %desktop-services))


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

  (packages (append (list font-bitstream-vera efibootmgr)
		    %cli-packages %gui-packages %base-packages %xfce-plugins))

  (services
   (cons* (service xfce-desktop-service-type)
                 (service lightdm-service-type)

                 ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
                 (service cups-service-type)
                 (service elogind-service-type
                        (elogind-configuration (idle-action 'ignore)))
                 ;;(set-xorg-configuration (xorg-configuration (keyboard-layout keyboard-layout)))
                 ;; from gnu/system/examples/plasma.tmpl
                 ;; Note: elogind is NOT actually removed,
                 ;;   but already added in above 'service elogind-service-type line!)
                 ;;   because adding same service twice is error.
                 (remove (lambda (service)
                       (memq (service-kind service)
                             (list gdm-service-type sddm-service-type elogind-service-type)))
                     %my-desktop-services)))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (initrd-modules (append '("sym53c8xx") %base-initrd-modules))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "75527ba5-a10f-4c7f-91a9-4f2484b97a0c")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "6149a873-e739-4208-9ae4-3072e1c048fa"
                                  'ext4))
                         (type "ext4"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "5169-0059"
                                       'fat32))
                         (type "vfat")) %base-file-systems)))
