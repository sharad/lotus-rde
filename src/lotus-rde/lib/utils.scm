(define-module (lotus-rde lib utils)
  #:use-module (ice-9 format)
  #:use-module (ice-9 stat)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 threads)
  #:use-module (srfi srfi-11)
  #:use-module (ice-9 srfi-13)
  #:use-module (guix gexp)
  #:use-module (guix modules)
  #:use-module (guix build utils)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system uuid)
  #:use-module (gnu packages lvm)
  #:export (lotus-devfs-system
            lotus-devfs-home
            lotus-devfs-swap))




;; (define %local-host-name "komputilo")
;; (define %local-default-realm  '((#:default #f)
;;                                 (#:realms)))


;; (define %local-disk-serial-id          "CHANGEIT")
;; (define %local-disk-prefix             "vds")
;; (define %local-disk-suffix-seq         01)
;; (define %local-fs-check? #t)

;; (define (build-local-disk-serial-id)
;;   %local-disk-serial-id)




;; ;; http://www.shido.info/lisp/scheme_syntax_e.html
;; (define-syntax base-system-value
;;   (syntax-rules ()
;;     ((_ local alternate)
;;      (if (not %lotus-system-init) local alternate))))

;; (define-syntax nongnu-system-value
;;   (syntax-rules ()
;;     ((_ local alternat)
;;      (if (and %lotus-use-nongnu
;;               (not %lotus-system-init))
;;          local alternat))))



;; Functions
;; (define (local-authorized-guix-keys-local-to-etc-config-file etc-subdir local-dir)
;;   (let ((currdir (string-append (dirname (current-filename)) "/")))
;;     (if (file-exists? (string-append currdir local-dir "/"))
;;         (map (lambda (f)
;;                (list (string-append etc-subdir "/" (substring f (string-length currdir)))
;;                      (local-file f)))
;;              (find-files (string-append currdir local-dir "/")
;;                          ".pub"))
;;         '())))

;; (define (local-authorized-guix-keys dir)
;;   (if (file-exists? dir)
;;       (map (lambda (f) (local-file f))
;;            (find-files (string-append dir "/")
;;                        ".pub"))
;;       '()))




(define (open-lvm-device source targets)
  ;; BUG: Fix using https://github.com/Webconverger/webc/blob/1164d83512305d49a8c3dc37b5d26e2d4dd84204/usr/share/initramfs-tools/scripts/init-top/udev
  "Return a gexp that maps SOURCES to TARGETSS as a LVM device, using
'lvm'."
  (with-imported-modules (source-module-closure '((gnu build file-systems)
                                                  (guix build utils)
                                                  (ice-9 threads)
                                                  (ice-9 srfi-13)))
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

  ;; (format #t "serial-id ~a~%" serial-id)

  (define (get-string s)
    (cond ((string? s) s)
          ((procedure? s)
           (s))
          (else (error (format #f "Wrong value ~a~%" s)))))

  (define (get-number n)
    (cond ((number? n) n)
          ((procedure? n)
           (n))
          (else (error (format #f "Wrong value ~a~%" n)))))

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



;; (define-values (lotus-build-mapped-device lotus-build-file-system lotus-get-disk-name)
;;   (lotus-lvm-dev-fs-builders (lambda () %lotus-disk-serial-id)
;;                              #:prefix (lambda () %lotus-disk-prefix)
;;                              #:suffix-seq (lambda () %lotus-disk-suffix-seq)))

;; (define-values (lotus-local-build-mapped-device lotus-local-build-file-system local-lotus-get-disk-name)
;;   (lotus-lvm-dev-fs-builders (lambda () %local-disk-serial-id)
;;                              #:prefix (lambda () %local-disk-prefix)
;;                              #:suffix-seq 0))


;; (define %local-home-build-mapped-device lotus-build-mapped-device)
;; (define %local-home-build-file-system   lotus-build-file-system)


;; (define* (build-parent-dir-file-system-builder parent-dir
;;                                               #:key
;;                                               (dep-mapped-devs (lambda () %local-udev-lvm-mapped-devices))
;;                                               (builder         lotus-local-build-file-system)
;;                                               (disk-name       local-lotus-get-disk-name)
;;                                               (check?          %local-fs-check?)
;;                                               (mount?          #f)
;;                                               (flags           '())
;;                                               (options         #f)
;;                                               (type            "ext4")
;;                                               (create-mount-point? #f)
;;                                               (needed-for-boot? #f))
;;   (define* (fs-builder vg lv
;;                        #:key
;;                        (dep-mapped-devs dep-mapped-devs)
;;                        (builder         builder)
;;                        (disk-name       disk-name)
;;                        (check?          check?)
;;                        (mount?          mount?)
;;                        (flags           flags)
;;                        (options         options)
;;                        (type            type)
;;                        (create-mount-point? create-mount-point?)
;;                        (needed-for-boot? needed-for-boot?))
;;     (define (get-value v)
;;       (cond ((procedure? v)
;;              (v))
;;             (else v)))
;;     (builder (string-append parent-dir "/" (disk-name) "/" vg "/" lv)
;;              vg
;;              lv
;;              #:check?  check?
;;              #:mount?  mount?
;;              #:flags   flags
;;              #:options options
;;              #:type    type
;;              #:create-mount-point? create-mount-point?
;;              #:needed-for-boot?    needed-for-boot?
;;              #:dependencies        (get-value dep-mapped-devs)))

;;   fs-builder)


;; (define* (lotus-devfs-system #:key
;;                              ;; lotus-lvm-dev-fs-builders
;;                              (disk-serial-id "CHANGEIT")
;;                              (disk-prefix    "vds")
;;                              (disk-suffix-seq 01)
;;                              (guix-boot-mount? #f)
;;                              (guix-boot-create-mount-point? #f)
;;                              (guix-boot-needed-for-boot? #f)
;;                              (guix-bootefi-mount? #f)
;;                              (guix-bootefi-create-mount-point? #f)
;;                              (guix-bootefi-needed-for-boot? #f)
;;                              (fs-boot-efi-partition (uuid "0000-0000" 'fat32)))
;;   (let*-values (((build-md build-fs _) (lotus-lvm-dev-fs-builders (lambda () disk-serial-id)
;;                                                                   #:prefix (lambda () disk-prefix)
;;                                                                   #:suffix-seq (lambda () disk-suffix-seq))))
;;       (let* ((md-guix-root      (build-md "guix" "root"))
;;              (md-guix-boot      (build-md "guix" "boot"))
;;              (md-guix-gnu       (build-md "guix" "gnu"))
;;              ;; (md-guix-swap      (build-md "guix" "swap"))
;;              (md-guix-var       (build-md "guix" "var"))
;;              (md-guix-var-cache (build-md "guix" "varScache"))
;;              (md-guix-var-lib   (build-md "guix" "varSlib"))
;;              (md-guix-var-log   (build-md "guix" "varSlog"))
;;              (md-guix-var-guix  (build-md "guix" "varSguix"))
;;              (md-guix-var-tmp   (build-md "guix" "varStmp"))
;;              (md-sys-tmp        (build-md "sys" "tmp"))
;;              ;; (swap-devices      (if #t
;;              ;;                       (list (swap-space (target (string-append "/dev/mapper/" disk-prefix disk-serial-id "X" "guix"
;;              ;;                                                                (if (> disk-suffix-seq 0) (format #f "~2'0d" disk-suffix-seq) "")
;;              ;;                                                                "-"
;;              ;;                                                                "swap"))
;;              ;;                              (list)))))
;;              (fs-guix-root       (build-fs "/" "guix" "root"
;;                                            #:check? #t ;; fs-guix-root-check?
;;                                            #:mount? #t
;;                                            #:create-mount-point? #t
;;                                            #:needed-for-boot? #t
;;                                            ;; #:flags               '(read-only)
;;                                            ;; #:options             "defaults,ro"
;;                                            #:dependencies (list md-guix-root)))
;;              (fs-guix-boot       (build-fs "/boot" "guix" "boot"
;;                                            #:check?              #t ;; fs-guix-boot-check?
;;                                            #:mount?              guix-boot-mount?
;;                                            #:create-mount-point? guix-boot-create-mount-point?
;;                                            #:needed-for-boot?    guix-boot-needed-for-boot?
;;                                            #:flags               '(read-only)
;;                                            #:options             "defaults,ro,noauto"
;;                                            #:dependencies        (append (list md-guix-root
;;                                                                                md-guix-boot)
;;                                                                          (list fs-guix-root))))
;;              (fs-guix-gnu        (build-fs "/gnu" "guix" "gnu"
;;                                            #:check?              #t ;; fs-guix-gnu-check?
;;                                            #:mount?              #t
;;                                            #:create-mount-point? #t
;;                                            #:needed-for-boot?    #t
;;                                            #:flags               '(read-only)
;;                                            ;; #:options             "defaults,ro,noauto"
;;                                            #:dependencies        (append (list md-guix-root
;;                                                                                md-guix-gnu)
;;                                                                          (list fs-guix-root))))
;;              (fs-sys-tmp        (build-fs "/tmp" "sys" "tmp"
;;                                           #:check?              #t ;; fs-sys-tmp-check?
;;                                           #:mount?              #t
;;                                           #:create-mount-point? #t
;;                                           #:needed-for-boot?    #t
;;                                           #:dependencies        (append (list md-guix-root
;;                                                                               md-sys-tmp)
;;                                                                         (list fs-guix-root))))
;;              (fs-guix-var        (build-fs "/var" "guix" "var"
;;                                            #:check?              #t ;; fs-guix-var-check?
;;                                            #:mount?              #t
;;                                            #:create-mount-point? #t
;;                                            #:needed-for-boot?    #t
;;                                            #:dependencies        (append (list md-guix-root
;;                                                                                md-guix-var)
;;                                                                          (list fs-guix-root))))
;;              (fs-guix-var-cache  (build-fs "/var/cache" "guix" "varScache"
;;                                            #:check?              #t ;; fs-guix-var-check?
;;                                            #:mount?              #t
;;                                            #:create-mount-point? #t
;;                                            #:needed-for-boot?    #t
;;                                            #:dependencies        (append (list md-guix-root
;;                                                                                md-guix-var
;;                                                                                md-guix-var-cache)
;;                                                                          (list fs-guix-root
;;                                                                                fs-guix-var))))
;;              (fs-guix-var-lib    (build-fs "/var/lib" "guix" "varSlib"
;;                                            #:check?              #t ;; fs-guix-var-check?
;;                                            #:mount?              #t
;;                                            #:create-mount-point? #t
;;                                            #:needed-for-boot?    #t
;;                                            #:dependencies        (append (list md-guix-root
;;                                                                                md-guix-var
;;                                                                                md-guix-var-lib)
;;                                                                          (list fs-guix-root
;;                                                                                fs-guix-var))))
;;              (fs-guix-var-log    (build-fs "/var/log" "guix" "varSlog"
;;                                            #:check?              #t ;; fs-guix-var-check?
;;                                            #:mount?              #t
;;                                            #:create-mount-point? #t
;;                                            #:needed-for-boot?    #t
;;                                            #:dependencies        (append (list md-guix-root
;;                                                                                md-guix-var
;;                                                                                md-guix-var-log)
;;                                                                          (list fs-guix-root
;;                                                                                fs-guix-var))))
;;              (fs-guix-var-guix   (build-fs "/var/guix" "guix" "varSguix"
;;                                            #:check?              #t ;; fs-guix-var-check?
;;                                            #:mount?              #t
;;                                            #:create-mount-point? #t
;;                                            #:needed-for-boot?    #t
;;                                            #:dependencies        (append (list md-guix-root
;;                                                                                md-guix-var
;;                                                                                md-guix-var-guix)
;;                                                                          (list fs-guix-root
;;                                                                                fs-guix-var))))

;;              (fs-guix-var-tmp   (build-fs "/var/tmp" "guix" "varStmp"
;;                                           ;; https://unix.stackexchange.com/questions/30489/what-is-the-difference-between-tmp-and-var-tmp
;;                                           #:check?              #t ;; fs-guix-var-check?
;;                                           #:mount?              #t
;;                                           #:create-mount-point? #t
;;                                           #:needed-for-boot?    #t
;;                                           #:dependencies        (append (list md-guix-root
;;                                                                               md-guix-var
;;                                                                               md-guix-var-tmp)
;;                                                                         (list fs-guix-root
;;                                                                               fs-guix-var))))
;;              (fs-boot-efi        (file-system (mount-point         "/boot/efi")
;;                                               (device              fs-boot-efi-partition)
;;                                               (type                "vfat")
;;                                               (check?              #t) ;
;;                                               (mount?              guix-bootefi-mount?)
;;                                               (create-mount-point? guix-bootefi-create-mount-point?)
;;                                               (needed-for-boot?    guix-bootefi-needed-for-boot?)
;;                                               (flags               '(read-only))
;;                                               (options             "defaults,ro,noauto")
;;                                               (dependencies        (append (list md-guix-root)
;;                                                                            (list fs-guix-boot
;;                                                                                  fs-guix-root))))))
;;         (let ((devices (list md-guix-root      ;8M
;;                              md-guix-boot      ;12M
;;                              md-guix-gnu       ;35G
;;                              md-guix-var       ;10M
;;                              md-guix-var-cache ;8G
;;                              md-guix-var-lib   ;30M
;;                              md-guix-var-log   ;300M
;;                              md-guix-var-guix  ;350M
;;                              md-guix-var-tmp   ;1G
;;                              ;; md-guix-swap      ;1G
;;                              md-sys-tmp))        ;20G
;;               (fs (list fs-guix-root
;;                         fs-guix-boot
;;                         fs-guix-gnu
;;                         fs-sys-tmp
;;                         fs-guix-var
;;                         fs-guix-var-cache
;;                         fs-guix-var-lib
;;                         fs-guix-var-log
;;                         fs-guix-var-guix
;;                         fs-guix-var-tmp
;;                         fs-boot-efi)))
;;           (format #t "Devices: ~a~%" devices)
;;           (format #t "File systems: ~a~%" fs)

;;           (values fs-guix-root
;;                   devices
;;                   fs)))))

(define* (lotus-devfs-home #:key
                           ;; lotus-lvm-dev-fs-builders
                           (fs-root #f)
                           (disk-serial-id "CHANGEIT")
                           (disk-prefix "vds")
                           (disk-suffix-seq 0))
  (let*-values (((build-md build-fs _) (lotus-lvm-dev-fs-builders (lambda () disk-serial-id)
                                                                  #:prefix (lambda () disk-prefix)
                                                                  #:suffix-seq (lambda () disk-suffix-seq))))
                  ;; ((home-build-md home-build-fs) (values build-md build-fs))
      (let* ((md-house-home     (build-md "house" "home" #:suffix-seq 0))

             (fs-house-home     (build-fs "/home" "house" "home"
                                               #:suffix-seq          0
                                               #:check?              #t ;; fs-house-home-check?
                                               #:mount?              #t ;; (if system-init #f #t)
                                               #:create-mount-point? #t
                                               #:needed-for-boot?    #f
                                               #:dependencies        (append (list md-house-home)
                                                                             (list))))) ;; fs-guix-root
        (let ((devices (list md-house-home))
              (fs (list fs-house-home)))
          (format #t "Devices: ~a~%" devices)
          (format #t "File systems: ~a~%" fs)
          (values devices
                  fs)))))

;; (define* (lotus-devfs-swap #:key
;;                            ;; lotus-lvm-dev-fs-builders
;;                            (fs-root #f)
;;                            (disk-serial-id "CHANGEIT")
;;                            (disk-prefix "vds")
;;                            (disk-suffix-seq 0))
;;   (let*-values (((build-md build-fs _) (lotus-lvm-dev-fs-builders (lambda () disk-serial-id)
;;                                                                   #:prefix (lambda () disk-prefix)
;;                                                                   #:suffix-seq (lambda () disk-suffix-seq))))
;;                (build-md "guix" "swap")))

