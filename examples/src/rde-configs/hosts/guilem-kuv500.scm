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




(define guilem-kuv500-services
  (feature-custom-services
   #:feature-name-prefix 'guilem-kuv500-extra
   #:system-services
   (list)))


(define-public guilem-kuv500-features
  (list (feature-host-info #:host-name "guilem-kuv500"
                             ;; ls `guix build tzdata`/share/zoneinfo
                             #:timezone "Asia/Kolkata")
        (feature-kernel #:kernel linux
                        #:initrd base-initrd
                        #:firmware '())
        (feature-bootloader #:bootloader-configuration '())
          ;; Allows to declare specific bootloader configuration,
          ;; grub-efi-bootloader used by default
          ;; (feature-bootloader)
        (let-values (((rootfs sys-devices sys-fs) (devfs-system #:disk-serial-id "aaaa"
                                                                #:fs-boot-efi-partition (uuid "0000-0000" 'fat32)))
                     ((home-devices home-fs) (devfs-system #:disk-serial-id "aaa")))
          (feature-file-systems #:mapped-devices (append sys-devices home-devices)
                                #:file-systems (append sys-fs home-fs)
                                #:swap-devices '()
                                #:user-pam-file-systems '()))
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


