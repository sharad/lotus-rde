
(define-module (rde-configs hosts dell5480)
  #:use-module (gnu system uuid)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features base)
  #:use-module (lotus-rde system os))


;;; Hardware/host specifis features

;; TODO: Switch from UUIDs to partition labels For better
;; reproducibilty and easier setup.  Grub doesn't support luks2 yet.

(define-public %dell5480-features (lotus-metal-machine "dell5480"
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
                                                      #:volume-mappings '( ("z7mp9s"
                                                                            ((("vg01" "lv01"))
                                                                             (("vg02" "lv01"))
                                                                             (("vg02" "lv02")))
                                                                            #:prefix "vds"
                                                                            #:seq 0))
                                                      #:custom-services (feature-custom-services
                                                                         #:feature-name-prefix 'dell5480-extra
                                                                         #:system-services (list))))
