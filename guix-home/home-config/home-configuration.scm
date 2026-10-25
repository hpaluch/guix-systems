;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (guix gexp)
             (gnu home services)
             (gnu home services shells))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages (specifications->packages (list "xfce4-xkb-plugin"
                                            "xfce4-netload-plugin"
                                            "xfce4-diskperf-plugin"
                                            "xfce4-cpugraph-plugin"
                                            "xfce4-cpufreq-plugin"
                                            "vlc"
                                            "virt-viewer"
                                            "mpv"
                                            "keepass"
                                            "audacious"
                                            "rsync"
                                            "git"
                                            "vim"
                                            "tmux"
                                            "pinfo"
                                            "ncdu"
                                            "mc"
                                            "lsof"
                                            "fastfetch-minimal"
                                            "git-minimal"
                                            "ungoogled-chromium"
                                            "btop"
                                            "icecat"
                                            "icedove"
                                            "strace")))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
   (append (list (service home-bash-service-type
                          (home-bash-configuration
                           (bash-profile (list (local-file ".bash_profile"
                                                           "bash_profile")))))
                 (service home-files-service-type
                          `((".tmux.conf" ,(local-file "tmux.conf"))
                            (".vimrc" ,(local-file "vimrc")))))
           %base-home-services)))
