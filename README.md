# My Guix Systems


* [apac-bios/](apac-bios/) - installed as VM to attached Apacer SSD in BIOS mode. Later
  plugged into old X2 Opteron machine (via AHCI). Thus I had to rename `/dev/vda` to `/dev/sda`
  in GRUB BIOS configuration.

  How I enabled BTRFS compression at installation: I simply used GUI installer
  (avoiding selection of any Desktop) and when there was generated `/etc/config.scm`
  I choose `Edit` then I added `(options "compress=zstd:3")` into
  `(file-system ...)` - so that option was added to generated `/etc/fstab` and activated.

* [apac-xfce/](apac-xfce/) - installed directly on target ) - old X2 Opteron machine (via AHCI).
  I wanted to clone it from `apac-bios`,but it lacked `cow-herd` service, required for install.

  Status: `/etc/config.scm` was just cloned from `apac-bios` and updated filesystem UUID. Also
  mounted `apac-bios` Guix under `/mnt/guix-cli`

  TODO: Add original `apac-bios` Guix to BOOT menu (overwritten BIOS/MBR loader that now loads just
  `apac-xfce`)

* [guix-2610/](guix-2610/) - VM with Xfce+lightdm (adapted from Lenovo below), but omitted
  packages at system level (often cause issues with updates)

  There is now experimental `Guix Home` configuration that will manage various dot files (like
  `~/.bash_profile` and installed packages in your HOME.

  To apply my configuration run:
  ```shell
  guix home reconfigure `pwd`/guix-2610/home-config/home-configuration.scm
  ```

  WARNING! Packages installed with Guix Home must use special commands. For example to
  list all Guix Home packages use this:
  ```shell
  # THIS WILL NOT WORK! => guix package -I
  # proper command:
  guix home describe -I
  ```

* [guix-cli-2610/](guix-cli-2610/) - like `guix-2610` (VM) - but this time with minimal
  CLI installation). Initial setup, but experiment with custom `/etc/issue` and custom
  console font (original VGA)

* [guix-home](guix-home) - VM to mimic my main Desktop (currently openSUSE LEAP 16.0) as much
  as possible.

* [guix-lenovo-samtb/](guix-lenovo-samtb/) - most comprehensive configuration on Lenovo notebook (UEFI mode),
  on secondary Samsung SATA SSD (SAMTB = Samsung 1TB), includes Xfce/X11.

