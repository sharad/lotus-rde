(define-module (rde-configs hosts gx2-guix-vmware)
  #:use-module (gnu system uuid)
  #:use-module (gnu system linux-initrd)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde features base)
  #:use-module (lotus-rde system os))



(define-public %gx2-guix-vmware-features (lotus-metal-machine "gx2-guix-vmware"
                                                              #:kernel linux
                                                              #:initrd microcode-initrd
                                                              #:firmware (list linux-firmware)
                                                              #:disk-serial-id-system "vmware"
                                                              #:disk-serial-id-home "vmware"
                                                              #:initrd-modules (append (list "mptbase"
                                                                                             "mptscsih"
                                                                                             "mptspi"
                                                                                             "virtio_net"
                                                                                             "vmwgfx")
                                                                                       %base-initrd-modules)
                                                              #:fs-boot-efi-partition (uuid "4D78-999F" 'fat32)))


