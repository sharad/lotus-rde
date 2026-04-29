
(define-module (lotus-rde system os)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-11)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu system uuid)
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
  #:use-module (rde packages)
  #:use-module (lotus-rde features mfs)
  #:export (feature-lotus-machine
            feature-lotus-machine-minimal))



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

(define %lotus-system-packages (strings->packages "stumpwm"
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

(define %lotus-kernel-arguments (list "usbcore.autosuspend=-1"
                                      "libata.force=2:disable"
                                      "libata.noacpi=1"
                                      "libata.ignore_hpa=1"
                                      "--verbose"
                                      "nosplash"
                                      "debug"))


(define* (feature-lotus-machine hostname
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

  ;; (initrd-modules '("virtio.ko"
  ;;                   "virtio_balloon.ko"
  ;;                   "virtio_ring.ko"
  ;;                   "virtio_blk.ko"
  ;;                   "virtio_pci.ko"
  ;;                   ;; https://issues.guix.gnu.org/31887
  ;;                   "mptbase.ko"
  ;;                   "mptscsih.ko"
  ;;                   "mptspi.ko"
  ;;                   "virtio_net.ko"))

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
        (feature-base-packages #:system-packages %lotus-system-packages)
        (feature-desktop-services)

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








(define* (feature-lotus-machine-minimal hostname
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
