(define-module (lotus-rde features base)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-11)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu packages base)
  #:use-module (gnu services)
  #:use-module (gnu services ssh)
  #:use-module (gnu packages linux)
  #:use-module (gnu system linux-initrd)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features guile)
  #:use-module (rde features networking)
  #:use-module (rde features system)
  #:use-module (lotus-rde features mfs)
  #:export (;; feature-file-database-services
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
            ;; feature-krberos-services
            define-lotus-machine-features))


(define (assert condition . msg)
  (throw-message
   condition
   (if (null? msg)
       (list "Assertion failed")
       msg)))


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


(define* (define-lotus-machine-features hostname
           #:key
           (disk-serial-id-system "aaa")
           (disk-serial-id-home "aaa")
           (fs-boot-efi-partition (uuid "0000-0000" 'fat32))
           (kernel linux-libre)
           (firmware '())
           (kernel-arguments '())
           (initrd base-initrd)
           (custom-services #f))
  (list (feature-host-info #:host-name hostname
                           ;; #:locale    (operating-system-locale bare-bone-os)
                           ;; ls `guix build tzdata`/share/zoneinfo
                           #:timezone "Asia/Kolkata")
        (feature-kernel #:kernel kernel
                        #:initrd initrd
                        #:firmware firmware
                        #:kernel-arguments kernel-arguments)
        (feature-bootloader #:bootloader-configuration (bootloader-configuration (bootloader grub-bootloader)
                                                                                 (targets    '())))
                                                                                 ;; (keyboard-layout %lotus-keyboard-layout)
                                                                                 ;; (menu-entries    %lotus-grub-ubuntu-menuentries)
        ;; Allows to declare specific bootloader configuration,
        ;; grub-efi-bootloader used by default
        ;; (feature-bootloader)

        (feature-mapped-file-systems #:disk-serial-id-system disk-serial-id-system
                                     #:disk-serial-id-home disk-serial-id-home
                                     #:fs-boot-efi-partition fs-boot-efi-partition)
        (feature-base-services)
        ;; (feature-desktop-services)

        ;; (feature-file-database-services)
        ;; ;; (feature-guix-publish-services)
        ;; (feature-schedular-services)
        ;; (feature-unattended-upgrade-services)
        ;; (feature-disk-services)
        ;; (feature-privileged-programs-services)
        ;; (feature-messaging-services)
        ;; (feature-mail-services)
        ;; (feature-iio-sensor-proxy-services)
        ;; (feature-network-manager-services)

        ;; (feature-dns-services)
        ;; (feature-pointer-services)
        ;; (feature-bluetooth-services)

        ;; ;; (feature-music-services)
        ;; ;; (feature-printing-services)
        ;; ;; (feature-polkit-services)
        ;; ;; (feature-krberos-services)
        ;; (feature-container-sevices)
        ;; (feature-security-services)
        ;; (feature-audit-services)
        ;; (feature-guix-services)
        ;; (feature-desktop-manager-service)
        ;; (feature-pulseaudio-service)
        (feature-networking)
        (feature-shepherd)
        (feature-custom-services #:feature-name-prefix 'openssh-server-extra
                                 #:system-services (list
                                                    ;; (service dhcp-client-service-type)
                                                    ;; (service cloud-init-service-type)
                                                    (service openssh-service-type)))))


