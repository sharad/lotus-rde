(define-module (rde-configs hosts dell5480)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (ice-9 match))


;;; Hardware/host specifis features

;; TODO: Switch from UUIDs to partition labels For better
;; reproducibilty and easier setup.  Grub doesn't support luks2 yet.

(define dell5480-mapped-devices
  (list (mapped-device
         (source (uuid "6243841f-4171-43dd-8e0b-93bddd56daaa"))
         (target "enc")
         (type luks-device-mapping))))

(define dell5480-file-systems
  (append
   btrfs-subvolumes
   (list
    ;; persist all system data to data
    (file-system
      (device "/data/system/var/lib")
      (type "none")
      (mount-point "/var/lib")
      (flags '(bind-mount))
      ;; (options "bind")
      (dependencies (list data-fs)))
    (file-system
      (mount-point "/boot/efi")
      (type "vfat")
      (device (uuid "97DB-35DC" 'fat32))))))

(define-public %dell5480-features
  (list
   (feature-host-info
    #:host-name "dell5480"
    ;; ls `guix build tzdata`/share/zoneinfo
    #:timezone  "Asia/Kolkata")
   ;;; Allows to declare specific bootloader configuration,
   ;;; grub-efi-bootloader used by default
   ;; (feature-bootloader)
   (feature-file-systems
    #:mapped-devices dell5480-mapped-devices
    #:file-systems   dell5480-file-systems)
   (feature-kanshi
    #:extra-config
    `((profile laptop ((output eDP-1 enable)))
      (profile docked ((output eDP-1 enable)
                       (output DP-2 scale 2)))))
   (feature-hidpi)))
