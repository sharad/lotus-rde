

(define-module (lotus-rde system install)
  #:use-module (gnu)
  #:use-module (gnu packages linux)
  #:use-module (gnu system)
  ;; #:use-module (gnu system install)

  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system privilege)
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
  #:export (guix-with-substitute-mirror
            live-os))


(define %installation-services (@ (gnu system install) %installation-services))

(define %issue
  ;; Greeting.
  "
\x1b[1;37mThis is an installation image of the GNU system.  Welcome.\x1b[0m

\x1b[1;33mUse Alt-F2 for documentation.\x1b[0m
")

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
                               ;; Version displayed in the GRUB entry name.
                               (grub-displayed-version
                                (package-version guix))
                               ;; Whether to use efi-only installation.
                               ;; When #f, use hybrid grub that sets up
                               ;; both legacy boot and efi.
                               (efi-only? #f))
  ;; The operating system used on installation images for USB sticks etc.
  (operating-system
    (host-name "gnu")
    (timezone "Europe/Paris")
    (locale "en_US.utf8")
    (name-service-switch %mdns-host-lookup-nss)

    (initrd-modules (%installation-initrd-modules))

    (bootloader (if efi-only?
                    (bootloader-configuration
                      (bootloader grub-efi-bootloader)
                      (targets '("/boot/efi")))
                    (bootloader-configuration
                      (bootloader grub-bootloader)
                      (targets '("/dev/sda")))))
    (label (string-append "GNU Guix installation " grub-displayed-version))

    ;; XXX: The AMD Radeon driver is reportedly broken, which makes kmscon
    ;; non-functional:
    ;; <https://lists.gnu.org/archive/html/guix-devel/2019-03/msg00441.html>.
    ;; Thus, blacklist it.
    (kernel-arguments '("quiet" "modprobe.blacklist=radeon,amdgpu"))

    (file-systems
     ;; Note: the disk image build code overrides this root file system with
     ;; the appropriate one.
     (append %base-live-file-systems

             ;; XXX: This should be %BASE-FILE-SYSTEMS but we don't need
             ;; elogind's cgroup file systems.
             (list %pseudo-terminal-file-system
                   %shared-memory-file-system
                   %efivars-file-system
                   %immutable-store)))

    (users (list (user-account
                   (name "guest")
                   (group "users")
                   (supplementary-groups '("wheel")) ; allow use of sudo
                   (password "")
                   (comment "Guest of GNU"))))

    (issue %issue)
    (services (%installation-services))

    ;; We don't need setuid programs, except for 'passwd', which can be handy
    ;; if one is to allow remote SSH login to the machine being installed.
    (privileged-programs (list (privileged-program
                                 (program (file-append shadow "/bin/passwd"))
                                 (setuid? #t))))

    (pam-services
     ;; Explicitly allow for empty passwords.
     (base-pam-services #:allow-empty-passwords? #t))

    (packages (append
               (list glibc             ; for 'tzselect' & co.
                     fontconfig
                     font-dejavu font-gnu-unifont

                     ;; Mostly so xrefs to its manual work.
                     (bootloader-package
                      (bootloader-configuration-bootloader bootloader)))
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


guix-with-substitute-mirror
