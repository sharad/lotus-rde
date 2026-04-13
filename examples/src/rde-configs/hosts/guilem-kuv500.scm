(define-module (rde-configs hosts guilem-kuv500)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (lotus-rde api utils)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (rde-configs default)
  #:use-module (ice-9 match))







(define* (feature-file-database
          #:key
          (package findutils)
          (schedule "0 4 * * *")
          (excluded-directories '("/tmp" "/var/tmp" "/gnu/store" "/run")))
  (feature
   (name 'file-database)
   (values
    (rde-system-services
     (list
      (service package-database-service-type)
      (service file-database-service-type
               (file-database-configuration
                (package              findutils)
                (schedule             schedule)
                (excluded-directories excluded-directories))))))))

;; https://guix.gnu.org/es/blog/2020/improve-internationalization-support-for-the-guix-data-service/
;; https://guix.gnu.org/en/blog/2020/introduction-to-the-guix-data-service-the-missing-blog-post/
;; https://data.guix.gnu.org/README
;; https://guix.gnu.org/manual/en/html_node/Guix-Services.html
;; https://guix.gnu.org/manual/en/guix.html#Debugging-Build-Failures
;; https://guix.gnu.org/manual/en/html_node/Continuous-Integration.html
;; https://guix.gnu.org/manual/en/html_node/Base-Services.html


(define* (feature-guix-publish
          #:key
          (advertise #t)
          (port 3000)
          (host "0.0.0.0")
          (compression '(("lzip" 7) ("gzip" 9)))
          (cache "/var/cache/guix/publish")
          (cache-bypass-threshold (* 100 1024 1024))
          (ttl (* 1 24 60 60)))

  (feature
   (name 'guix-publish)
   (values
    (rde-system-services
     (list
      (service guix-publish-service-type
               (guix-publish-configuration
                (advertise?             advertise)
                (port                   port)
                (host                   host)
                (compression            compression)
                (cache                  cache)
                (cache-bypass-threshold cache-bypass-threshold)
                (ttl                    ttl))))))))


;; Vixie cron schedular
(define updatedb-job
  ;; Run 'updatedb' at 3AM every day.  Here we write the
  ;; job's action as a Scheme procedure.
  #~(job '(next-hour '(3))
         (lambda ()
           (execl (string-append #$findutils "/bin/updatedb")
                  ;; "updatedb"
                  "--prunepaths=`/tmp /var/tmp /gnu/store /run'"))))

(define garbage-collector-job
  ;; Collect garbage 5 minutes after midnight every day.
  ;; The job's action is a shell command.
  #~(job "5 0 * * *"            ;Vixie cron syntax
         "guix gc -F 1G"))

(define idutils-job
  ;; Update the index database as user "charlie" at 12:15PM
  ;; and 19:15PM.  This runs from the user's home directory.
  #~(job '(next-minute-from (next-hour '(12 19)) '(15))
         (string-append #$idutils "/bin/mkid src")
         #:user "s"))

(define* (feature-mcron
          #:key
          (jobs (list garbage-collector-job
                 ;; idutils-job
                 updatedb-job)))

  (feature
   (name 'mcron)
   (values
    (rde-system-services
     (list
      (service mcron-service-type
               (mcron-configuration
                (jobs jobs))))))))


;; https://guix.gnu.org/manual/en/html_node/Unattended-Upgrades.html
;; How to mount /boot and that as rw?
;; Check also these https://guix.gnu.org/manual/en/html_node/Service-Reference.html
(define %lotus-unattended-upgrade-services (list (service unattended-upgrade-service-type
                                                          (unattended-upgrade-configuration
                                                           (operating-system-file (file-append "/run/current-system/etc/config/config.scm"))
                                                           (services-to-restart '(mcron))
                                                           (channels #~%default-channels)
                                                           (schedule "30 01 * * 0")
                                                           (system-expiration (* 3 30 24 3600))
                                                           (maximum-duration 3600)
                                                           (log-file "/var/log/unattended-upgrade.log")))))


;;  NOT ADDED
;; https://guix.gnu.org/manual/en/html_node/Desktop-Services.html
(define %lotus-udisks-services (list (service udisks-service-type)))
(define %lotus-gnome-keyring-services (list (service gnome-keyring-service-type)))


(define* (feature-privileged-programs
          #:key
          (programs '()))

  (feature
   (name 'privileged-programs)
   (values
    (rde-system-services
     (list
      (simple-service
       'privileged-programs
       privileged-program-service-type
       programs))))))

;; ;; https://git.sr.ht/~boeg/home/tree/master/.config/guix/system/config.scm
;; ;; https://git.savannah.gnu.org/cgit/guix.git/tree/gnu/services/desktop.scm#n1209
;; (define %lotus-privilege-services (list (simple-service 'lotus-privilege
;;                                                         privileged-program-service-type
;;                                                         (map (lambda (program)
;;                                                                (privileged-program (program program)
;;                                                                                    (setuid? #t)))
;;                                                              (list (file-append ecryptfs-utils "/sbin/mount.ecryptfs_private")
;;                                                                    (file-append ecryptfs-utils "/sbin/umount.ecryptfs_private")
;;                                                                    (file-append xtrlock "/bin/xtrlock")
;;                                                                    (file-append firejail "/bin/firejail"))))))


;; TODO
;; https://github.com/xavierm02/guix-config/blob/master/config.scm
;; (simple-service 'i3-packages
;;                 profile-service-type
;;                 (list dmenu i3-wm i3lock i3status))


(define* (feature-bitlbee
          #:key
          (plugins '()))

  ;; (service bitlbee-service-type
  ;;          (bitlbee-configuration
  ;;           (plugins (if %lotus-bitlbee-service-use-default? '() (if nongnu-desktop?
  ;;                                                                    (list skype4pidgin)
  ;;                                                                    '())))
  ;;           (bitlbee (if %lotus-bitlbee-service-use-default? bitlbee bitlbee-purple))))

  (feature
   (name 'bitlbee)
   (values
    (rde-system-services
     (list
      (service bitlbee-service-type
               (bitlbee-configuration
                (plugins plugins))))))))



(define* (feature-mail-aliases
          #:key
          (aliases '(("postmaster" "bob")
                     ("bob"        "bob@example.com" "bob@example2.com"))))
  ;; https://guix.gnu.org/manual/en/html_node/Mail-Services.html
  (feature
   (name 'mail-aliases)
   (values
    (rde-system-services
     (list
      (service mail-aliases-service-type aliases)
      (service dovecot-service-type
               (dovecot-configuration
                (mail-location "maildir:~/.maildir")
                (listen        '("127.0.0.1"))))
      (service exim-service-type
       (exim-configuration
        (config-file #f))))))))



(define %iio-sensor-proxy-services (list (service iio-sensor-proxy-service-type)))






;; https://notabug.org/thomassgn/guixsd-configuration/src/master/config.scm
;; https://guix.gnu.org/manual/en/html_node/Networking-Services.html
;; https://jonathansblog.co.uk/using-dnsmasq-as-an-internal-dns-server-to-block-online-adverts
;; https://stackoverflow.com/questions/48644841/multiple-addn-hosts-conf-in-dnsmasq
(define %lotus-dnsmasq-services (list (service dnsmasq-service-type
                                               (dnsmasq-configuration (no-resolv? #t)
                                                                      (local-service? #t)))))

;; https://guix.gnu.org/manual/en/html_node/Networking-Services.html
(define %lotus-network-manager-services (list (service network-manager-service-type
                                                       (network-manager-configuration (dns %lotus-network-manager-dns)))))

(define %lotus-avahi-services (list (service avahi-service-type)))





(define %lotus-gpm-services  (list (service gpm-service-type)))


(define* (feature-bluetooth
          #:key (auto-enable? #t))
  ;; https://unix.stackexchange.com/questions/617858/how-to-enable-bluetooth-in-guix
  (feature
   (name 'bluetooth)
   (values
    (rde-system-services
     (list
      (service bluetooth-service-type
               (bluetooth-configuration
                (auto-enable? auto-enable?))))))))


(define* (feature-mpd
          #:key
          (music-dir "~/Music"))

  (feature
   (name 'mpd)
   (values
    (rde-system-services
     (list
      (service mpd-service-type
               (mpd-configuration
                (music-directory music-dir))))))))

;; (define %lotus-audio-services (list (service mpd-service-type
;;                                              (mpd-configuration
;;                                               (auto-update? #t)
;;                                               (user  (car %lotus-simple-users))
;;                                               (group (car %lotus-simple-groups))
;;                                               (log-file "/var/log/mpd.log")
;;                                               (log-level "verbose")
;;                                               (state-file (string-append %lotus-account-home-directory "/Music/.mpd/state-file"))
;;                                               (sticker-file (string-append %lotus-account-home-directory "/Music/.mpd/sticker-file"))
;;                                               (db-file   (string-append %lotus-account-home-directory "/Music/.mpd/db"))
;;                                               (music-directory (string-append %lotus-account-home-directory "/Music"))
;;                                               (playlist-directory (string-append %lotus-account-home-directory "/Music/.mpd/playlists"))
;;                                               (outputs
;;                                                (list (mpd-output (name "Pulseaudio Sound Server")
;;                                                                  (type "pulse")
;;                                                                  ;; (mixer-type 'null)
;;                                                                  ;; (extra-options
;;                                                                  ;;  `((encoder . "vorbis")
;;                                                                  ;;    (port    . "8080")))
;;                                                                  (enabled?   #t)
;;                                                                  (always-on? #f)
;;                                                                  (mixer-type "software"))
;;                                                      (mpd-output (name "PipeWire Sound Server")
;;                                                                  (type "pipewire")
;;                                                                  (enabled?   #f))))))))


;; https://github.com/alezost/guix-config/blob/master/system-config/os-main.scm
(define %lotus-mingetty-services (list (service mingetty-service-type
                                                (mingetty-configuration (tty "tty1")))
                                       (service mingetty-service-type
                                                (mingetty-configuration (tty "tty2")))
                                       (service mingetty-service-type
                                                (mingetty-configuration (tty "tty3")))
                                       (service mingetty-service-type
                                                (mingetty-configuration (tty "tty4")))
                                       (service mingetty-service-type
                                                (mingetty-configuration (tty "tty5")))
                                       (service mingetty-service-type
                                                (mingetty-configuration (tty "tty6")))))


(define %lotus-cups-services (list (service cups-service-type
                                            (cups-configuration (web-interface? #t)
                                                                (default-paper-size "A4")
                                                                (extensions (list cups-filters
                                                                                  hplip-minimal))))))


;; https://github.com/alezost/guix-config/blob/master/system-config/os-main.scm
;; (define %lotus-polkit-services (list (service polkit-service-type)))
(define %lotus-polkit-services (list))


(define %lotus-krb5-services (if %lotus-system-init
                                 (list)
                                 (list (if (cadr (assoc #:default %lotus-default-realm))
                                           (service krb5-service-type
                                                    (krb5-configuration
                                                     (default-realm (cadr (assoc #:default %lotus-default-realm)))
                                                     (allow-weak-crypto? #t)
                                                     (realms (cdr (assoc #:realms %lotus-default-realm)))))
                                           (service krb5-service-type (krb5-configuration))))))


(define %lotus-docker-services (list (service containerd-service-type)
                                     (service docker-service-type)))


(define %lotus-security-services  (list (service pcscd-service-type
                                                 (pcscd-configuration (pcsc-lite pcsc-lite)
                                                                      (usb-drivers (list ccid))))
                                        (service fail2ban-service-type
                                                 (fail2ban-configuration
                                                  (extra-jails (list (fail2ban-jail-configuration
                                                                      (name "sshd")
                                                                      (enabled? #t))))))))

(define %lotus-spice-services (list (service spice-vdagent-service-type)))

(define %lotus-audit-services (list (service auditd-service-type
                                             (auditd-configuration
                                              (audit audit)
                                              (configuration-directory %default-auditd-configuration-directory)))))

;; services modifications


(define %lotus-desktop-general-services %desktop-services)

(set! %lotus-desktop-general-services (modify-services
                                          %lotus-desktop-general-services
                                        (network-manager-service-type config =>
                                                                      (network-manager-configuration (inherit config)
                                                                                                     ;; (vpn-plugins '("network-manager-openconnect"))
                                                                                                     (vpn-plugins (list network-manager-fortisslvpn
                                                                                                                        network-manager-openconnect))
                                                                                                     (dns "dnsmasq")))))

(set! %lotus-desktop-general-services (modify-services
                                          %lotus-desktop-general-services
                                        ;; https://gitlab.com/Efraim/guix-config/blob/master/macbook41_config.scm
                                        (guix-service-type config =>
                                                           (guix-configuration (inherit config)
                                                                               (discover?        %lotus-guix-configuration-discover) ;; (default: #f)
                                                                               (build-accounts   %lotus-guix-configuration-build-accounts) ;; (default: 10)
                                                                               (authorize-key?   %lotus-guix-configuration-authorize-key?) ;; (default: #t)
                                                                               ;; https://guix.gnu.org/manual/en/html_node/Base-Services.html
                                                                               (tmpdir           (if %lotus-system-init
                                                                                                     #f
                                                                                                     %lotus-guix-configuration-tmpdir))
                                                                               (use-substitutes? %lotus-guix-configuration-use-substitutes)
                                                                               (substitute-urls  (append %default-substitute-urls
                                                                                                         %lotus-guix-configuration-substitute-urls ;public urls
                                                                                                         %lotus-guix-configuration-local-substitute-urls ;local working urls
                                                                                                         %lotus-guix-configuration-local-fixed-named-substitute-urls)) ;local fixed named (may not be working) urls
                                                                               ;; https://guix.gnu.org/manual/en/html_node/Getting-Substitutes-from-Other-Servers.html
                                                                               (authorized-keys  (append %default-authorized-guix-keys
                                                                                                         (local-authorized-guix-keys "/etc/config/keys")
                                                                                                         (local-authorized-guix-keys "/etc/config/local"))) ;; https://issues.guix.gnu.org/39819
                                                                               (extra-options    %lotus-guix-configuration-extra-options)))))

;; https://issues.guix.info/issue/35674
(when #t
  (set! %lotus-desktop-general-services (modify-services
                                            %lotus-desktop-general-services
                                          (gdm-service-type config =>
                                                            (gdm-configuration (inherit config)
                                                                               (xorg-configuration
                                                                                (xorg-configuration
                                                                                 (keyboard-layout %lotus-keyboard-layout)))
                                                                               (allow-empty-passwords? %lotus-gdm-allow-empty-password)
                                                                               (auto-login?            %lotus-gdm-auto-login)
                                                                               (default-user           %lotus-account-user-name))))))
(when #f
  ;; https://www.mail-archive.com/search?l=help-guix@gnu.org&q=subject:%22Re%5C%3A+Guix+Bluetooth+Headset%22&o=newest&f=1
  (set! %lotus-desktop-general-services (modify-services
                                            %lotus-desktop-general-services
                                          (pulseaudio-service-type config =>
                                                                   (pulseaudio-configuration
                                                                    (inherit config)
                                                                    (script-file (local-file "/etc/guix/default.pa")))))))

;; services add


(define %lotus-desktop-services %lotus-desktop-general-services)


(define %lotus-network-services  (list (service openssh-service-type)))
                                       ;; (service tor-service-type)


(define %lotus-gui-desktop-services (list (service gnome-desktop-service-type)))


(define %lotus-heavy-wm-services (list (service gnome-desktop-service-type)
                                       (service xfce-desktop-service-type)
                                       (service mate-desktop-service-type)
                                       (service enlightenment-desktop-service-type)))

(define %lotus-many-services (append %lotus-network-services
                                     %lotus-heavy-wm-services))

(define %lotus-few-services  (append %lotus-gui-desktop-services
                                     %lotus-network-services))


(define %lotus-simple-services %lotus-few-services)

(define %lotus-simple-and-desktop-services (append %lotus-simple-services
                                                   %lotus-mail-aliases-services
                                                   %iio-sensor-proxy-services
                                                   %lotus-dovecot-services
                                                   %lotus-gpm-services
                                                   %lotus-bluez-services
                                                   %lotus-audio-services
                                                   %lotus-file-serach-services
                                                   %lotus-publish-services
                                                   %lotus-mcron-services
                                                   %lotus-cups-services
                                                   %lotus-polkit-services
                                                   %lotus-krb5-services
                                                   %lotus-privilege-services
                                                   %lotus-bitlbee-services
                                                   %lotus-desktop-services
                                                   %lotus-local-services
                                                   %lotus-docker-services
                                                   %lotus-security-services
                                                   %lotus-spice-services
                                                   %lotus-audit-services))


(define %lotus-base-services %base-services)

(define %lotus-base-with-dhcp-services
  (append (list (service dhcpcd-service-type))
          %lotus-network-services
          %lotus-base-services))

(define %lotus-base-with-nm-wifi-services
  (append (list (service network-manager-service-type)
                (service wpa-supplicant-service-type))
          %lotus-network-services
          %lotus-base-services))

(define %lotus-base-with-gui-nm-wifi-services
  (append %lotus-network-services
          %lotus-desktop-services))


(define %lotus-system-init-services %lotus-base-with-gui-nm-wifi-services)

(define %lotus-system-post-init-services %lotus-simple-and-desktop-services)





;; (define btrfs-subvolumes
;;   (map (match-lambda
;;          ((subvol . mount-point)
;;           (file-system
;;             (type "btrfs")
;;             (device "/dev/mapper/enc")
;;             (mount-point mount-point)
;;             (options (format #f "subvol=~a" subvol))
;;             (dependencies ixy-mapped-devices))))
;;        '((@ . "/")
;;          (@boot . "/boot")
;;          (@gnu  . "/gnu")
;;          (@home . "/home")
;;          (@data . "/data")
;;          (@var-log . "/var/log")
;;          (@swap . "/swap"))))


(define guilem-kuv500-services
  (feature-custom-services
   #:feature-name-prefix 'cloud-extra
   #:system-services
   (list
    (service dhcp-client-service-type)
    (service cloud-init-service-type)
    (service openssh-service-type
             (openssh-configuration
              (openssh openssh-sans-x)
              (permit-root-login #t)
              (password-authentication? #f)
              (authorized-keys
               `(("root"
                  ,(local-file
                    (canonicalize-path
                     (find-resource-in-load-path
                      "rde-configs/files/ssh/public-keys/abcdw"))))))))
    sudoers-extra-service)))



(define my-features
  (list
   (feature-host-info
    #:host-name "my-machine"
    #:timezone "Asia/Kolkata")

   ;; THIS replaces %desktop-services
   (feature-base-services)
   (feature-desktop-services)

   ;; session stack
   (feature-dbus)
   (feature-polkit)
   (feature-elogind)

   ;; display stack
   ;; (feature-wayland)

   ;; your stuff
   (feature-file-systems ...)
   (feature-hidpi)))


(define-public guilem-kuv500-features
  (list (feature-host-info #:host-name "guilem-kuv500"
                             ;; ls `guix build tzdata`/share/zoneinfo
                             #:timezone "Asia/Kolkata")
          ;; Allows to declare specific bootloader configuration,
          ;; grub-efi-bootloader used by default
          ;; (feature-bootloader)
        (let-values (((rootfs sys-devices sys-fs) (devfs-system #:disk-serial-id "aaaa"
                                                                #:fs-boot-efi-partition (uuid "0000-0000" 'fat32)))
                     ((home-devices home-fs) (devfs-system #:disk-serial-id)))
          (feature-file-systems #:mapped-devices (append sys-devices home-devices)
                                #:file-systems (append sys-fs home-fs)))
          ;; (feature-kanshi #:extra-config `((profile laptop
          ;;                                           ((output eDP-1 enable)))
          ;;                                  (profile docked
          ;;                                           ((output eDP-1 enable)
          ;;                                            (output DP-2 scale 2)))))
          ;; (feature-hidpi)
        guilem-kuv500-services

        (feature-base-services)
        (feature-desktop-services)

        ;; session stack
        (feature-dbus)
        (feature-polkit)
        (feature-elogind)

        ;; display stack
        ;; (feature-wayland)

        ;; your stuff
        (feature-file-systems ...)
        (feature-hidpi)))


