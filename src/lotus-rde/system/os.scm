
(define-module (lotus-rde system os)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-11)
  #:use-module (guix gexp)
  #:use-module (gnu system uuid)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services ssh)
  #:use-module (gnu services xorg)
  #:use-module (gnu services desktop)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages mate)
  #:use-module (gnu packages enlightenment)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features guile)
  #:use-module (rde features keyboard)
  #:use-module (rde features linux)
  #:use-module (rde features networking)
  #:use-module (rde features shells)
  #:use-module (rde features system)
  #:use-module (rde features emacs)
  #:use-module (rde features image-viewers)
  #:use-module (rde features xdg)
  #:use-module (rde packages)
  #:use-module (lotus-rde lib utils)
  #:use-module (lotus-rde features base)
  #:use-module (lotus-rde features mfs)
  #:use-module (lotus-rde features networking)
  #:export (lotus-metal-machine
            lotus-experimental-machine
            lotus-metal-machine-minimal))




(define %lotus-system-packages '(;; "gdm"
                                 ;; "gpm"
                                 "slock" ; need suid
                                 "zsh"
                                 "stumpwm"
                                 ;; "stumpwm-gnome"
                                 "sbcl"
                                 "sbcl-stumpwm-cpu"
                                 "sbcl-stumpwm-mem"
                                 "sbcl-stumpwm-numpad-layouts"
                                 "sbcl-stumpwm-screenshot"
                                 "sbcl-stumpwm-winner-mode"
                                 "sbcl-dbus"
                                 "libfixposix"
                                 "pkg-config"
                                 "cl-fad"
                                 "cl-slime-swank"))

(define %lotus-kernel-arguments '("usbcore.autosuspend=-1"
                                  "libata.force=2:disable"
                                  "libata.noacpi=1"
                                  "libata.ignore_hpa=1"
                                  "--verbose"
                                  "nosplash"
                                  "debug"))

(define %lotus-guix-initrd-modules '())

(define %lotus-nonguix-initrd-modules '("mptbase"
                                        "mptscsih"
                                        "mptspi"
                                        "virtio_net"
                                        "vmwgfx"))




(define* (lotus-metal-machine hostname
                             #:key
                             (timezone "Asia/Kolkata")
                             (locale "en_US.utf8")
                             (locale-names (list "en_US"
                                                 "hi_IN"
                                                 "ur_PK"
                                                 "fa_IR"
                                                 "ar_SA"))
                             (disk-serial-id-system "aaa")
                             (disk-serial-id-home "aaa")
                             (fs-boot-efi-partition (uuid "0000-0000" 'fat32))
                             (bootloader-targets (let ((rde-sysinit (getenv "RDE_SYSINIT")))
                                                   (match rde-sysinit
                                                     (#f '())
                                                     ("init" (list fs-boot-efi-partition))
                                                     (_ '()))))
                             (kernel linux-libre)
                             (firmware '())
                             (kernel-arguments '())
                             (keyboard-layout (keyboard-layout "us" "altgr-intl"))
                             (initrd base-initrd)
                             (initrd-modules %lotus-guix-initrd-modules)
                             (custom-services #f)
                             (login-shell (file-append zsh "/bin/zsh"))
                             (parent-dir "/srv/volumes/local")
                             (volume-mappings '())
                             (networking-iwd? #t)
                             (nm-dns "dnsmasq")
                             (nm-vpn-plugins (list network-manager-fortisslvpn
                                                   network-manager-openconnect))
                             (gdm-auto-login? #t)
                             (gdm-allow-empty-password? #t))

  (when (> (length bootloader-targets) 0)
    (ensure-rw-mount "/boot")
    (ensure-rw-mount "/boot/efi"))

  (list (feature-host-info #:host-name hostname
                           #:locale locale
                           #:timezone timezone)
        (feature-locale-names #:locale-names locale-names)
        (feature-kernel #:kernel kernel
                        #:initrd initrd
                        #:initrd-modules initrd-modules
                        #:firmware firmware
                        #:kernel-arguments kernel-arguments)
        (feature-bootloader #:bootloader-configuration
                            (bootloader-configuration
                              (bootloader grub-efi-bootloader)
                              (targets    bootloader-targets)))
        (feature-hidpi)
        ;; (keyboard-layout %lotus-keyboard-layout)
        ;; (menu-entries    %lotus-grub-ubuntu-menuentries)
        ;; Allows to declare specific bootloader configuration,
        ;; grub-efi-bootloader used by default
        ;; (feature-bootloader)
        (feature-keyboard #:keyboard-layout
                          keyboard-layout)
        (feature-mapped-file-systems #:disk-serial-id-system disk-serial-id-system
                                     #:disk-serial-id-home disk-serial-id-home
                                     #:fs-boot-efi-partition fs-boot-efi-partition
                                     #:parent-dir parent-dir
                                     #:volume-mappings volume-mappings)
        ;; (feature-users-group)
        (feature-base-packages #:system-packages
                               (apply strings->packages
                                      %lotus-system-packages))

        (feature-ssh-daemon-services)

        ;; (feature-logger-services)
        ;; (feature-loopback-services)
        (feature-lotus-base-services)
        (feature-lotus-desktop-services #:dns nm-dns
                                        #:vpn-plugins nm-vpn-plugins)
        (feature-display-manager-services #:allow-empty-password? gdm-allow-empty-password?
                                          #:auto-login? gdm-auto-login?)
        ;; (feature-zsh #:default-shell? #t)
        (feature-login-shell #:login-shell login-shell)

        (feature-substitutes)

        (feature-gnome-desktop-services)
        (feature-file-database-services)
        ;; ;; (feature-guix-publish-services)

        ;; (feature-schedular-services)
        ;; (feature-unattended-upgrade-services)


        ;; (feature-disk-services)
        (feature-privileged-programs-services 'firejail-setuid-helpers
                                              #:paths
                                              (list (file-append firejail "/bin/firejail")))
        (feature-privileged-programs-services 'xtrlock-setuid-helpers
                                              #:paths
                                              (list (file-append xtrlock "/bin/xtrlock")))
        (feature-privileged-programs-services 'mount-ecryptfs-setuid-helpers
                                              #:paths
                                              (list (file-append ecryptfs-utils "/sbin/mount.ecryptfs_private")
                                                    (file-append ecryptfs-utils "/sbin/umount.ecryptfs_private")))


        ;; (feature-messaging-services)
        ;; (feature-mail-services)
        (feature-iio-sensor-proxy-services)
        ;; (feature-network-manager-services)

        ;; (feature-dns-services)
        (feature-pointer-services)
        (feature-bluetooth-services)
        (feature-pipewire)
        (feature-imv)

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

        (feature-lotus-networking #:mdns? #t
                                  #:iwd? networking-iwd?
                                  #:iwd-autoconnect? #t
                                  #:dns nm-dns
                                  #:vpn-plugins nm-vpn-plugins)
        ;; (feature-custom-services #:feature-name-prefix 'extra
        ;;                          #:system-services %desktop-services)
        (feature-shepherd)))




(define* (lotus-experimental-machine hostname
                                     #:key
                                     (timezone "Asia/Kolkata")
                                     (locale "en_US.utf8")
                                     (locale-names (list "en_US"
                                                         "hi_IN"
                                                         "ur_PK"
                                                         "fa_IR"
                                                         "ar_SA"))
                                     (disk-serial-id-system "aaa")
                                     (disk-serial-id-home "aaa")
                                     (fs-boot-efi-partition (uuid "0000-0000" 'fat32))
                                     (bootloader-targets (let ((rde-sysinit (getenv "RDE_SYSINIT")))
                                                           (match rde-sysinit
                                                             (#f '())
                                                             ("init" (list fs-boot-efi-partition))
                                                             (_ '()))))
                                     (kernel linux-libre)
                                     (firmware '())
                                     (kernel-arguments '())
                                     (keyboard-layout (keyboard-layout "us" "altgr-intl"))
                                     (initrd base-initrd)
                                     (initrd-modules %lotus-guix-initrd-modules)
                                     (custom-services #f)
                                     (login-shell (file-append zsh "/bin/zsh"))
                                     (parent-dir "/srv/volumes/local")
                                     (volume-mappings '())
                                     (nm-dns "dnsmasq")
                                     (nm-vpn-plugins (list network-manager-fortisslvpn
                                                           network-manager-openconnect))
                                     (gdm-auto-login? #t)
                                     (gdm-allow-empty-password? #t))
  (lotus-metal-machine hostname
                       #:timezone timezone
                       #:locale locale
                       #:locale-names locale-names
                       #:disk-serial-id-system disk-serial-id-system
                       #:disk-serial-id-home disk-serial-id-home
                       #:fs-boot-efi-partition fs-boot-efi-partition
                       #:bootloader-targets bootloader-targets
                       #:kernel kernel
                       #:firmware firmware
                       #:kernel-arguments kernel-arguments
                       #:keyboard-layout keyboard-layout
                       #:initrd initrd
                       #:initrd-modules initrd-modules
                       #:custom-services custom-services
                       #:login-shell login-shell
                       #:parent-dir parent-dir
                       #:volume-mappings volume-mappings
                       #:nm-dns nm-dns
                       #:nm-vpn-plugins nm-vpn-plugins
                       #:gdm-auto-login? gdm-auto-login?
                       #:gdm-allow-empty-password? gdm-allow-empty-password?))

(define* (lotus-metal-machine-minimal hostname
                                #:key
                                (timezone "Asia/Kolkata")
                                (disk-serial-id-system "aaa")
                                (disk-serial-id-home "aaa")
                                (fs-boot-efi-partition (uuid "0000-0000" 'fat32))
                                (bootloader-targets '())
                                (kernel linux-libre)
                                (firmware '())
                                (kernel-arguments '())
                                (initrd base-initrd)
                                (initrd-modules '())
                                (custom-services #f))
  (list (feature-host-info #:host-name hostname
                           ;; #:locale    (operating-system-locale bare-bone-os)
                           ;; ls `guix build tzdata`/share/zoneinfo
                           #:timezone timezone)
        (feature-kernel #:kernel kernel
                        #:initrd initrd
                        #:initrd-modules initrd-modules
                        #:firmware firmware
                        #:kernel-arguments kernel-arguments)
        (feature-bootloader #:bootloader-configuration (bootloader-configuration (bootloader grub-efi-bootloader)
                                                                                 (targets    bootloader-targets)))
        ;;                                                                          (menu-entries    %lotus-grub-ubuntu-menuentries)
        ;; Allows to declare specific bootloader configuration,
        ;; grub-efi-bootloader used by default
        ;; (feature-bootloader)
        (feature-mapped-file-systems #:disk-serial-id-system disk-serial-id-system
                                     #:disk-serial-id-home disk-serial-id-home
                                     #:fs-boot-efi-partition fs-boot-efi-partition)
        (feature-base-services)
        (feature-shepherd)))


