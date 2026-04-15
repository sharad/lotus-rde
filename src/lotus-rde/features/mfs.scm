(define-module (lotus-rde features mfs)
  #:use-module (ice-9 match)
  #:use-module (lotus-rde lib utils)
  #:export (feature-mapped-file-systems))




(define* (feature-mapped-file-systems
          #:key
          (disk-serial-id "aaaa")
          (fs-boot-efi-partition (uuid "0000-0000" 'fat32)))
  (let-values (((rootfs sys-devices sys-fs) (devfs-system #:disk-serial-id disk-serial-id
                                                          #:fs-boot-efi-partition fs-boot-efi-partition))
               ((home-devices home-fs) (devfs-system #:disk-serial-id)))
    (feature-file-systems #:mapped-devices (append sys-devices home-devices)
                          #:file-systems (append sys-fs home-fs))))



