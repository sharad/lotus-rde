(define-module (lotus-rde rde api defaults)
  ;; #:use-module (rde features)
  ;; #:use-module (rde features emacs)
  ;; #:use-module (rde predicates)
  ;; #:use-module (rde serializers elisp)
  ;; #:use-module (gnu services)
  ;; #:use-module (gnu home services)
  ;; #:use-module (gnu packages markup)
  ;; #:use-module (gnu packages haskell-xyz)
  ;; #:use-module (gnu packages emacs-xyz)
  ;; #:use-module (gnu packages tex)
  #:use-module (guix gexp)
  #:use-module (guix build utils)
  #:use-module (gnu system uuid)
  #:use-module (gnu services)
  #:use-module (gnu services networking)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages shells)
  #:use-module (lotus-rde rde api utils)
  #:export (build-mapped-device))



(define %lotus-system-init #f)
(define %lotus-use-nongnu  #t)

(define nongnu-desktop?    %lotus-use-nongnu)




(define build-srv-local-file-system  (build-parent-dir-file-system-builder "/srv/volumes/local"))
(define build-srv-distro-file-system (build-parent-dir-file-system-builder "/srv/volumes/distro"))


(define %local-udev-lvm-mapped-devices             '())
(define %local-mount-lvm-non-system-file-systems   '())
(define %local-unmount-lvm-non-system-file-systems '())


(define %local-fs-boot-efi-partition (uuid "0000-0000" 'fat32))
(define %local-fs-boot-efi-device    "/dev/sda1")


(define %lotus-local-services (list (service tor-service-type)))


(define %local-grub-ubuntu-menuentries (list))

(define %lotus-grub-bootloader grub-efi-bootloader)
(define %lotus-grub-targets    '("/boot/efi"))


(define %local-bitlbee-service-use-default?  #f)
(define %local-account-uid                   1000)
(define %local-account-user-name             "s")
(define %local-account-comment               "sharad")
(define %local-account-group-name            "users")
(define %local-account-group-gid              1000)
(define %local-account-supplementry-groups   (append '("wheel" "netdev" "audio" "video")
                                                     (if %lotus-system-init
                                                       '()
                                                       '("docker"))))
(define %local-account-home-parent-directory "/home")
(define %local-account-relative-home-directory (string-append %local-account-user-name "/" "hell"))
(define %local-account-shell                 #~(string-append #$zsh "/bin/zsh"))


(define %local-guest-user-name             "guest")
(define %local-guest-comment               "Guest")
(define %local-guest-group-name            "users")
(define %local-guest-group-gid             %local-account-group-name)
(define %local-guest-relative-home-directory %local-guest-user-name)
(define %local-guest-supplementry-groups   (append '("netdev" "audio" "video")
                                                   (if %lotus-system-init
                                                     '()
                                                     '("docker"))))


(define %local-gdm-auto-login                #f)
(define %local-gdm-allow-empty-password      #t)




;; (define %local-nm-dnsmasq-ns-path         #~(string-append #$nm-dnsmasq-ns "/etc/NetworkManager/dnsmasq.d"))

(define %local-account-create-home-directory #f)
(define %local-network-manager-dns           "dnsmasq")


(define %local-guix-publish-advertise          #t)
(define %local-guix-publish-port               80)
(define %local-guix-publish-host               "0.0.0.0")
(define %local-guix-publish-compression        '(("lzip" 7) ("gzip" 9)))
(define %local-guix-publish-cache              "/var/cache/guix/publish")
(define %local-guix-publish-cache-bypass-threshold (* 100 1024 1024))
(define %local-guix-publish-ttl                (* 1 24 60 60))


(define %local-guix-configuration-discover       #t)
(define %local-guix-configuration-build-accounts 10)
(define %local-guix-configuration-authorize-key? #f)
(define %local-guix-configuration-local-fixed-named-substitute-urls '())
;; "http://local.guix-01"
;; "http://local.guix-02"
;; "http://local.guix-03"
;; "http://local.guix-04"

(define %local-guix-configuration-local-substitute-urls '())

(define %local-guix-configuration-substitute-urls       '(;; "https://ci.guix.gnu.org"
                                                          ;; "https://bayfront.guixsd.org"
                                                          ;; "http://guix.genenetwork.org" -- Backtrace
                                                          ;; "https://berlin.guixsd.org"
                                                          "https://cuirass.genenetwork.org"
                                                          "https://guix.tobias.gr"
                                                          "https://bordeaux.guix.gnu.org"
                                                          "https://ci.guix.info/"
                                                          "https://berlin.guix.gnu.org"
                                                          "https://substitutes.nonguix.org"))
(define %local-guix-configuration-extra-options         '(
                                                          ;; "--max-jobs=2"
                                                          ;; "--cores=1"
                                                          "--gc-keep-derivations=yes"
                                                          "--gc-keep-outputs=yes"))
(define %local-guix-configuration-use-substitutes       #t) ;always true
;; (define %local-guix-configuration-tmpdir         #f)
(define %local-guix-configuration-tmpdir "/tmp/guix-build-workspace/build/tmp")


(define %local-fs-guix-check?                   #t)
(define %local-fs-guix-root-check?              %local-fs-guix-check?)
(define %local-fs-guix-boot-check?              %local-fs-guix-check?)
(define %local-fs-guix-gnu-check?               %local-fs-guix-check?)
(define %local-fs-sys-tmp-check?                %local-fs-guix-check?)
(define %local-fs-guix-var-check?               %local-fs-guix-check?)


(define %local-fs-house-check?                  #t)
(define %local-fs-house-home-check?             %local-fs-house-check?)

(define %local-guix-boot-mount?                 #f)
(define %local-guix-boot-create-mount-point?    #f)
(define %local-guix-boot-needed-for-boot?       #f)
(define %local-guix-bootefi-mount?              #f)
(define %local-guix-bootefi-create-mount-point? #f)
(define %local-guix-bootefi-needed-for-boot?    #f)


(define %local-locale "en_US.utf8")

(define %local-locate-names (list "en_US"
                                  "hi_IN"
                                  "ur_PK"
                                  "fa_IR"
                                  "ar_SA"))


(define %local-timezone  "Asia/Kolkata")


(define %local-kernel-loadable-modules (list v4l2loopback-linux-module))

