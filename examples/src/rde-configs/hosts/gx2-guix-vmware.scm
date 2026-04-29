(define-module (rde-configs hosts gx2-guix-vmware)
  #:use-module (gnu system uuid)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features base)
  #:use-module (lotus-rde features system))



(define-public %gx2-guix-vmware-features (feature-lotus-machine-minimal "gx2-guix-vmware"
                                                                ;; #:kernel linux
                                                                ;; #:initrd microcode-initrd
                                                                ;; #:firmware (list linux-firmware)
                                                                #:disk-serial-id-system "vmware"
                                                                #:disk-serial-id-home "vmware"
                                                                #:initrd-modules '("virtio.ko"
                                                                                   "virtio_balloon.ko"
                                                                                   "virtio_ring.ko"
                                                                                   "virtio_blk.ko"
                                                                                   "virtio_pci.ko"
                                                                                   ;; https://issues.guix.gnu.org/31887
                                                                                   "mptbase.ko"
                                                                                   "mptscsih.ko"
                                                                                   "mptspi.ko"
                                                                                   "virtio_net.ko")
                                                                #:fs-boot-efi-partition (uuid "4D78-999F" 'fat32)
                                                                #:bootloader-targets '("/boot/efi")))





;; (display %gx2-guix-vmware-features)
;; (newline)

;; (define-public %gx2-guix-vmware-features
;;   (list
;;    (feature-host-info
;;     #:host-name "gx2")

;;    (feature-file-systems
;;     #:file-systems '()
;;     #:mapped-devices '())

;;    (feature-base-services)))



