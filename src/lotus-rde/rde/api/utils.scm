(define-module (lotus-rde rde api utils)
  #:use-module (lotus-rde rde api defaults)
  #:use-module (guix gexp)
  #:use-module (guix build utils)
  #:use-module (gnu system mapped-devices)

  #:export (build-mapped-device
            build-parent-dir-file-system-builder))




(define %local-host-name "komputilo")
(define %local-default-realm  '((#:default #f)
                                (#:realms)))


(define %local-disk-serial-id          "CHANGEIT")
(define %local-disk-prefix             "vds")
(define %local-disk-suffix-seq         01)
(define %local-fs-check? #t)

(define (build-local-disk-serial-id)
  %local-disk-serial-id)




;; http://www.shido.info/lisp/scheme_syntax_e.html
(define-syntax base-system-value
  (syntax-rules ()
    ((_ local alternate)
     (if (not %lotus-system-init) local alternate))))

(define-syntax nongnu-system-value
  (syntax-rules ()
    ((_ local alternat)
     (if (and %lotus-use-nongnu
              (not %lotus-system-init))
         local alternat))))



;; Functions
(define (local-authorized-guix-keys-local-to-etc-config-file etc-subdir local-dir)
  (let ((currdir (string-append (dirname (current-filename)) "/")))
    (if (file-exists? (string-append currdir local-dir "/"))
        (map (lambda (f)
               (list (string-append etc-subdir "/" (substring f (string-length currdir)))
                     (local-file f)))
             (find-files (string-append currdir local-dir "/")
                         ".pub"))
        '())))

(define (local-authorized-guix-keys dir)
  (if (file-exists? dir)
      (map (lambda (f) (local-file f))
           (find-files (string-append dir "/")
                       ".pub"))
      '()))




(define (open-lvm-device source targets)
  ;; BUG: Fix using https://github.com/Webconverger/webc/blob/1164d83512305d49a8c3dc37b5d26e2d4dd84204/usr/share/initramfs-tools/scripts/init-top/udev
  "Return a gexp that maps SOURCES to TARGETSS as a LVM device, using
'lvm'."
  (with-imported-modules (source-module-closure '((gnu build file-systems)))
                         #~(let ((source   #$source)
                                 (targets  '#$targets)
                                 (lvm-bin  #$(file-append lvm2-static "/sbin/lvm")))
                             ;; Use 'lvm2-static', not 'lvm2', to avoid pulling the
                             ;; whole world inside the initrd (for when we're in an initrd).
                             (begin
                               (format #t "Enabling ~a~%" targets)
                               (map (lambda (trg)
                                      (let ((trg-mapper-path (string-append "/dev/mapper/" trg)))
                                        (unless (file-exists? trg-mapper-path)
                                          (zero? (system* lvm-bin "vgscan" "--mknodes"))
                                          (unless (file-exists? trg-mapper-path)
                                            (sleep 1)
                                            (zero? (system* lvm-bin "vgchange" "-ay" (car (string-split trg #\-))))
                                            (unless (file-exists? trg-mapper-path)
                                              (sleep 1)
                                              (zero? (system* lvm-bin "lvchange" "-aay" "-y" "--sysinit" "--ignoreskippedcluster"
                                                              (string-join (string-split trg #\-) "/")))
                                              (unless (file-exists? trg-mapper-path)
                                                (sleep 1)
                                                (zero? (system* lvm-bin "vgmknodes" "--refresh" (car (string-split trg #\-))))))))))
                                    targets)
                               #t))))

(define (close-lvm-device source targets)
  "Return a gexp that closes TARGETS, a LVM device."
  #~(let ((source   #$source)
          (targets  '#$targets)
          (lvm-bin  #$(file-append lvm2-static "/sbin/lvm")))
      (format #t "Disabling ~a~%" targets)
      (begin
        (map (lambda (trg)
               (let ((trg-mapper-path (string-append "/dev/mapper/" trg)))
                 (when (file-exists? trg-mapper-path)
                   (zero? (system* lvm-bin "lvchange" "-an" "-y" (string-join (string-split trg #\-) "/"))))))
             targets)
        #t)))

;; The type of LVM mapped devices.
(define lvm-device-mapping (mapped-device-kind (open open-lvm-device)
                                               ;; (check check-lvm-device)
                                               (close close-lvm-device)))


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


;; from local-default.scm

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


(define %local-home-build-mapped-device lotus-build-mapped-device)
(define %local-home-build-file-system   lotus-build-file-system)


(define* (build-parent-dir-file-system-builder parent-dir
                                              #:key
                                              (dep-mapped-devs (lambda () %local-udev-lvm-mapped-devices))
                                              (builder         lotus-local-build-file-system)
                                              (disk-name       local-lotus-get-disk-name)
                                              (check?          %local-fs-check?)
                                              (mount?          #f)
                                              (flags           '())
                                              (options         #f)
                                              (type            "ext4")
                                              (create-mount-point? #f)
                                              (needed-for-boot? #f))
  (define* (fs-builder vg lv
                       #:key
                       (dep-mapped-devs dep-mapped-devs)
                       (builder         builder)
                       (disk-name       disk-name)
                       (check?          check?)
                       (mount?          mount?)
                       (flags           flags)
                       (options         options)
                       (type            type)
                       (create-mount-point? create-mount-point?)
                       (needed-for-boot? needed-for-boot?))
    (define (get-value v)
      (cond ((procedure? v)
             (v))
            (else v)))
    (builder (string-append parent-dir "/" (disk-name) "/" vg "/" lv)
             vg
             lv
             #:check?  check?
             #:mount?  mount?
             #:flags   flags
             #:options options
             #:type    type
             #:create-mount-point? create-mount-point?
             #:needed-for-boot?    needed-for-boot?
             #:dependencies        (get-value dep-mapped-devs)))

  fs-builder)

