(define-module (rde-configs hosts guilem-kuv500)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (lotus-rde lib utils)
  #:use-module (lotus-rde base)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (rde-configs default)
  #:use-module (ice-9 match))



;; (define %lotus-desktop-services %lotus-desktop-general-services)


;; (define %lotus-network-services  (list (service openssh-service-type)))
;;                                        ;; (service tor-service-type)


;; (define %lotus-gui-desktop-services (list (service gnome-desktop-service-type)))


;; (define %lotus-heavy-wm-services (list (service gnome-desktop-service-type)
;;                                        (service xfce-desktop-service-type)
;;                                        (service mate-desktop-service-type)
;;                                        (service enlightenment-desktop-service-type)))

;; (define %lotus-many-services (append %lotus-network-services
;;                                      %lotus-heavy-wm-services))

;; (define %lotus-few-services  (append %lotus-gui-desktop-services
;;                                      %lotus-network-services))


;; (define %lotus-simple-services %lotus-few-services)

;; (define %lotus-simple-and-desktop-services (append %lotus-simple-services
;;                                                    %lotus-mail-aliases-services
;;                                                    %iio-sensor-proxy-services
;;                                                    %lotus-dovecot-services
;;                                                    %lotus-gpm-services
;;                                                    %lotus-bluez-services
;;                                                    %lotus-audio-services
;;                                                    %lotus-file-serach-services
;;                                                    %lotus-publish-services
;;                                                    %lotus-mcron-services
;;                                                    %lotus-cups-services
;;                                                    %lotus-polkit-services
;;                                                    %lotus-krb5-services
;;                                                    %lotus-privilege-services
;;                                                    %lotus-bitlbee-services
;;                                                    %lotus-desktop-services
;;                                                    %lotus-local-services
;;                                                    %lotus-docker-services
;;                                                    %lotus-security-services
;;                                                    %lotus-spice-services
;;                                                    %lotus-audit-services))


;; (define %lotus-base-services %base-services)

;; (define %lotus-base-with-dhcp-services
;;   (append (list (service dhcpcd-service-type))
;;           %lotus-network-services
;;           %lotus-base-services))

;; (define %lotus-base-with-nm-wifi-services
;;   (append (list (service network-manager-service-type)
;;                 (service wpa-supplicant-service-type))
;;           %lotus-network-services
;;           %lotus-base-services))

;; (define %lotus-base-with-gui-nm-wifi-services
;;   (append %lotus-network-services
;;           %lotus-desktop-services))


;; (define %lotus-system-init-services %lotus-base-with-gui-nm-wifi-services)

;; (define %lotus-system-post-init-services %lotus-simple-and-desktop-services)

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


(define* define-machine (hostname #:key
                         (disk-serial-if-system "aaa")
                         (disk-serial-if-home "aaa")
                         (fs-boot-efi-partition (uuid "0000-0000" 'fat32))
                         (kernel linux)
                         (firmware '())
                         (initrd base-initrd)
                         (custom-services #f))
  (list (feature-host-info #:host-name hostname
                           ;; #:locale    (operating-system-locale bare-bone-os)
                           ;; ls `guix build tzdata`/share/zoneinfo
                           #:timezone "Asia/Kolkata")
        (feature-kernel #:kernel kernel
                        #:initrd initrd
                        #:firmware firmware
                        #:kernel-arguments (append (list "usbcore.autosuspend=-1"
                                                         "libata.force=2:disable"
                                                         "libata.noacpi=1"
                                                         "libata.ignore_hpa=1"
                                                         "--verbose"
                                                         "nosplash"
                                                         "debug")))
                                                   ;; (if (and (pair? %lotus-swap-devices)
                                                   ;;          (> (length %lotus-swap-devices) 0))
                                                   ;;     (list (string-append "resume="
                                                   ;;                          (swap-space-target (car %lotus-swap-devices))))
                                                   ;;     '())
        (feature-bootloader #:bootloader-configuration (bootloader-configuration (bootloader grub-bootloader)
                                                                                 (targets    '())))
                                                                                 ;; (keyboard-layout %lotus-keyboard-layout)
                                                                                 ;; (menu-entries    %lotus-grub-ubuntu-menuentries)
          ;; Allows to declare specific bootloader configuration,
          ;; grub-efi-bootloader used by default
          ;; (feature-bootloader)
        (let-values (((rootfs sys-devices sys-fs) (devfs-system #:disk-serial-id disk-serial-if-system
                                                                #:fs-boot-efi-partition fs-boot-efi-partition))
                     ((home-devices home-fs) (devfs-system #:disk-serial-id disk-serial-if-home)))
          (feature-file-systems #:mapped-devices (append sys-devices home-devices)
                                #:file-systems (append sys-fs home-fs)
                                #:swap-devices '()
                                #:user-pam-file-systems '()))
        guilem-kuv500-services

        (feature-base-services)
        (feature-desktop-services)

        (feature-file-database-services)
        ;; (feature-guix-publish-services)
        (feature-schedular-services)
        (feature-unattended-upgrade-services)
        (feature-disk-services)
        (feature-privileged-programs-services)
        (feature-messaging-services)
        (feature-mail-services)
        (feature-iio-sensor-proxy-services)
        (feature-network-manager-services)

        (feature-dns-services)
        (feature-pointer-services)
        (feature-bluetooth-services)

        ;; (feature-music-services)
        ;; (feature-printing-services)
        ;; (feature-polkit-services)
        ;; (feature-krberos-services)
        (feature-container-sevices)
        (feature-security-services)
        (feature-audit-services)
        (feature-guix-services)
        (feature-desktop-manager-service)
        (feature-pulseaudio-service)))


;; ;; session stack
;; (feature-dbus)
;; (feature-polkit)
;; (feature-elogind)

;; display stack
;; (feature-wayland)

;; your stuff
;; (feature-hidpi)


(define-public guilem-kuv500-features (define-machine "guilem-kuv500"
                                        #:disk-serial-if-system "aaa"
                                        #:disk-serial-if-home "aaa"
                                        #:fs-boot-efi-partition (uuid "0000-0000" 'fat32)
                                        #:kernel linux
                                        #:firmware (list linux-firmware)
                                        #:initrd (lambda (file-systems . rest)
                                                   (apply base-initrd file-systems
                                                          #:extra-modules '("virtio.ko"
                                                                            "virtio_balloon.ko"
                                                                            "virtio_ring.ko"
                                                                            "virtio_blk.ko"
                                                                            "virtio_pci.ko"
                                                                            ;; https://issues.guix.gnu.org/31887
                                                                            "mptbase.ko"
                                                                            "mptscsih.ko"
                                                                            "mptspi.ko"
                                                                            "virtio_net.ko")
                                                          rest))
                                        #:custom-services (feature-custom-services
                                                           #:feature-name-prefix 'guilem-kuv500-extra
                                                           #:system-services
                                                           (list))))


