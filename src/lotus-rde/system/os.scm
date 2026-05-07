
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
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features guile)
  #:use-module (rde features networking)
  #:use-module (rde features shells)
  #:use-module (rde features system)
  #:use-module (rde packages)
  #:use-module (lotus-rde features base)
  #:use-module (lotus-rde features mfs)
  #:export (iron-lotus-machine
            iron-lotus-machine-minimal))



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

(define %lotus-nonguix-initrd-modules '("virtio.ko"
                                        "virtio_balloon.ko"
                                        "virtio_ring.ko"
                                        "virtio_blk.ko"
                                        "virtio_pci.ko"
                                        ;; https://issues.guix.gnu.org/31887
                                        "mptbase.ko"
                                        "mptscsih.ko"
                                        "mptspi.ko"
                                        "virtio_net.ko"))




(define* (iron-lotus-machine hostname
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
                             (initrd-modules %lotus-guix-initrd-modules)
                             (custom-services #f)
                             (login-shell (file-append zsh "/bin/zsh")))

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
        ;; (feature-base-services #:guix-substitute-urls %lotus-guix-substitute-urls
        ;;                        #:guix-authorized-keys '())

        ;; (feature-users-group)
        (feature-base-packages #:system-packages
                               (apply strings->packages %lotus-system-packages))

        (feature-custom-services #:feature-name-prefix 'openssh-server-extra
                                 #:system-services (list
                                                    ;; (service dhcp-client-service-type)
                                                    ;; (service network-manager-service-type)
                                                    ;; (service cloud-init-service-type)
                                                    (service openssh-service-type)))

        ;; (feature-logger-services)
        ;; (feature-loopback-services)
        (feature-lotus-base-services)
        (feature-lotus-desktop-services)
        ;; (feature-zsh #:default-shell? #t)
        (feature-login-shell #:login-shell login-shell)

        (feature-custom-services #:feature-name-prefix 'substitutes
                                 #:system-services
                                 (list
                                  ;; (service gdm-service-type
                                  ;;          (gdm-configuration
                                  ;;           (xorg-configuration
                                  ;;            (xorg-configuration
                                  ;;             (keyboard-layout (keyboard-layout "us" "altgr-intl"))))
                                  ;;           (allow-empty-passwords? #t)
                                  ;;           (auto-login?            #f)
                                  ;;           (default-user           "s")))
                                  (simple-service 'guix-substitutes guix-service-type
                                                  (guix-extension (authorized-keys (list (plain-file "cuirass-genenetwork-org.pub"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #11217788B41ADC8D5B8E71BD87EF699C65312EC387752899FE9C888856F5C769#)))")
                                                                                         (plain-file "guix.tobias.gr"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #628CD75C05C78223317092AFDCBE7130D363ACA938114A067F4F9DCF346B59DB#)))")
                                                                                         (plain-file "bordeaux.guix.gnu.org"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #7D602902D3A2DBB83F8A0FB98602A754C5493B0B778C8D1DD4E0F41DE14DE34F#)))")
                                                                                         (plain-file "ci.guix.info"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #8D156F295D24B0D9A86FA5741A840FF2D24F60F7B6C4134814AD55625971B394#)))")
                                                                                         (plain-file "berlin.guix.gnu.org"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #8D156F295D24B0D9A86FA5741A840FF2D24F60F7B6C4134814AD55625971B394#)))")
                                                                                         (plain-file "mirror.brielmaier.net"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #34C318D602FCF6198C5A9F5290A8DB2382D2D0C5478441F8308D24E31BA61633#)))")
                                                                                         (plain-file "substitutes.nonguix.org.pub"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
                                                                                         (plain-file "nonguix-proxy.ditigal.xyz.pub"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
                                                                                         (plain-file "cache-cdn.guix.moe-old.pub"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #374EC58F5F2EC0412431723AF2D527AD626B049D657B5633AAAEBC694F3E33F9#)))")
                                                                                         ;; New key since 2025-10-29.
                                                                                         (plain-file "cache-cdn.guix.moe.pub"
                                                                                                     "(public-key (ecc (curve Ed25519) (q #552F670D5005D7EB6ACF05284A1066E52156B51D75DE3EBD3030CD046675D543#)))")))
                                                                  (substitute-urls '("https://cuirass.genenetwork.org"
                                                                                     "https://guix.tobias.gr"
                                                                                     "https://bordeaux.guix.gnu.org"
                                                                                     "https://ci.guix.info/"
                                                                                     "https://berlin.guix.gnu.org"
                                                                                     "https://mirror.brielmaier.net"
                                                                                     "https://substitutes.nonguix.org"
                                                                                     "https://nonguix-proxy.ditigal.xyz"
                                                                                     "https://cache-cdn.guix.moe"))))))

        (feature-gnome-desktop-services)
        (feature-file-database-services)
        ;; ;; (feature-guix-publish-services)
        (feature-schedular-services)
        (feature-unattended-upgrade-services)
        (feature-disk-services)
        (feature-privileged-programs-services)
        ;; (feature-messaging-services)
        ;; (feature-mail-services)
        (feature-iio-sensor-proxy-services)
        ;; (feature-network-manager-services)

        ;; (feature-dns-services)
        (feature-pointer-services)
        (feature-bluetooth-services)

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



(define* (iron-lotus-machine-minimal hostname
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


