(define-module (rde-configs hosts guilem-kuv500)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (rde-configs default)
  #:use-module (ice-9 match))


;;; Hardware/host specifis features

;; TODO: Switch from UUIDs to partition labels For better
;; reproducibilty and easier setup.  Grub doesn't support luks2 yet.
(define %lotus-home-build-mapped-device %local-home-build-mapped-device)
(define %lotus-home-build-file-system %local-home-build-file-system)

(define %lotus-mapped-device-guix-root      (lotus-build-mapped-device "guix" "root"))
(define %lotus-mapped-device-guix-boot      (lotus-build-mapped-device "guix" "boot"))
(define %lotus-mapped-device-guix-gnu       (lotus-build-mapped-device "guix" "gnu"))
(define %lotus-mapped-device-guix-swap      (lotus-build-mapped-device "guix" "swap"))
(define %lotus-mapped-device-guix-var       (lotus-build-mapped-device "guix" "var"))
(define %lotus-mapped-device-guix-var-cache (lotus-build-mapped-device "guix" "varScache"))
(define %lotus-mapped-device-guix-var-lib   (lotus-build-mapped-device "guix" "varSlib"))
(define %lotus-mapped-device-guix-var-log   (lotus-build-mapped-device "guix" "varSlog"))
(define %lotus-mapped-device-guix-var-guix  (lotus-build-mapped-device "guix" "varSguix"))
(define %lotus-mapped-device-guix-var-tmp   (lotus-build-mapped-device "guix" "varStmp"))
(define %lotus-mapped-device-sys-tmp        (lotus-build-mapped-device "sys" "tmp"))
(define %lotus-mapped-device-house-home     (%lotus-home-build-mapped-device "house" "home" #:suffix-seq 0))

(define %lotus-swap-devices      (if #t
                                     (list (swap-space (target (string-append "/dev/mapper/" %lotus-disk-prefix %lotus-disk-serial-id "X" "guix"
                                                                              (if (> %lotus-disk-suffix-seq 0) (format #f "~2'0d" %lotus-disk-suffix-seq) "")
                                                                              "-"
                                                                              "swap"))))
                                     (list)))

(define %lotus-file-system-guix-root       (lotus-build-file-system "/" "guix" "root"
                                                                    #:check? %lotus-fs-guix-root-check?
                                                                    #:mount? #t
                                                                    #:create-mount-point? #t
                                                                    #:needed-for-boot? #t
                                                                    ;; #:flags               '(read-only)
                                                                    ;; #:options             "defaults,ro"
                                                                    #:dependencies (list %lotus-mapped-device-guix-root)))
(define %lotus-file-system-guix-boot       (lotus-build-file-system "/boot" "guix" "boot"
                                                                    #:check?              %lotus-fs-guix-boot-check?
                                                                    #:mount?              %lotus-guix-boot-mount?
                                                                    #:create-mount-point? %lotus-guix-boot-create-mount-point?
                                                                    #:needed-for-boot?    %lotus-guix-boot-needed-for-boot?
                                                                    #:flags               '(read-only)
                                                                    #:options             "defaults,ro,noauto"
                                                                    #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                        %lotus-mapped-device-guix-boot)
                                                                                                  (list %lotus-file-system-guix-root))))
(define %lotus-file-system-guix-gnu        (lotus-build-file-system "/gnu" "guix" "gnu"
                                                                    #:check?              %lotus-fs-guix-gnu-check?
                                                                    #:mount?              #t
                                                                    #:create-mount-point? #t
                                                                    #:needed-for-boot?    #t
                                                                    #:flags               '(read-only)
                                                                    ;; #:options             "defaults,ro,noauto"
                                                                    #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                        %lotus-mapped-device-guix-gnu)
                                                                                                  (list %lotus-file-system-guix-root))))
(define %lotus-file-system-sys-tmp        (lotus-build-file-system "/tmp" "sys" "tmp"
                                                                   #:check?              %lotus-fs-sys-tmp-check?
                                                                   #:mount?              #t
                                                                   #:create-mount-point? #t
                                                                   #:needed-for-boot?    #t
                                                                   #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                       %lotus-mapped-device-sys-tmp)
                                                                                                 (list %lotus-file-system-guix-root))))
(define %lotus-file-system-guix-var        (lotus-build-file-system "/var" "guix" "var"
                                                                    #:check?              %lotus-fs-guix-var-check?
                                                                    #:mount?              #t
                                                                    #:create-mount-point? #t
                                                                    #:needed-for-boot?    #t
                                                                    #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                        %lotus-mapped-device-guix-var)
                                                                                                  (list %lotus-file-system-guix-root))))
(define %lotus-file-system-guix-var-cache  (lotus-build-file-system "/var/cache" "guix" "varScache"
                                                                    #:check?              %lotus-fs-guix-var-check?
                                                                    #:mount?              #t
                                                                    #:create-mount-point? #t
                                                                    #:needed-for-boot?    #t
                                                                    #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                        %lotus-mapped-device-guix-var
                                                                                                        %lotus-mapped-device-guix-var-cache)
                                                                                                  (list %lotus-file-system-guix-root
                                                                                                        %lotus-file-system-guix-var))))
(define %lotus-file-system-guix-var-lib    (lotus-build-file-system "/var/lib" "guix" "varSlib"
                                                                    #:check?              %lotus-fs-guix-var-check?
                                                                    #:mount?              #t
                                                                    #:create-mount-point? #t
                                                                    #:needed-for-boot?    #t
                                                                    #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                        %lotus-mapped-device-guix-var
                                                                                                        %lotus-mapped-device-guix-var-lib)
                                                                                                  (list %lotus-file-system-guix-root
                                                                                                        %lotus-file-system-guix-var))))
(define %lotus-file-system-guix-var-log    (lotus-build-file-system "/var/log" "guix" "varSlog"
                                                                    #:check?              %lotus-fs-guix-var-check?
                                                                    #:mount?              #t
                                                                    #:create-mount-point? #t
                                                                    #:needed-for-boot?    #t
                                                                    #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                        %lotus-mapped-device-guix-var
                                                                                                        %lotus-mapped-device-guix-var-log)
                                                                                                  (list %lotus-file-system-guix-root
                                                                                                        %lotus-file-system-guix-var))))
(define %lotus-file-system-guix-var-guix   (lotus-build-file-system "/var/guix" "guix" "varSguix"
                                                                    #:check?              %lotus-fs-guix-var-check?
                                                                    #:mount?              #t
                                                                    #:create-mount-point? #t
                                                                    #:needed-for-boot?    #t
                                                                    #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                        %lotus-mapped-device-guix-var
                                                                                                        %lotus-mapped-device-guix-var-guix)
                                                                                                  (list %lotus-file-system-guix-root
                                                                                                        %lotus-file-system-guix-var))))

(define %lotus-file-system-guix-var-tmp   (lotus-build-file-system "/var/tmp" "guix" "varStmp"
                                                                   ;; https://unix.stackexchange.com/questions/30489/what-is-the-difference-between-tmp-and-var-tmp
                                                                   #:check?              %lotus-fs-guix-var-check?
                                                                   #:mount?              #t
                                                                   #:create-mount-point? #t
                                                                   #:needed-for-boot?    #t
                                                                   #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                       %lotus-mapped-device-guix-var
                                                                                                       %lotus-mapped-device-guix-var-tmp)
                                                                                                 (list %lotus-file-system-guix-root
                                                                                                       %lotus-file-system-guix-var))))

(define %lotus-file-system-house-home      (%lotus-home-build-file-system "/home" "house" "home"
                                                                    #:suffix-seq          0
                                                                    #:check?              %lotus-fs-house-home-check?
                                                                    #:mount?              #t ;; (if %lotus-system-init #f #t)
                                                                    #:create-mount-point? #t
                                                                    #:needed-for-boot?    #f
                                                                    #:dependencies        (append (list %lotus-mapped-device-guix-root
                                                                                                        %lotus-mapped-device-house-home)
                                                                                                  (list)))) ;; %lotus-file-system-guix-root


(define %lotus-file-system-boot-efi        (file-system (mount-point         "/boot/efi")
                                                        (device              %lotus-fs-boot-efi-partition)
                                                        (type                "vfat")
                                                        (check?              #f) ;
                                                        (mount?              %lotus-guix-bootefi-mount?)
                                                        (create-mount-point? %lotus-guix-bootefi-create-mount-point?)
                                                        (needed-for-boot?    %lotus-guix-bootefi-needed-for-boot?)
                                                        (flags               '(read-only))
                                                        (options             "defaults,ro,noauto")
                                                        (dependencies        (append (list %lotus-mapped-device-guix-root)
                                                                                     (list %lotus-file-system-guix-boot
                                                                                           %lotus-file-system-guix-root)))))






(define guilem-kuv500-mapped-devices (append (list %lotus-mapped-device-guix-root      ;8M
                                                   %lotus-mapped-device-guix-boot      ;12M
                                                   %lotus-mapped-device-guix-gnu       ;35G
                                                   %lotus-mapped-device-guix-var       ;10M
                                                   %lotus-mapped-device-guix-var-cache ;8G
                                                   %lotus-mapped-device-guix-var-lib   ;30M
                                                   %lotus-mapped-device-guix-var-log   ;300M
                                                   %lotus-mapped-device-guix-var-guix  ;350M
                                                   %lotus-mapped-device-guix-var-tmp   ;1G
                                                   %lotus-mapped-device-guix-swap      ;1G
                                                   %lotus-mapped-device-sys-tmp        ;20G
                                                   %lotus-mapped-device-house-home)
                                      %local-udev-lvm-mapped-devices))


(define guilem-kuv500-file-systems)


(define-public %guilem-kuv500-features
  (list (feature-host-info #:host-name "guilem-kuv500"
                           ;; ls `guix build tzdata`/share/zoneinfo
                           #:timezone "Asia/Kolkata")
        ;; Allows to declare specific bootloader configuration,
        ;; grub-efi-bootloader used by default
        ;; (feature-bootloader)
        (feature-file-systems #:mapped-devices guilem-kuv500-mapped-devices
                              #:file-systems guilem-kuv500-file-systems)
        (feature-kanshi #:extra-config `((profile laptop
                                                  ((output eDP-1 enable)))
                                         (profile docked
                                                  ((output eDP-1 enable)
                                                   (output DP-2 scale 2)))))
        (feature-hidpi)))
