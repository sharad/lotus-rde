(define-module (rde-configs hosts gx2-guix-vmware)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (gnu system file-systems)
  #:use-module (lotus-rde features base)
  #:use-module (ice-9 match))



(define-public gx2-guix-vmware-features (define-lotus-machine-features "gx2-guix-vmware"
                                          #:disk-serial-if-system "vmware"
                                          #:disk-serial-if-home "vmware"
                                          #:fs-boot-efi-partition (uuid "4D78-999F" 'fat32)
                                          #:kernel-arguments (append (list "usbcore.autosuspend=-1"
                                                                      "libata.force=2:disable"
                                                                      "libata.noacpi=1"
                                                                      "libata.ignore_hpa=1"
                                                                      "--verbose"
                                                                      "nosplash"
                                                                      "debug"))
                                          ;; (if (and (pair? %lotus-swap-devices)
                                          ;;          (> (length %lotus-swap-devices) 0))
                                          ;;     (list (string-append "resume="
                                          ;;                          (swap-space-target (car %lotus-swap-devices))))
                                          ;;     '())
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
                                                             #:feature-name-prefix 'gx2-guix-vmware-extra
                                                             #:system-services
                                                             (list))))


