
(define-module (lotus-rde features system)
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
  #:use-module (lotus-rde features mfs)
  #:export (feature-lotus-machine))



(define* (feature-lotus-machine hostname
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
        ;; (feature-bootloader #:bootloader-configuration (bootloader-configuration (bootloader grub-bootloader)
        ;;                                                                          (targets    '())))
                                                                                 ;; (keyboard-layout %lotus-keyboard-layout)
                                                                                 ;; (menu-entries    %lotus-grub-ubuntu-menuentries)
        ;; Allows to declare specific bootloader configuration,
        ;; grub-efi-bootloader used by default
        ;; (feature-bootloader)

        (feature-mapped-file-systems #:disk-serial-id-system disk-serial-id-system
                                     #:disk-serial-id-home disk-serial-id-home
                                     #:fs-boot-efi-partition fs-boot-efi-partition)
        ;; (let-values (((_ sys-devices sys-fs) (lotus-devfs-system #:disk-serial-id disk-serial-id-system
        ;;                                                          #:fs-boot-efi-partition fs-boot-efi-partition))
        ;;              ((home-devices home-fs) (lotus-devfs-home ;; #:fs-root rootfs
        ;;                                                        #:disk-serial-id disk-serial-id-home)))
        ;;   ;; (assert (list? sys-devices) "sys-devices not list")
        ;;   ;; (assert (list? home-devices) "home-devices not list")
        ;;   ;; (assert (list? sys-fs) "sys-fs not list")
        ;;   ;; (assert (list? home-fs) "home-fs not list")
        ;;   ;; (for-each (lambda (x)
        ;;   ;;             (assert x "sys-device contains #f"))
        ;;   ;;           sys-devices)
        ;;   ;; (for-each (lambda (x)
        ;;   ;;             (assert x "home-device contains #f"))
        ;;   ;;           home-devices)
        ;;   ;; (for-each (lambda (x)
        ;;   ;;             (assert x "sys-fs contains #f"))
        ;;   ;;           sys-fs)
        ;;   ;; (for-each (lambda (x)
        ;;   ;;             (assert x "home-fs contains #f"))
        ;;   ;;           home-fs)
        ;;   (feature-file-systems #:mapped-devices (append sys-devices home-devices)
        ;;                         #:file-systems (append sys-fs home-fs)
        ;;                         ;; #:swap-devices (list (lotus-devfs-swap))
        ;;                         #:user-pam-file-systems '()))
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
