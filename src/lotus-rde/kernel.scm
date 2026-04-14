
(define %default-boot-targets '("/boot/efi"))

(define* (feature-bootloader
          #:key
          (targets %default-boot-targets))

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

(define %default-initrd-modules
  '("dm-crypt" "dm-mod" "ext4"))

(define* (feature-initrd
          #:key
          (extra-modules %default-initrd-modules))

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


(use-modules (nongnu packages linux))

(define %default-kernel linux)
(define %default-firmware (list linux-firmware))

(define* (feature-kernel
          #:key
          (kernel %default-kernel)
          (firmware %default-firmware))

  (feature
   (name 'kernel)
   (values
    (rde-system-operating-system
     (lambda (os)
       (operating-system
         (inherit os)
         (kernel kernel)
         (firmware firmware)))))))

(use-modules (nongnu packages linux))

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


(use-modules (nongnu packages linux))

(define (feature-nonguix-kernel)
  (feature
   (name 'nonguix-kernel)
   (values
    (rde-system-operating-system
     (lambda (os)
       (operating-system
         (inherit os)
         (kernel linux)
         (firmware (list linux-firmware))))))))


