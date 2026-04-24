
(define-module (rde-configs hosts dell5480)
  #:use-module (gnu system uuid)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features base)
  #:use-module (lotus-rde features system))


;;; Hardware/host specifis features

;; TODO: Switch from UUIDs to partition labels For better
;; reproducibilty and easier setup.  Grub doesn't support luks2 yet.

(define-public %dell5480-features (feature-lotus-machine "dell5480"
                                                         #:kernel linux
                                                         #:initrd microcode-initrd
                                                         #:firmware (list linux-firmware)
                                                         #:disk-serial-id-system "z7mp9s"
                                                         #:disk-serial-id-home "z7mp9s"
                                                         #:fs-boot-efi-partition (uuid "7528-DF8A" 'fat32)
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
                                                                            #:feature-name-prefix 'dell5480-extra
                                                                            #:system-services (list))))
