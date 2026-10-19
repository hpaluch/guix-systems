# My Guix Systems


* [apac-bios/](apac-bios/) - installed as VM to attached Apacer SSD in BIOS mode. Later
  plugged into old X2 Opteron machine (via AHCI). Thus I had to rename `/dev/vda` to `/dev/sda`
  in GRUB BIOS configuration.

  How I enabled BTRFS compression at installation: I simply used GUI installer
  (avoiding selection of any Desktop) and when there was generated `/etc/config.scm`
  I choose `Edit` then I added `(options "compress=zstd:3")` into
  `(file-system ...)` - so that option was added to generated `/etc/fstab` and activated.

* [guix-lenovo-samtb/](guix-lenovo-samtb/) - most comprehensive configuration on Lenovo notebook (UEFI mode),
  on secondary Samsung SATA SSD (SAMTB = Samsung 1TB), includes Xfce/X11.

