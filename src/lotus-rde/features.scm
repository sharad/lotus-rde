
(define-module (lotus-rde features)
  #:use-module (guix records)
  #:use-module (guix ui)
  #:use-module (guix gexp)

  #:use-module (gnu services)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system accounts)
  #:use-module (gnu system shadow)
  #:use-module (gnu system nss)
  #:use-module (gnu services guix)
  #:use-module (gnu services shepherd)
  #:use-module (rde system bare-bone)
  #:use-module (rde system services accounts)
  #:use-module (rde system services admin)

  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu home)
  #:use-module (gnu services configuration)

  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:use-module (srfi srfi-35)

  #:use-module (ice-9 hash-table)
  #:use-module (ice-9 match)
  #:use-module (ice-9 pretty-print)
  #:use-module (rde features)
  #:export (lotus-make-rde-config))



(define (lotus-get-operating-system config)
  (define rde-config-integrate-he-in-os?
    (@@ (rde features) rde-config-integrate-he-in-os?))
  (define rde-config-initial-os
    (@@ (rde features) rde-config-initial-os))
  (define (resume-swap-device config)
    (let ((swap-devices (get-value 'swap-devices config '())))
      (if (and (pair? swap-devices)
               (> (length swap-devices) 0))
          (list (string-append "resume="
                               (swap-space-target (car swap-devices))))
          '())))


  (when (rde-config-integrate-he-in-os? config)
    (require-value 'user-name config))
  (let* ((initial-os (rde-config-initial-os config))

         (rde-host-name    (get-value
                            'host-name config
                            (operating-system-host-name initial-os)))
         (rde-timezone     (get-value
                            'timezone config
                            (operating-system-timezone initial-os)))
         (rde-locale       (get-value
                            'locale config
                            (operating-system-locale initial-os)))
         (rde-issue        (get-value
                            'issue config
                            (operating-system-locale initial-os)))
         (rde-keyboard-layout
                           (get-value
                            'keyboard-layout config
                            (operating-system-keyboard-layout initial-os)))
         (rde-bootloader-cfg
                           (get-value
                            'bootloader-configuration config
                            (operating-system-bootloader initial-os)))
         (rde-bootloader   (bootloader-configuration
                            (inherit rde-bootloader-cfg)
                            (keyboard-layout rde-keyboard-layout)))
         (rde-mapped-devices
                           (get-value
                            'mapped-devices config
                            (operating-system-mapped-devices initial-os)))
         (rde-swap-devices (get-value
                            'swap-devices config
                            (operating-system-swap-devices initial-os)))
         (rde-file-systems (get-value
                            'file-systems config
                            (operating-system-file-systems initial-os)))

         (rde-user-name    (get-value 'user-name config #f))
         (rde-user-id      (get-value 'user-id config 1000))
         (rde-user-group   (get-value 'user-group config "users"))
         (rde-full-name    (get-value 'full-name config ""))
         (rde-user-groups  (get-value 'user-groups config '()))
         (rde-home-directory
                           (get-value
                            'home-directory config
                            (string-append "/home/" (or rde-user-name "user"))))
         (rde-login-shell  (get-value 'login-shell config (default-shell)))
         (rde-user-password
                           (get-value 'user-initial-password-hash config #f))

         (rde-user         (if rde-user-name
                               (user-account
                                (uid  rde-user-id)
                                (name rde-user-name)
                                (comment rde-full-name)
                                (password rde-user-password)
                                (home-directory rde-home-directory)
                                (shell rde-login-shell)
                                (group rde-user-group)
                                (supplementary-groups rde-user-groups))
                               #f))

         (rde-services     (rde-config-system-services config))

         (rde-kernel       (get-value
                            'kernel config
                            (operating-system-kernel initial-os)))
         (rde-kernel-arguments (append (resume-swap-device config)
                                       (get-value
                                        'kernel-arguments config
                                        (operating-system-user-kernel-arguments initial-os))))
         (rde-kernel-modules
                           (get-value
                            'kernel-loadable-modules config
                            (operating-system-kernel-loadable-modules initial-os)))
         (rde-initrd       (get-value
                            'initrd config
                            (operating-system-initrd initial-os)))
         (rde-initrd-modules
                           (get-value
                            'initrd-modules config
                            (operating-system-initrd-modules initial-os)))
         (rde-firmware     (get-value
                            'firmware config
                            (operating-system-firmware initial-os)))
         (rde-name-service-switch
                           (get-value
                            'name-service config
                            %default-nss))

         (computed-os
          (operating-system
            (inherit initial-os)
            (host-name rde-host-name)
            (timezone rde-timezone)
            (locale rde-locale)
            (issue rde-issue)
            (bootloader rde-bootloader)
            (mapped-devices rde-mapped-devices)
            (swap-devices rde-swap-devices)
            (file-systems rde-file-systems)
            (keyboard-layout rde-keyboard-layout)
            (kernel rde-kernel)
            (kernel-arguments rde-kernel-arguments)
            (kernel-loadable-modules rde-kernel-modules)
            (initrd rde-initrd)
            (initrd-modules rde-initrd-modules)
            (firmware rde-firmware)
            (services (append
                       rde-services
                       (if (rde-config-integrate-he-in-os? config)
                           (list (service guix-home-service-type
                                          ;; TODO: [Andrew Tropin, 2024-05-27]
                                          ;; Temporary fix, remove it, when
                                          ;; https://issues.guix.gnu.org/71111 is
                                          ;; merged
                                          `(,(list
                                              rde-user-name
                                              (get-home-environment config)))))
                           '())
                       (list (service sudoers-service-type))
                       (if rde-user-name
                           (list (service rde-account-service-type rde-user))
                           '())))
            (sudoers-file #f)
            (name-service-switch rde-name-service-switch))))
    ;; Only apply transformations on thunked fields here.
    (operating-system
      (inherit computed-os)
      (essential-services
       (modify-services (operating-system-essential-services computed-os)
         (shepherd-root-service-type
          this-config =>
          (shepherd-configuration
           (inherit this-config)
           (shepherd (get-value 'shepherd config)))))))))

(define* (lotus-make-rde-config #:key (features '()))
  (define (make-os-thunk f)
    (lambda (cfg)
      (f cfg)))
  (letrec ((cfg (rde-config
                 (features features)
                 (operating-system
                   ((make-os-thunk lotus-get-operating-system) cfg)))))
    cfg))
