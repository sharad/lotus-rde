(define-module (rde-configs hosts guilem-lat7420)
  #:use-module (gnu system uuid)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features base)
  #:use-module (lotus-rde system os))



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


;; ;; session stack
;; (feature-dbus)
;; (feature-polkit)
;; (feature-elogind)

;; display stack
;; (feature-wayland)

;; your stuff
;; (feature-hidpi)

(define-public %guilem-lat7420-features (feature-lotus-machine "guilem-lat7420"
                                                               #:kernel linux
                                                               #:initrd microcode-initrd
                                                               #:firmware (list linux-firmware)
                                                               #:disk-serial-id-system "knba2f"
                                                               #:disk-serial-id-home "knba2f"
                                                               #:fs-boot-efi-partition (uuid "C4B7-5EA9" 'fat32)
                                                               #:kernel-arguments (list "usbcore.autosuspend=-1"
                                                                                        "libata.force=2:disable"
                                                                                        "libata.noacpi=1"
                                                                                        "libata.ignore_hpa=1"
                                                                                        "--verbose"
                                                                                        "nosplash"
                                                                                        "debug")
                                                               ;; (if (and (pair? %lotus-swap-devices)
                                                               ;;          (> (length %lotus-swap-devices) 0))
                                                               ;;     (list (string-append "resume="
                                                               ;;                          (swap-space-target (car %lotus-swap-devices))))
                                                               ;;     '())
                                                               ;; #:initrd (lambda (file-systems . rest)
                                                               ;;            (apply base-initrd file-systems
                                                               ;;                   #:extra-modules '("virtio.ko"
                                                               ;;                                     "virtio_balloon.ko"
                                                               ;;                                     "virtio_ring.ko"
                                                               ;;                                     "virtio_blk.ko"
                                                               ;;                                     "virtio_pci.ko"
                                                               ;;                                     ;; https://issues.guix.gnu.org/31887
                                                               ;;                                     "mptbase.ko"
                                                               ;;                                     "mptscsih.ko"
                                                               ;;                                     "mptspi.ko"
                                                               ;;                                     "virtio_net.ko")
                                                               ;;                   rest))
                                                               #:custom-services (feature-custom-services
                                                                                  #:feature-name-prefix 'guilem-lat7420-extra
                                                                                  #:system-services (list))))

;; (define-public %guilem-lat7420-features (list))


