(define-module (lotus-rde features base)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (rde system services admin)

  #:use-module (gnu system)
  #:use-module (gnu system setuid)
  #:use-module (gnu services)
  #:use-module (gnu services admin)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services base)
  #:use-module (gnu services desktop)
  #:use-module (gnu services sound)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services xorg)
  #:use-module (gnu services admin)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services networking)
  #:use-module (gnu services avahi)
  #:use-module (gnu services dbus)
  #:use-module (gnu home services)
  #:use-module (gnu home services admin)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services shepherd)

  #:use-module (gnu packages avahi)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages nfs)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages freedesktop)
  #:use-module (rde packages)

  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  #:use-module (guix diagnostics)
  #:use-module (guix i18n)



  #:use-module (ice-9 match)
  #:use-module (srfi srfi-11)
  #:use-module (guix gexp)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system accounts)
  #:use-module (gnu system shadow)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services avahi)
  #:use-module (gnu services ssh)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages avahi)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages xdisorg)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde predicates)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features guile)
  #:use-module (rde features networking)
  #:use-module (rde features system)
  #:use-module (lotus-rde features mfs)
  #:export (feature-login-shell
            ;; feature-lotus-users-group
            feature-lotus-base-services
            feature-lotus-desktop-services))
;; feature-file-database-services
;; feature-guix-publish-services
;; feature-schedular-services
;; feature-unattended-upgrade-services
;; feature-disk-services
;; feature-privileged-programs-services
;; feature-messaging-services
;; feature-mail-services
;; feature-iio-sensor-proxy-services
;; feature-dnsmasq-services
;; feature-network-manager-services
;; feature-dns-services
;; feature-pointer-services
;; feature-bluetooth-services
;; feature-music-services
;; feature-printing-services
;; feature-polkit-services
;; feature-krberos-services))




(define* (feature-login-shell #:key (login-shell #~(string-append #$zsh "/bin/zsh")))
  (feature
   (name 'login-shell)
   (values (make-feature-values login-shell))))

;; (define (feature-lotus-users-group)
;;   (feature
;;    (name 'users-group)
;;    (system-services-getter
;;     (lambda (_)
;;       (list
;;        (simple-service
;;         'users-group
;;         account-service-type
;;         (list
;;          (user-group
;;           (name "users")
;;           (id 1000))
;;          (user-account
;;           (name "s")
;;           (uid 1000)
;;           (group "users")
;;           (home-directory "/home/s/hell")
;;           (shell (file-append zsh "/bin/zsh"))
;;           (supplementary-groups '("wheel" "netdev" "audio" "video" "dialout"))))))))))




(define %lotus-rde-base-system-services1
  (list
   (service greetd-service-type)
   ;; (service mingetty-service-type
   ;;          (mingetty-configuration (tty "tty1")))
   ;; (service mingetty-service-type
   ;;          (mingetty-configuration (tty "tty2")))
   ;; (service mingetty-service-type
   ;;          (mingetty-configuration (tty "tty3")))
   ;; (service mingetty-service-type
   ;;          (mingetty-configuration (tty "tty4")))
   ;; (service mingetty-service-type
   ;;          (mingetty-configuration (tty "tty5")))
   ;; (service mingetty-service-type
   ;;          (mingetty-configuration (tty "tty6")))
   ;; (service mingetty-service-type
   ;;          (mingetty-configuration (tty "tty7")))
   (service virtual-terminal-service-type)
   (service console-font-service-type '())

   (service static-networking-service-type
            (list %loopback-static-networking))
   (service urandom-seed-service-type)
   (service guix-service-type)
   (service nscd-service-type)

   (service shepherd-system-log-service-type)

   (service shepherd-timer-service-type)
   (service shepherd-transient-service-type)

   (service log-rotation-service-type)
   (service log-cleanup-service-type
            (log-cleanup-configuration
             (directory "/var/log/guix/drvs")))
   (service udev-service-type
            (udev-configuration
             (rules (list lvm2 fuse alsa-utils crda))))

   (service sysctl-service-type)

   (service special-files-service-type
            `(("/bin/sh" ,(file-append bash "/bin/sh"))
              ("/usr/bin/env" ,(file-append coreutils "/bin/env"))))))




(define %lotus-rde-base-system-services
  ;; https://github.com/lfam/guix/blob/56ad75cdabe759d8cc004a369ae9c845d34ae896/gnu/services/base.scm
  (list (service login-service-type)

        (service virtual-terminal-service-type)
        (service console-font-service-type
                 (map (lambda (tty)
                        (cons tty %default-console-font))
                      '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))

        (service syslog-service-type)
        (service agetty-service-type (agetty-configuration
                                       (extra-options '("-L")) ; no carrier detect
                                       (term "vt100")
                                       (tty #f) ; automatic
                                       (shepherd-requirement '(syslogd))))

        (service mingetty-service-type (mingetty-configuration
                                         (tty "tty1")))
        (service mingetty-service-type (mingetty-configuration
                                         (tty "tty2")))
        (service mingetty-service-type (mingetty-configuration
                                         (tty "tty3")))
        (service mingetty-service-type (mingetty-configuration
                                         (tty "tty4")))
        (service mingetty-service-type (mingetty-configuration
                                         (tty "tty5")))
        (service mingetty-service-type (mingetty-configuration
                                         (tty "tty6")))

        (service static-networking-service-type
                 (list %loopback-static-networking))
        (service urandom-seed-service-type)
        (service guix-service-type)
        (service nscd-service-type)

        (service log-rotation-service-type)

        ;; Convenient services brought by the Shepherd.
        (service shepherd-timer-service-type)
        (service shepherd-transient-service-type)

        ;; Periodically delete old build logs.
        (service log-cleanup-service-type
                 (log-cleanup-configuration
                  (directory "/var/log/guix/drvs")))

        ;; The LVM2 rules are needed as soon as LVM2 or the device-mapper is
        ;; used, so enable them by default.  The FUSE and ALSA rules are
        ;; less critical, but handy.
        (service udev-service-type
                 (udev-configuration
                   (rules (list lvm2 fuse alsa-utils crda))))

        (service sysctl-service-type)))


(define %lotus-rde-base-home-services
  ;; Non-essential but useful services to have by default.
  (list (service home-log-rotation-service-type)
        (service home-shepherd-timer-service-type)
        (service home-shepherd-transient-service-type)))

(define* (feature-lotus-base-services
          #:key
          (default-substitute-urls #f)
          (default-authorized-guix-keys #f)
          (guix-substitute-urls #f)
          (guix-authorized-keys #f)
          (guix-daemon-extra-options
           (list "--gc-keep-derivations=yes" "--gc-keep-outputs=yes"))
          (guix-daemon-privileged? #t)
          (udev-rules '())
          (guix-http-proxy #f)
          (base-system-services %lotus-rde-base-system-services)
          (base-home-services %lotus-rde-base-home-services))
  "Provides base system services."
  (ensure-pred list-of-strings? guix-daemon-extra-options)
  (ensure-pred boolean? guix-daemon-privileged?)
  (ensure-pred list-of-file-likes? udev-rules)
  (ensure-pred maybe-string? guix-http-proxy)
  (ensure-pred list-of-services? base-system-services)
  (ensure-pred list-of-services? base-home-services)

  (when default-substitute-urls
    (warning
     (G_ "'~a' in feature-base-services is deprecated and ignored, use '~a' instead~%")
     'default-substitute-urls 'guix-extensions))
  (when default-authorized-guix-keys
    (warning
     (G_ "'~a' in feature-base-services is deprecated and ignored, use '~a' instead~%")
     'default-authorized-guix-keys 'guix-extensions))
  (when guix-substitute-urls
    (warning
     (G_ "'~a' in feature-base-services is deprecated and ignored, use '~a' instead~%")
     'guix-substitute-urls 'guix-extensions))
  (when guix-authorized-keys
    (warning
     (G_ "'~a' in feature-base-services is deprecated and ignored, use '~a' instead~%")
     'guix-authorized-keys 'guix-extensions))

  (define (get-base-system-services cfg)
    (append
     (modify-services base-system-services
       (console-font-service-type
        config =>
        (map (lambda (x)
               (cons
                (format #f "tty~a" x)
                (get-value 'console-font cfg "LatGrkCyr-8x16")))
             (iota (get-value 'number-of-ttys cfg 6) 1)))
       (guix-service-type
        config =>
        (guix-configuration
         (inherit config)
         (privileged? guix-daemon-privileged?)
         (extra-options guix-daemon-extra-options)
         (http-proxy guix-http-proxy)))
       ;; (greetd-service-type
       ;;  config =>
       ;;  (greetd-configuration
       ;;   (terminals
       ;;    (map (lambda (x)
       ;;           (greetd-terminal-configuration
       ;;            (terminal-vt (number->string x))
       ;;            (terminal-switch #t)
       ;;            (default-session-command
       ;;              #~(string-append #$shadow "/bin/login"))))
       ;;         (iota (get-value 'number-of-ttys cfg 5) 2)))))
       ;; (greetd-service-type
       ;;  config =>
       ;;  (greetd-configuration
       ;;   (terminals
       ;;    (map (lambda (x)
       ;;           (greetd-terminal-configuration
       ;;            (terminal-vt (number->string x))))
       ;;         (iota 6 1)))))
       (udev-service-type
        config =>
        (udev-configuration
         (inherit config)
         (rules (append
                 udev-rules
                 (udev-configuration-rules config))))))
     (list
      (simple-service
       'base-preserve-terminfo-variable
       sudoers-service-type
       (list "
# Keep terminfo database for root and %wheel.
Defaults:%wheel env_keep+=TERMINFO_DIRS
Defaults:%wheel env_keep+=TERMINFO")))))

  (feature
   (name 'base-services)
   (values `((base-services . #t)
             (number-of-ttys . ,%number-of-ttys)))
   (system-services-getter get-base-system-services)
   (home-services-getter (const base-home-services))))






(define %rde-from-rde-desktop-system-services
  (list
   ;; Add udev rules for MTP devices so that non-root users can access
   ;; them.
   (simple-service 'mtp udev-service-type (list libmtp))
   ;; Add udev rules for scanners.
   (service sane-service-type)
   ;; Add polkti rules, so that non-root users in the wheel group can
   ;; perform administrative tasks (similar to "sudo").
   polkit-wheel-service

   ;; Allow desktop users to also mount NTFS and NFS file systems
   ;; without root.
   (simple-service
    'mount-setuid-helpers
    privileged-program-service-type
    (map (lambda (program)
           (setuid-program
            (program program)))
         (list (file-append nfs-utils "/sbin/mount.nfs")
               (file-append ntfs-3g "/sbin/mount.ntfs-3g"))))

   ;; The global fontconfig cache directory can sometimes contain
   ;; stale entries, possibly referencing fonts that have been GC'd,
   ;; so mount it read-only.
   (simple-service 'fontconfig-file-system
                   file-system-service-type
                   (list %fontconfig-file-system))


   ;; The D-Bus clique.
   (service accountsservice-service-type)
   (service cups-pk-helper-service-type)
   (service colord-service-type)

   (service ntp-service-type)

   (service x11-socket-directory-service-type)))


(define %rde-lotus-desktop-system-services
  ;; https://github.com/lfam/guix/blob/56ad75cdabe759d8cc004a369ae9c845d34ae896/gnu/services/desktop.scm

  ;; List of services typically useful for a "desktop" use case.

  ;; FIXME: Since GDM depends on more dependencies that do not build on i686,
  ;; keep SDDM on it for the time being.
  ;; XXX: When changing login manager, also change set-xorg-configuration
  (list ;; (service gdm-service-type)

        ;; Screen lockers are a pretty useful thing and these are small.
        (service screen-locker-service-type
                 (screen-locker-configuration
                  (name "slock")
                  (program (file-append slock "/bin/slock"))))
        (service screen-locker-service-type
                 (screen-locker-configuration
                  (name "xlock")
                  (program (file-append xlockmore "/bin/xlock"))))

        ;; Add udev rules for MTP devices so that non-root users can access
        ;; them.
        (simple-service 'mtp udev-service-type (list libmtp))
        ;; Add udev rules and default backends for scanners.
        (service sane-service-type)
        ;; Add polkit rules, so that non-root users in the wheel group can
        ;; perform administrative tasks (similar to "sudo").
        polkit-wheel-service

        ;; Allow desktop users to also mount NTFS and NFS file systems
        ;; without root.
        (simple-service 'mount-setuid-helpers privileged-program-service-type
                        (map file-like->setuid-program
                             (list (file-append nfs-utils "/sbin/mount.nfs")
                                   (file-append ntfs-3g "/sbin/mount.ntfs-3g"))))

        ;; Add some of the artwork niceties for the desktop.
        (simple-service 'guix-artwork
                        profile-service-type
                        %base-packages-artwork)

        ;; This is a volatile read-write file system mounted at /var/lib/gdm,
        ;; to avoid GDM stale cache and permission issues.
        gdm-file-system-service

        ;; Provides a nicer experience for VTE-using terminal emulators such
        ;; as GNOME Console, Xfce Terminal, etc.
        (service vte-integration-service-type)

        ;; The global fontconfig cache directory can sometimes contain
        ;; stale entries, possibly referencing fonts that have been GC'd,
        ;; so mount it read-only.
        fontconfig-file-system-service

        ;; NetworkManager and its applet.
        ;; (service network-manager-service-type)
        (service wpa-supplicant-service-type)    ;needed by NetworkManager
        (simple-service 'network-manager-applet
                        profile-service-type
                        (list network-manager-applet))
        (service modem-manager-service-type)
        (service usb-modeswitch-service-type)

        ;; The D-Bus clique.
        ;; (service avahi-service-type)
        (service udisks-service-type)
        ;; (service upower-service-type)
        (service accountsservice-service-type)
        (service cups-pk-helper-service-type)
        (service colord-service-type)
        (service geoclue-service-type)
        (service polkit-service-type)
        ;; (service elogind-service-type)
        ;; (service dbus-root-service-type)

        (service ntp-service-type)

        (service x11-socket-directory-service-type)



        ;; %base-services

        (service pulseaudio-service-type)
        (service alsa-service-type)))





(define* (feature-lotus-desktop-services
          #:key
          (default-desktop-system-services %rde-lotus-desktop-system-services)
          (avahi avahi)
          (dbus dbus)
          (elogind elogind)
          (geoclue geoclue)
          (udisks udisks)
          (upower upower))
  "Provides desktop system services."
  (ensure-pred file-like? avahi)
  (ensure-pred file-like? dbus)
  (ensure-pred file-like? elogind)
  (ensure-pred file-like? geoclue)
  (ensure-pred file-like? udisks)
  (ensure-pred file-like? upower)

  (define (get-home-services _)
    (list (service home-dbus-service-type
                   (home-dbus-configuration (dbus dbus)))))

  (define (get-system-services _)
    (cons*

     (service gnome-desktop-service-type)

     (service avahi-service-type
              (avahi-configuration (avahi avahi)))
     ;; (service dbus-root-service-type
     ;;          (dbus-configuration (dbus dbus)))
     (service elogind-service-type
              (elogind-configuration (elogind elogind)))
     (service geoclue-service-type
              (geoclue-configuration (geoclue geoclue)))
     (service udisks-service-type
              (udisks-configuration (udisks udisks)))
     (service upower-service-type
              (upower-configuration (upower upower)))
     default-desktop-system-services))

  (feature
   (name 'desktop-services)
   (values `((desktop-services . #t)
             (elogind . ,elogind)
             (dbus . ,dbus)))
   (home-services-getter get-home-services)
   (system-services-getter get-system-services)))











;; (get-value 'number-of-ttys cfg 6)
;; (make-feature-values scaling-factor console-font)

;; (define* (feature-file-database-services
;;           #:key
;;           (package findutils)
;;           (schedule "0 4 * * *")
;;           (excluded-directories '("/tmp" "/var/tmp" "/gnu/store" "/run")))
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;    (cons*
;;     (service package-database-service-type)
;;     (service file-database-service-type
;;              (file-database-configuration
;;               (package              findutils)
;;               (schedule             schedule)
;;               (excluded-directories excluded-directories)))))
;;   (feature
;;    (name 'file-database)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))

;; (define* (feature-guix-publish-services
;;           #:key
;;           (advertise #t)
;;           (port 3000)
;;           (host "0.0.0.0")
;;           (compression '(("lzip" 7) ("gzip" 9)))
;;           (cache "/var/cache/guix/publish")
;;           (cache-bypass-threshold (* 100 1024 1024))
;;           (ttl (* 1 24 60 60)))
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service guix-publish-service-type
;;               (guix-publish-configuration
;;                (advertise?             advertise)
;;                (port                   port)
;;                (host                   host)
;;                (compression            compression)
;;                (cache                  cache)
;;                (cache-bypass-threshold cache-bypass-threshold)
;;                (ttl                    ttl)))))
;;   (feature
;;    (name 'guix-publish)
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))
;; 

;; (define* (feature-schedular-services
;;           #:key
;;           (jobs #f))
;;   ;; Vixie cron schedular
;;   (define updatedb-job
;;     ;; Run 'updatedb' at 3AM every day.  Here we write the
;;     ;; job's action as a Scheme procedure.
;;     #~(job '(next-hour '(3))
;;            (lambda ()
;;              (execl (string-append #$findutils "/bin/updatedb")
;;                     ;; "updatedb"
;;                     "--prunepaths=`/tmp /var/tmp /gnu/store /run'"))))

;;   (define garbage-collector-job
;;     ;; Collect garbage 5 minutes after midnight every day.
;;     ;; The job's action is a shell command.
;;     #~(job "5 0 * * *"            ;Vixie cron syntax
;;            "guix gc -F 1G"))

;;   (define idutils-job
;;     ;; Update the index database as user "charlie" at 12:15PM
;;     ;; and 19:15PM.  This runs from the user's home directory.
;;     #~(job '(next-minute-from (next-hour '(12 19)) '(15))
;;            (string-append #$idutils "/bin/mkid src")
;;            #:user "s"))

;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (let ((jobs (or jobs (list updatedb-job garbage-collector-job idutils-job))))
;;       (cons*
;;        (service mcron-service-type
;;               (mcron-configuration
;;                (jobs jobs))))))

;;   (let ((jobs (or jobs (list updatedb-job garbage-collector-job idutils-job))))
;;     (feature
;;      (name 'mcron)
;;      (values `())
;;      (home-services-getter get-home-services)
;;      (system-services-getter get-system-services))))


;; (define* (feature-unattended-upgrade-services
;;           #:key
;;           (operating-system-file (file-append "/run/current-system/etc/config/config.scm"))
;;           (services-to-restart '(mcron))
;;           (channels #~%default-channels)
;;           (schedule "30 01 * * 0")
;;           (system-expiration (* 3 30 24 3600))
;;           (maximum-duration 3600)
;;           (log-file "/var/log/unattended-upgrade.log"))
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service unattended-upgrade-service-type
;;               (unattended-upgrade-configuration
;;                (operating-system-file operating-system-file)
;;                (services-to-restart services-to-restart)
;;                (channels channels)
;;                (schedule schedule)
;;                (system-expiration system-expiration)
;;                (maximum-duration maximum-duration)
;;                (log-file log-file)))))
;;   ;; https://guix.gnu.org/manual/en/html_node/Unattended-Upgrades.html
;;   ;; How to mount /boot and that as rw?
;;   ;; Check also these
;;   ;; https://guix.gnu.org/manual/en/html_node/Service-Reference.html
;;   (feature
;;    (name 'unattended-upgrade)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-disk-services
;;           #:key)
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service udisks-service-type)))

;;   (feature
;;    (name 'desktop)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-privileged-programs-services
;;           #:key
;;           (paths (list (file-append ecryptfs-utils "/sbin/mount.ecryptfs_private")
;;                        (file-append ecryptfs-utils "/sbin/umount.ecryptfs_private")
;;                        (file-append xtrlock "/bin/xtrlock")
;;                        (file-append firejail "/bin/firejail"))))
;;   ;; https://git.sr.ht/~boeg/home/tree/master/.config/guix/system/config.scm
;;   ;; https://git.savannah.gnu.org/cgit/guix.git/tree/gnu/services/desktop.scm#n1209
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (simple-service
;;       'privileged-programs
;;       privileged-program-service-type
;;       (map (lambda (path)
;;              (privileged-program
;;               (program path)
;;               (setuid? #t)))
;;            paths))))

;;   (feature
;;    (name 'privileged-programs)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; ;; TODO
;; ;; https://github.com/xavierm02/guix-config/blob/master/config.scm
;; ;; (simple-service 'i3-packages
;; ;;                 profile-service-type
;; ;;                 (list dmenu i3-wm i3lock i3status))


;; (define* (feature-messaging-services
;;           #:key
;;           (plugins '()))
;;   ;; (service bitlbee-service-type
;;   ;;          (bitlbee-configuration
;;   ;;           (plugins (if %lotus-bitlbee-service-use-default? '() (if nongnu-desktop?
;;   ;;                                                                    (list skype4pidgin)
;;   ;;                                                                    '())))
;;   ;;           (bitlbee (if %lotus-bitlbee-service-use-default? bitlbee bitlbee-purple))))
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service bitlbee-service-type
;;               (bitlbee-configuration
;;                (plugins plugins)))))

;;   (feature
;;    (name 'bitlbee)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-mail-services
;;           #:key
;;           (aliases '(("postmaster" "bob")
;;                      ("bob"        "bob@example.com" "bob@example2.com"))))
;;   ;; https://guix.gnu.org/manual/en/html_node/Mail-Services.html
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service mail-aliases-service-type
;;               aliases)
;;      (service dovecot-service-type
;;               (dovecot-configuration
;;                (mail-location "maildir:~/.maildir")
;;                (listen        '("127.0.0.1"))))
;;      (service exim-service-type
;;               (exim-configuration
;;                (config-file #f)))))

;;   (feature
;;    (name 'mail-aliases)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-iio-sensor-proxy-services
;;           #:key
;;           (auto-enable? #t))
;;   ;; https://guix.gnu.org/manual/en/html_node/Desktop-Services.html
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service iio-sensor-proxy-service-type
;;               (iio-sensor-proxy-configuration
;;                (auto-enable? auto-enable?)))))

;;   (feature
;;    (name 'iio-sensor-proxy)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-dnsmasq-services
;;           #:key
;;           (no-resolv? #t)
;;           (local-service? #t))
;;   ;; https://notabug.org/thomassgn/guixsd-configuration/src/master/config.scm
;;   ;; https://guix.gnu.org/manual/en/html_node/Networking-Services.html
;;   ;; https://jonathansblog.co.uk/using-dnsmasq-as-an-internal-dns-server-to-block-online-adverts
;;   ;; https://stackoverflow.com/questions/48644841/multiple-addn-hosts-conf-in-dnsmasq
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service dnsmasq-service-type
;;               (dnsmasq-configuration (no-resolv? no-resolv?)
;;                                      (local-service? local-service?)))))

;;   (feature
;;    (name 'dnsmasq)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-network-manager-services
;;           #:key
;;           (vpn-plugins (list network-manager-fortisslvpn
;;                              network-manager-openconnect))
;;           (dns "dnsmasq"))
;;   ;; https://guix.gnu.org/manual/en/html_node/Networking-Services.html
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service network-manager-service-type
;;               (network-manager-configuration
;;                (vpn-plugins vpn-plugins)
;;                (dns dns)))))

;;   (feature
;;    (name 'network-manager-vpn)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))

;; (define* (feature-dns-services)
;;   ;; https://guix.gnu.org/manual/en/html_node/Avahi-Services.html
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service avahi-service-type)))

;;   (feature
;;    (name 'avahi)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-pointer-services)
;;   ;; https://guix.gnu.org/manual/en/html_node/GPM-Services.html
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service gpm-service-type)))

;;   (feature
;;    (name 'gpm)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-bluetooth-services
;;           #:key (auto-enable? #t))
;;   ;; https://unix.stackexchange.com/questions/617858/how-to-enable-bluetooth-in-guix
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service bluetooth-service-type
;;               (bluetooth-configuration
;;                (auto-enable? auto-enable?)))))

;;   (feature
;;    (name 'bluetooth)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-music-services
;;           #:key
;;           (music-dir "~/Music")
;;           (auto-update? #t)
;;           (user  #f)
;;           (group #f)
;;           (log-file "/var/log/mpd.log")
;;           (log-level "verbose")
;;           (state-file #f)
;;           (sticker-file #f)
;;           (db-file   #f)
;;           (music-directory #f)
;;           (playlist-directory #f)
;;           (outputs
;;            (list (mpd-output (name "Pulseaudio Sound Server")
;;                              (type "pulse")
;;                              ;; (mixer-type 'null)
;;                              ;; (extra-options
;;                              ;;  `((encoder . "vorbis")
;;                              ;;    (port    . "8080")))
;;                              (enabled?   #t)
;;                              (always-on? #f)
;;                              (mixer-type "software"))
;;                  (mpd-output (name "PipeWire Sound Server")
;;                              (type "pipewire")
;;                              (enabled?   #f)))))
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service mpd-service-type
;;               (mpd-configuration
;;                (auto-update? auto-update?)
;;                (user  user)
;;                (group group)
;;                (log-file log-file)
;;                (log-level log-level)
;;                (state-file state-file)
;;                (sticker-file sticker-file)
;;                (db-file db-file)
;;                (music-directory music-directory)
;;                (playlist-directory playlist-directory)
;;                (outputs outputs)))))

;;   (feature
;;    (name 'mpd)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-printing-services
;;           #:key
;;           (web-interface? #t)
;;           (default-paper-size "A4")
;;           (extensions (list cups-filters
;;                             hplip-minimal)))

;;   ;; https://guix.gnu.org/manual/en/html_node/CUPS-Services.html
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service cups-service-type
;;               (cups-configuration
;;                (web-interface? web-interface?)
;;                (default-paper-size default-paper-size)
;;                (extensions extensions)))))

;;   (feature
;;    (name 'cups)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-polkit-services
;;           #:key)
;;   ;; https://github.com/alezost/guix-config/blob/master/system-config/os-main.scm
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons* (service polkit-service-type)))

;;   (feature
;;    (name 'polkit)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-krberos-services
;;           #:key
;;           (default-realm "EXAMPLE.COM")
;;           (allow-weak-crypto? #t)
;;           (realms '()))
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service krb5-service-type
;;               (krb5-configuration
;;                (default-realm default-realm)
;;                (allow-weak-crypto? allow-weak-crypto?)
;;                (realms realms)))))

;;   (feature
;;    (name 'krb5)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-container-sevices #:key)
;;    ;; https://guix.gnu.org/manual/en/html_node/Container-Services.html
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service containerd-service-type)
;;      (service docker-service-type)
;;      (service spice-vdagent-service-type)))

;;   (feature
;;    (name 'container)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-security-services
;;           #:key
;;           (pcsc-lite pcsc-lite)
;;           (usb-drivers (list ccid))
;;           (fail2ban-jails (list (fail2ban-jail-configuration
;;                                   (name "sshd")
;;                                   (enabled? #t)))))
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service pcscd-service-type
;;               (pcscd-configuration (pcsc-lite pcsc-lite)
;;                                    (usb-drivers (list ccid))))
;;      (service fail2ban-service-type
;;               (fail2ban-configuration
;;                (extra-jails fail2ban-jails)))))

;;   (feature
;;    (name 'security)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))

;; (define* (feature-audit-services
;;           #:key
;;           (audit audit)
;;           (configuration-directory #f))
;;   ;; https://guix.gnu.org/manual/en/html_node/Audit-Services.html
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service auditd-service-type
;;               (auditd-configuration
;;                (audit audit)
;;                (configuration-directory configuration-directory)))))

;;   (feature
;;    (name 'audit)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-guix-services
;;           #:key
;;           (discover? #t)
;;           (build-accounts 10)
;;           (authorize-key? #f)
;;           (tmpdir (if %lotus-system-init #f "/tmp"))
;;           (use-substitutes? #t)
;;           (substitute-urls '())
;;           (local-substitute-urls '())
;;           (local-fixed-named-substitute-urls '())
;;           (authorized-keys '())
;;           (extra-options '()))
;;   ;; https://gitlab.com/Efraim/guix-config/blob/master/macbook41_config.scm
;;   ;; https://guix.gnu.org/manual/en/html_node/Base-Services.html
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service guix-service-type
;;               (guix-configuration
;;                (discover?        discover?)
;;                (build-accounts   build-accounts)
;;                (authorize-key?   authorize-key?)
;;                ;; https://guix.gnu.org/manual/en/html_node/Base-Services.html
;;                (tmpdir           tmpdir)
;;                (use-substitutes? use-substitutes?)
;;                (substitute-urls  substitute-urls)
;;                (local-substitute-urls local-substitute-urls)
;;                (local-fixed-named-substitute-urls local-fixed-named-substitute-urls)
;;                ;; https://guix.gnu.org/manual/en/html_node/Getting-Substitutes-from-Other-Servers.html
;;                (authorized-keys  authorized-keys)
;;                (extra-options    extra-options)))))

;;   (feature
;;    (name 'guix-service)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


;; (define* (feature-desktop-manager-service
;;           #:key
;;           (xorg-configuration (xorg-configuration
;;                                (keyboard-layout %lotus-keyboard-layout)))
;;           (allow-empty-password? #t)
;;           (auto-login? #t)
;;           (default-user #f))
;;   ;; https://gitlab.com/Efraim/guix-config/blob/master/macbook41_config.scm)
;;   ;; https://issues.guix.info/issue/35674
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service gdm-service-type
;;               (gdm-configuration
;;                (xorg-configuration xorg-configuration)
;;                (allow-empty-passwords? allow-empty-password?)
;;                (auto-login? auto-login?)
;;                (default-user %lotus-account-user-name)))))

;;   (feature
;;    (name 'gdm-service)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))

;; (define* (feature-pulseaudio-service
;;           #:key
;;           (script-file (local-file "/etc/guix/default.pa")))
;;   (define (get-home-services config)
;;     (cons*))

;;   (define (get-system-packages config)
;;     (cons*
;;      (service pulseaudio-service-type
;;               (pulseaudio-configuration
;;                (script-file script-file)))))

;;   (feature
;;    (name 'pulseaudio)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))


