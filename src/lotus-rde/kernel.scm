(use-modules (nongnu packages linux))
;; (define %default-boot-targets '("/boot/efi"))

(define* (feature-bootloader
          #:key
          (targets '("/boot/efi")))
  (feature
   (name 'bootloader)
   (values
    (rde-system-operating-system
     (lambda (os)
       (operating-system
         (inherit os)
         (bootloader
          (bootloader-configuration
           (bootloader grub-efi-bootloader)
           (targets targets)))))))))

;; (define %default-initrd-modules
;;   '("dm-crypt" "dm-mod" "ext4"))

(define* (feature-initrd
          #:key
          (extra-modules '()))
  (feature
   (name 'initrd)
   (values
    (rde-system-operating-system
     (lambda (os)
       (operating-system
         (inherit os)
         (initrd
          (lambda (file-systems . rest)
            (apply base-initrd
                   file-systems
                   #:extra-modules extra-modules
                   rest)))))))))

(define* (feature-kernel
          #:key
          (kernel linux)
          (firmware (list linux-firmware)))
  (feature
   (name 'kernel)
   (values
    (rde-system-operating-system
     (lambda (os)
       (operating-system
         (inherit os)
         (kernel kernel)
         (firmware firmware)))))))


(define (feature-nonguix)
  (feature
   (name 'nonguix)
   (values
    (rde-system-operating-system
     (lambda (os)
       (operating-system
         (inherit os)
         (kernel linux)
         (firmware (list linux-firmware))))))))

