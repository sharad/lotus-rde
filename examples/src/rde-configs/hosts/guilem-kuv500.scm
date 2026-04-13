(define-module (rde-configs hosts guilem-kuv500)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (rde-configs default)
  #:use-module (ice-9 match))



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
  (let-values (((rootfs sys-devices sys-fs) (devfs-system))
               ((home-devices home-fs) (devfs-system)))
    (list (feature-host-info #:host-name "guilem-kuv500"
                             ;; ls `guix build tzdata`/share/zoneinfo
                             #:timezone "Asia/Kolkata")
          ;; Allows to declare specific bootloader configuration,
          ;; grub-efi-bootloader used by default
          ;; (feature-bootloader)
          (feature-file-systems #:mapped-devices (append sys-devices home-devices)
                                #:file-systems (append sys-fs home-fs))
          (feature-kanshi #:extra-config `((profile laptop
                                                    ((output eDP-1 enable)))
                                           (profile docked
                                                    ((output eDP-1 enable)
                                                     (output DP-2 scale 2)))))
          (feature-hidpi))))

