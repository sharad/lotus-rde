
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
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages mate)
  #:use-module (gnu packages enlightenment)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features guile)
  #:use-module (rde features linux)
  #:use-module (rde features networking)
  #:use-module (rde features shells)
  #:use-module (rde features system)
  #:use-module (rde features image-viewers)
  #:use-module (rde packages)
  #:use-module (lotus-rde features base)
  #:use-module (lotus-rde features mfs)
  #:export (lotus-metal-machine
            lotus-metal-machine-minimal))



(define %lotus-guix-substitute-urls '(;; "https://ci.guix.gnu.org"
                                      ;; "https://bayfront.guixsd.org"
                                      ;; "http://guix.genenetwork.org" -- Backtrace
                                      ;; "https://berlin.guixsd.org"
                                      "https://cuirass.genenetwork.org"
                                      "https://guix.tobias.gr"
                                      "https://bordeaux.guix.gnu.org"
                                      "https://ci.guix.info/"
                                      "https://berlin.guix.gnu.org"
                                      "https://cache-cdn.guix.moe"
                                      "https://substitutes.nonguix.org"
                                      "https://nonguix-proxy.ditigal.xyz"
                                      "https://mirror.brielmaier.net"))

(define %lotus-system-packages '("gdm"
                                 "gpm"
                                 "slock" ; need suid
                                 "zsh"
                                 "stumpwm"
                                 "stumpwm-gnome"
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
                             (disk-serial-id-system "aaa")
                             (disk-serial-id-home "aaa")
                             (fs-boot-efi-partition (uuid "0000-0000" 'fat32))
                             (bootloader-targets (match (getenv "RDE_TARGET")
                                                   ("init" fs-boot-efi-partition)
                                                   (_ '())))
                             (kernel linux-libre)
                             (firmware '())
                             (kernel-arguments '())
                             (initrd base-initrd)
                             (initrd-modules %lotus-guix-initrd-modules)
                             (custom-services #f)
                             (login-shell (file-append zsh "/bin/zsh"))
                             (parent-dir "/srv/volumes/local")
                             (volume-mappings '()))


  (list (feature-keyboard #:keyboard-layout (keyboard-layout "us" "altgr-intl"))
        (feature-host-info #:host-name hostname
           ;; #:locale    (operating-system-locale bare-bone-os)
           ;; ls `guix build tzdata`/share/zoneinfo
           #:timezone timezone)
        (feature-kernel #:kernel kernel
                        #:initrd initrd
                        #:initrd-modules initrd-modules
                        #:firmware firmware
                        #:kernel-arguments kernel-arguments)
        (feature-bootloader #:bootloader-configuration
                            (bootloader-configuration (bootloader grub-efi-bootloader)
                                                      (targets    bootloader-targets)))
        ;; (keyboard-layout %lotus-keyboard-layout)
        ;; (menu-entries    %lotus-grub-ubuntu-menuentries)
        ;; Allows to declare specific bootloader configuration,
        ;; grub-efi-bootloader used by default
        ;; (feature-bootloader)
        (feature-mapped-file-systems #:disk-serial-id-system disk-serial-id-system
                                     #:disk-serial-id-home disk-serial-id-home
                                     #:fs-boot-efi-partition fs-boot-efi-partition
                                     #:parent-dir parent-dir
                                     #:volume-mappings volume-mappings)
        ;; (feature-base-services #:guix-substitute-urls %lotus-guix-substitute-urls
        ;;                        #:guix-authorized-keys '())

        ;; (feature-users-group)
        (feature-base-packages #:system-packages
                               (apply strings->packages %lotus-system-packages))

        (feature-ssh-daemon-services)

        ;; (feature-logger-services)
        ;; (feature-loopback-services)
        (feature-lotus-base-services)
        (feature-lotus-desktop-services)
        ;; (feature-zsh #:default-shell? #t)
        (feature-login-shell #:login-shell login-shell)

        (feature-substitutes)

        (feature-gnome-desktop-services)
        (feature-file-database-services)
        ;; ;; (feature-guix-publish-services)
        (feature-schedular-services)
        ;; (feature-unattended-upgrade-services)


        ;; (feature-disk-services)
        (feature-privileged-programs-services)


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

        ;; (feature-networking #:mdns? #t)
        (feature-shepherd)))
        ;; (feature-custom-services #:feature-name-prefix 'extra
        ;;                          #:system-services %desktop-services)



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
                                                                                 ;; (keyboard-layout %lotus-keyboard-layout)
                                                                                 ;; (menu-entries    %lotus-grub-ubuntu-menuentries)
        ;; Allows to declare specific bootloader configuration,
        ;; grub-efi-bootloader used by default
        ;; (feature-bootloader)
        (feature-mapped-file-systems #:disk-serial-id-system disk-serial-id-system
                                     #:disk-serial-id-home disk-serial-id-home
                                     #:fs-boot-efi-partition fs-boot-efi-partition)
        (feature-base-services #:guix-substitute-urls %lotus-guix-substitute-urls
                               #:guix-authorized-keys '())
        (feature-shepherd)))


