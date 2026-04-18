(define-module (lotus-rde features mfs)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-11)
  #:use-module (gnu system uuid)
  #:use-module (rde features system)
  #:use-module (lotus-rde lib utils)
  #:export (feature-mapped-file-systems))


(define* (feature-mapped-file-systems
          #:key
          (disk-serial-id-system "aaaa")
          (disk-serial-id-home "aaaa")
          (fs-boot-efi-partition (uuid "0000-0000" 'fat32)))
  (let*-values (((rootfs sys-devices sys-fs) (lotus-devfs-system #:disk-serial-id disk-serial-id-system
                                                                 #:fs-boot-efi-partition fs-boot-efi-partition))
                ((home-devices home-fs) (lotus-devfs-home #:fs-root rootfs
                                                          #:disk-serial-id disk-serial-id-home)))
    ;; (assert (list? sys-devices) "sys-devices not list")
    ;; (assert (list? home-devices) "home-devices not list")
    ;; (assert (list? sys-fs) "sys-fs not list")
    ;; (assert (list? home-fs) "home-fs not list")
    ;; (for-each (lambda (x)
    ;;             (assert x "sys-device contains #f"))
    ;;           sys-devices)
    ;; (for-each (lambda (x)
    ;;             (assert x "home-device contains #f"))
    ;;           home-devices)
    ;; (for-each (lambda (x)
    ;;             (assert x "sys-fs contains #f"))
    ;;           sys-fs)
    ;; (for-each (lambda (x)
    ;;             (assert x "home-fs contains #f"))
    ;;           home-fs)
    (feature-file-systems #:mapped-devices (append sys-devices home-devices)
                          #:file-systems (append sys-fs home-fs)
                          ;; #:swap-devices (list (lotus-devfs-swap))
                          #:user-pam-file-systems '())))





