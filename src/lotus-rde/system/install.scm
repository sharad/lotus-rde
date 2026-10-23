

(define-module (lotus-rde system install)
  #:use-module (ice-9 pretty-print)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix channels)
  #:use-module (gnu)
  #:use-module (gnu packages linux)
  #:use-module (gnu system)

  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system privilege)
  #:use-module (gnu system install)
  #:use-module (guix build-system trivial)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (guix gexp)
  #:use-module (guix store)
  #:use-module (guix modules)
  #:use-module ((guix packages) #:select (package-version supported-package?))
  #:autoload   (guix channels) (channel? channel-commit)
  #:use-module (guix platform)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module ((guix channels)
                #:select (%default-guix-channel
                          channel
                          channel-commit))
  #:use-module (gnu installer)
  #:use-module (gnu system locale)
  #:use-module (gnu services avahi)
  #:use-module (gnu services dbus)
  #:use-module (gnu services networking)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services ssh)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bootloaders)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cryptsetup)
  #:use-module (gnu packages disk)
  #:use-module (gnu packages file-systems)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages xorg)
  #:use-module (ice-9 match)


  #:use-module (rde features)
  #:use-module (rde features system)
  #:use-module (rde features base)
  #:use-module (lotus-rde config misc)
  #:export (guix-with-substitute-mirror
            live-os))

(define %lotus-installer-disk-utilities
  ;; A well-rounded set of packages for interacting with disks, partitions and
  ;; file systems, included with the Guix installation image.
  (list parted gptfdisk ddrescue
        ;; Use the static LVM2 because it's already pulled in by the installer.
        lvm2-static
        ;; We used to provide fdisk from GNU fdisk, but as of version 2.0.0a
        ;; it pulls Guile 1.8, which takes unreasonable space; furthermore
        ;; util-linux's fdisk is already available, in %base-packages-linux.
        ;; cryptsetup
        mdadm
        dosfstools
        ;; btrfs-progs
        ;; jfsutils
        ;; xfsprogs
        e2fsprogs
        f2fs-tools))

(define* (make-installation-os #:key
                               (kernel (operating-system-kernel installation-os))
                               (inherit-os installation-os)
                               (substitute-urls '())
                               (authorized-guix-keys '())
                               (base-substitute-urls %lotus-rde-substitute-urls)
                               (base-authorized-guix-keys %lotus-rde-authorized-guix-keys)
                               (channels %lotus-rde-channels)
                               (efi-only? #f))
  (define channel->code
    (@@ (gnu services) channel->code))

  (define (object->pretty-string obj)
    (call-with-output-string
      (lambda (port)
        (pretty-print obj port))))
  (define channels-file
    (plain-file
     "channels.scm"
     (object->pretty-string
      `(list
        ,@(map channel->code
               (append channels
                       %default-channels))))))
  ;; The operating system used on installation images for USB sticks etc.
  (operating-system
    (inherit inherit-os)
    (kernel kernel)
    (services
     (cons*
      ;; Include the channel file so that it can be used during installation
      (simple-service
       'lotus-channel-file
       etc-service-type
       (list `("guix/channels.scm" ,channels-file)))
      (modify-services (operating-system-user-services inherit-os)
        (guix-service-type
         config => (guix-configuration
                    (inherit config)
                    (guix (guix-for-channels (append channels
                                                     %default-channels)))
                    (authorized-keys
                     (append %default-authorized-guix-keys
                             authorized-guix-keys
                             base-authorized-guix-keys))
                    (substitute-urls
                     (append %default-substitute-urls
                             substitute-urls
                             base-substitute-urls))
                    (channels (append channels
                                      %default-channels)))))))
    (packages (append
               ;; (operating-system-packages installation-os)
               (list glibc             ; for 'tzselect' & co.
                     fontconfig
                     font-dejavu font-gnu-unifont

                     ;; Mostly so xrefs to its manual work.
                     (bootloader-package
                      (bootloader-configuration-bootloader (operating-system-bootloader inherit-os))))
               %lotus-installer-disk-utilities
               %base-packages))))

(define lotus-installation-os (make-installation-os))


(define guix-with-substitute-mirror
  (operating-system
    (inherit lotus-installation-os)
    (services
     (modify-services (operating-system-user-services lotus-installation-os)
      (guix-service-type
       config =>
       (guix-configuration
        (inherit config)
        (substitute-urls '("http://ci.guix.trop.in"
                           "https://bordeaux.guix.gnu.org"))))))))


(define live-file-systems
  (list (file-system
          (mount-point "/")
          (device (file-system-label "Guix_image"))
          (type "ext4"))
        (file-system
          (mount-point "/tmp")
          (device "none")
          (type "tmpfs")
          (check? #f))))

(define* (live-os
          #:key
          (kernel linux-libre)
          (kernel-firmware '())
          (guix-substitute-urls '())
          (guix-authorized-keys '())
          (custom-system-services '())
          (supplementary-system-packages '())
          (supplementary-features '())) ;; user-preferences
  (rde-config-operating-system
   (rde-config
    (initial-os lotus-installation-os)
    (features
     (append
      supplementary-features
      (list
       (feature-file-systems
        #:file-systems live-file-systems)
       (feature-kernel
        #:kernel kernel
        #:firmware kernel-firmware)
       (feature-base-packages
        #:system-packages supplementary-system-packages)
       (feature-custom-services
        #:feature-name-prefix 'live
        #:system-services custom-system-services)
       (feature-base-services
        #:guix-substitute-urls guix-substitute-urls
        #:guix-authorized-keys guix-authorized-keys)))))))



;; guix system image -t iso9660 \
;; -e '(@ (lotus-rde system install) guix-with-substitute-mirror)'


;; guix system image -t iso9660 lotus-rde/system/install.scm


;; guix-with-substitute-mirror
lotus-installation-os
