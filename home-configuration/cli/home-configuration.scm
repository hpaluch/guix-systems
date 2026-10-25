;; Henryk's Guix Home for CLI installations
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
  (packages (specifications->packages (list "btop"
                                            "fastfetch-minimal"
                                            "git-minimal"
                                            "lsof"
                                            "mc"
                                            "ncdu"
                                            "pinfo"
                                            "rsync"
                                            "strace"
                                            "tmux"
                                            "vim")))

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
