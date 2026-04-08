(define-module (rde-configs hosts guilem-kuv500)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (rde-configs default)
  #:use-module (ice-9 match))





(define* (lotus-lvm-dev-fs-builders serial-id #:key (prefix "vds") (suffix-seq 01) (separator "X"))

  ;; (display "serial-id ~a~%" serial-id)

  (define (get-string s)
    (cond ((string? s) s)
          ((procedure? s)
           (s))
          (else (error (format #t "Wrong value ~a~%" s)))))

  (define (get-number n)
    (cond ((number? n) n)
          ((procedure? n)
           (n))
          (else (error (format #t "Wrong value ~a~%" n)))))

  (define (get-serial-id serial-id prefix)
    (string-append (get-string prefix)
                   (get-string serial-id)))

  (define (get-group group suffix-seq)
    (let ((suffix-seq (get-number suffix-seq)))
      (string-append group
                     (if (> suffix-seq 0)
                         (format #f "~2'0d" suffix-seq)
                         ""))))
  (define* (dev-builder group volume #:key (suffix-seq suffix-seq))
    (mapped-device (source (string-append (get-serial-id serial-id
                                                         prefix)
                                          "X"
                                          (get-group group
                                                     suffix-seq)))
                   (targets (list (string-append (get-serial-id serial-id
                                                                prefix)
                                                 "X"
                                                 (string-join (list (get-group group
                                                                               suffix-seq)
                                                                    volume)
                                                              "-"))))
                   (type   lvm-device-mapping)))

  (define* (fs-builder mount-point
                              group
                              volume
                              #:key
                              (suffix-seq suffix-seq)
                              (type "ext4")
                              (check? #t)
                              (mount? #t)
                              (flags  '())
                              (options #f)
                              (create-mount-point? #t)
                              (needed-for-boot?    #t)
                              (dependencies (list)))
           (file-system (mount-point         mount-point)
                        (device              (string-append "/dev/mapper/"
                                                            (get-serial-id serial-id
                                                                           prefix)
                                                            "X" (string-join (list (get-group group
                                                                                              suffix-seq)
                                                                                   volume)
                                                                             "-")))
                        (type                type)
                        (check?              check?)
                        (mount?              mount?)
                        (flags               flags)
                        (options             options)
                        (create-mount-point? create-mount-point?)
                        (needed-for-boot?    needed-for-boot?)
                        (dependencies        dependencies)))

  (define (get-disk-name) (get-serial-id serial-id prefix))

  (values dev-builder
          fs-builder
          get-disk-name))


(define (build-mapped-device source disk-id vg lv)
  (mapped-device (source source)
                 (targets (list (string-append disk-id "X" (string-append vg "-" lv))))
                 (type   lvm-device-mapping)))

(define-values (lotus-build-mapped-device lotus-build-file-system lotus-get-disk-name)
  (lotus-lvm-dev-fs-builders (lambda () %lotus-disk-serial-id)
                             #:prefix (lambda () %lotus-disk-prefix)
                             #:suffix-seq (lambda () %lotus-disk-suffix-seq)))

(define-values (lotus-local-build-mapped-device lotus-local-build-file-system local-lotus-get-disk-name)
  (lotus-lvm-dev-fs-builders (lambda () %local-disk-serial-id)
                             #:prefix (lambda () %local-disk-prefix)
                             #:suffix-seq 0))



;;; Hardware/host specifis features

;; TODO: Switch from UUIDs to partition labels For better
;; reproducibilty and easier setup.  Grub doesn't support luks2 yet.
(define %lotus-home-build-mapped-device %local-home-build-mapped-device)
(define %lotus-home-build-file-system %local-home-build-file-system)


(define (system-devices-fs)
  (let-values (;; ((home-build-md home-build-fs) (home-build-mapped-device-file-system))
               ((build-md build-fs) (lotus-lvm-dev-fs-builders (lambda () %lotus-disk-serial-id)
                                                               #:prefix (lambda () %lotus-disk-prefix)
                                                               #:suffix-seq (lambda () %lotus-disk-suffix-seq))))
    (let* ((md-guix-root      (build-md "guix" "root"))
           (md-guix-boot      (build-md "guix" "boot"))
           (md-guix-gnu       (build-md "guix" "gnu"))
           (md-guix-swap      (build-md "guix" "swap"))
           (md-guix-var       (build-md "guix" "var"))
           (md-guix-var-cache (build-md "guix" "varScache"))
           (md-guix-var-lib   (build-md "guix" "varSlib"))
           (md-guix-var-log   (build-md "guix" "varSlog"))
           (md-guix-var-guix  (build-md "guix" "varSguix"))
           (md-guix-var-tmp   (build-md "guix" "varStmp"))
           (md-sys-tmp        (build-md "sys" "tmp"))
           (md-house-home     (home-build-md "house" "home" #:suffix-seq 0))
           (swap-devices      (if #t
                                  (list (swap-space (target (string-append "/dev/mapper/" disk-prefix disk-serial-id "X" "guix"
                                                                           (if (> disk-suffix-seq 0) (format #f "~2'0d" disk-suffix-seq) "")
                                                                           "-"
                                                                           "swap")))
                                        (list))))
           (fs-guix-root       (build-fs "/" "guix" "root"
                                         #:check? fs-guix-root-check?
                                         #:mount? #t
                                         #:create-mount-point? #t
                                         #:needed-for-boot? #t
                                         ;; #:flags               '(read-only)
                                         ;; #:options             "defaults,ro"
                                         #:dependencies (list md-guix-root)))
           (fs-guix-boot       (build-fs "/boot" "guix" "boot"
                                         #:check?              fs-guix-boot-check?
                                         #:mount?              guix-boot-mount?
                                         #:create-mount-point? guix-boot-create-mount-point?
                                         #:needed-for-boot?    guix-boot-needed-for-boot?
                                         #:flags               '(read-only)
                                         #:options             "defaults,ro,noauto"
                                         #:dependencies        (append (list md-guix-root
                                                                             md-guix-boot)
                                                                       (list fs-guix-root))))
           (fs-guix-gnu        (build-fs "/gnu" "guix" "gnu"
                                         #:check?              fs-guix-gnu-check?
                                         #:mount?              #t
                                         #:create-mount-point? #t
                                         #:needed-for-boot?    #t
                                         #:flags               '(read-only)
                                         ;; #:options             "defaults,ro,noauto"
                                         #:dependencies        (append (list md-guix-root
                                                                             md-guix-gnu)
                                                                       (list fs-guix-root))))
           (fs-sys-tmp        (build-fs "/tmp" "sys" "tmp"
                                        #:check?              fs-sys-tmp-check?
                                        #:mount?              #t
                                        #:create-mount-point? #t
                                        #:needed-for-boot?    #t
                                        #:dependencies        (append (list md-guix-root
                                                                            md-sys-tmp)
                                                                      (list fs-guix-root))))
           (fs-guix-var        (build-fs "/var" "guix" "var"
                                         #:check?              fs-guix-var-check?
                                         #:mount?              #t
                                         #:create-mount-point? #t
                                         #:needed-for-boot?    #t
                                         #:dependencies        (append (list md-guix-root
                                                                             md-guix-var)
                                                                       (list fs-guix-root))))
           (fs-guix-var-cache  (build-fs "/var/cache" "guix" "varScache"
                                         #:check?              fs-guix-var-check?
                                         #:mount?              #t
                                         #:create-mount-point? #t
                                         #:needed-for-boot?    #t
                                         #:dependencies        (append (list md-guix-root
                                                                             md-guix-var
                                                                             md-guix-var-cache)
                                                                       (list fs-guix-root
                                                                             fs-guix-var))))
           (fs-guix-var-lib    (build-fs "/var/lib" "guix" "varSlib"
                                         #:check?              fs-guix-var-check?
                                         #:mount?              #t
                                         #:create-mount-point? #t
                                         #:needed-for-boot?    #t
                                         #:dependencies        (append (list md-guix-root
                                                                             md-guix-var
                                                                             md-guix-var-lib)
                                                                       (list fs-guix-root
                                                                             fs-guix-var))))
           (fs-guix-var-log    (build-fs "/var/log" "guix" "varSlog"
                                         #:check?              fs-guix-var-check?
                                         #:mount?              #t
                                         #:create-mount-point? #t
                                         #:needed-for-boot?    #t
                                         #:dependencies        (append (list md-guix-root
                                                                             md-guix-var
                                                                             md-guix-var-log)
                                                                       (list fs-guix-root
                                                                             fs-guix-var))))
           (fs-guix-var-guix   (build-fs "/var/guix" "guix" "varSguix"
                                         #:check?              fs-guix-var-check?
                                         #:mount?              #t
                                         #:create-mount-point? #t
                                         #:needed-for-boot?    #t
                                         #:dependencies        (append (list md-guix-root
                                                                             md-guix-var
                                                                             md-guix-var-guix)
                                                                       (list fs-guix-root
                                                                             fs-guix-var))))

           (fs-guix-var-tmp   (build-fs "/var/tmp" "guix" "varStmp"
                                        ;; https://unix.stackexchange.com/questions/30489/what-is-the-difference-between-tmp-and-var-tmp
                                        #:check?              fs-guix-var-check?
                                        #:mount?              #t
                                        #:create-mount-point? #t
                                        #:needed-for-boot?    #t
                                        #:dependencies        (append (list md-guix-root
                                                                            md-guix-var
                                                                            md-guix-var-tmp)
                                                                      (list fs-guix-root
                                                                            fs-guix-var))))

           (fs-house-home      (home-build-fs "/home" "house" "home"
                                              #:suffix-seq          0
                                              #:check?              fs-house-home-check?
                                              #:mount?              #t ;; (if system-init #f #t)
                                              #:create-mount-point? #t
                                              #:needed-for-boot?    #f
                                              #:dependencies        (append (list md-guix-root
                                                                                  md-house-home)
                                                                            (list)))) ;; fs-guix-root
           (fs-boot-efi        (fs (mount-point         "/boot/efi"
                                                        (device              fs-boot-efi-partition)
                                                        (type                "vfat")
                                                        (check?              #f) ;
                                                        (mount?              guix-bootefi-mount?)
                                                        (create-mount-point? guix-bootefi-create-mount-point?)
                                                        (needed-for-boot?    guix-bootefi-needed-for-boot?)
                                                        (flags               '(read-only))
                                                        (options             "defaults,ro,noauto")
                                                        (dependencies        (append (list md-guix-root)
                                                                                     (list fs-guix-boot
                                                                                           fs-guix-root)))))))




      (let ((devices (list md-guix-root      ;8M
                           md-guix-boot      ;12M
                           md-guix-gnu       ;35G
                           md-guix-var       ;10M
                           md-guix-var-cache ;8G
                           md-guix-var-lib   ;30M
                           md-guix-var-log   ;300M
                           md-guix-var-guix  ;350M
                           md-guix-var-tmp   ;1G
                           md-guix-swap      ;1G
                           md-sys-tmp        ;20G
                           md-house-home))
            (fs (list fs-guix-root
                      fs-guix-boot
                      fs-guix-gnu
                      fs-sys-tmp
                      fs-guix-var
                      fs-guix-var-cache
                      fs-guix-var-lib
                      fs-guix-var-log
                      fs-guix-var-guix
                      fs-guix-var-tmp
                      fs-house-home
                      fs-boot-efi)))
        (values devices fs)))))

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


(define-public %guilem-kuv500-features
  (let-values (((sys-devices sys-fs) (system-devices-fs)))
    (list (feature-host-info #:host-name "guilem-kuv500"
                             ;; ls `guix build tzdata`/share/zoneinfo
                             #:timezone "Asia/Kolkata")
          ;; Allows to declare specific bootloader configuration,
          ;; grub-efi-bootloader used by default
          ;; (feature-bootloader)
          (feature-file-systems #:mapped-devices sys-devices
                                #:file-systems sys-fs)
          (feature-kanshi #:extra-config `((profile laptop
                                                    ((output eDP-1 enable)))
                                           (profile docked
                                                    ((output eDP-1 enable)
                                                     (output DP-2 scale 2)))))
          (feature-hidpi))))

