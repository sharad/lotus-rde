(define-module (rde-configs configs)
  #:use-module (rde features)
  #:use-module (lotus-rde features)
  #:use-module (gnu services)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (ice-9 pretty-print))

(define* (use-nested-configuration-modules
          #:key
          (users-subdirectory "/users")
          (hosts-subdirectory "/hosts"))
  (use-modules (guix discovery)
               (guix modules))

  (define current-module-file
    (search-path %load-path
                 (module-name->file-name (module-name (current-module)))))
  (define current-module-directory
    (dirname (and=> current-module-file canonicalize-path)))

  (define src-directory
    (dirname current-module-directory))

  (define current-module-subdirectory
    (string-drop current-module-directory (1+ (string-length src-directory))))

  (define users-modules
    (scheme-modules
     src-directory
     (string-append current-module-subdirectory users-subdirectory)
     #:warn (lambda (. args)
              (map display  args))))

  (define hosts-modules
    (scheme-modules
     src-directory
     (string-append current-module-subdirectory hosts-subdirectory)
     #:warn (lambda (. args)
              (map display  args))))

  (map (lambda (x) (module-use! (current-module) x)) hosts-modules)
  (map (lambda (x) (module-use! (current-module) x)) users-modules))

(use-nested-configuration-modules)


;;; Some TODOs

;; TODO: Add an app for saving and reading articles and web pages
;; https://github.com/wallabag/wallabag
;; https://github.com/chenyanming/wallabag.el

;; TODO: feature-wallpapers https://wallhaven.cc/
;; TODO: feature-icecat
;; TODO: Revisit <https://en.wikipedia.org/wiki/Git-annex>
;; TODO: <https://www.labri.fr/perso/nrougier/GTD/index.html#table-of-contents>


;;; ixy

(define-public ixy-config
  (rde-config
   (features
    (append
     %ixy-features
     %abcdw-features))))
   ;; (operating-system (lotus-get-operating-system this-rde-config))

(define-public ixy-os
  (rde-config-operating-system ixy-config))

(define-public ixy-he
  (rde-config-home-environment ixy-config))

;;; live

;; TODO: Pull channels from lock file in advance and link them to example-config
;; TODO: Add auto-login

(define-public live-config
  (rde-config
   (integrate-he-in-os? #t)
   (features
    (append
     %live-features
     %guest-features))))

(define-public live-os
  (rde-config-operating-system live-config))

;;; dell5480

(define-public dell5480-config
  (rde-config
   (features
    (append
     %dell5480-features
     %sharad-features))))

(define-public dell5480-os
  (rde-config-operating-system dell5480-config))

(define-public dell5480-he
  (rde-config-home-environment dell5480-config))

;;; guilem-lat7420

(define-public guilem-lat7420-config
  (rde-config
   (features
    (append %guilem-lat7420-features
            %sharad-features))))

(define-public guilem-lat7420-os
  (rde-config-operating-system guilem-lat7420-config))

(define-public guilem-lat7420-he
  (rde-config-home-environment guilem-lat7420-config))

;;; guilem-kuv500

(define-public guilem-kuv500-config
  (rde-config
   (features
    (append %guilem-kuv500-features
            %sharad-features))))

(define-public guilem-kuv500-os
  (rde-config-operating-system guilem-kuv500-config))

(define-public guilem-kuv500-he
  (rde-config-home-environment guilem-kuv500-config))

;;; guilem-lat7420

(define-public gx2-guix-vmware-config
  (rde-config
   (features
    (append %gx2-guix-vmware-features
            %sharad-features))))

(define-public gx2-guix-vmware-os
  (rde-config-operating-system gx2-guix-vmware-config))

(define-public gx2-guix-vmware-he
  (rde-config-home-environment gx2-guix-vmware-config))

;;; Dispatcher, which helps to return various values based on environment
;;; variable value.

(define (dispatcher)
  (let ((rde-target (getenv "RDE_TARGET")))
    (match rde-target
      ("ixy-home" ixy-he)
      ("ixy-system" ixy-os)
      ("live-system" live-os)
      ("dell5480-home" dell5480-he)
      ("dell5480-system" dell5480-os)
      ("guilem-kuv500-home" guilem-kuv500-he)
      ("guilem-kuv500-system" guilem-kuv500-os)
      ("guilem-lat7420-home" guilem-lat7420-he)
      ("guilem-lat7420-system" guilem-lat7420-os)
      ("gx2-guix-vmware-home" gx2-guix-vmware-he)
      ("gx2-guix-vmware-system" gx2-guix-vmware-os)
      (_ gx2-guix-vmware-os))))

;; (pretty-print-rde-config ixy-config)
;; (use-modules (gnu services)
;;           (gnu services base))
;; (display
;;  (filter (lambda (x)
;;         (eq? (service-kind x) console-font-service-type))
;;       (rde-config-system-services ixy-config)))

;; (use-modules (rde features))
;; ((@ (ice-9 pretty-print) pretty-print)
;;  (map feature-name (rde-config-features ixy-config)))

;; ((@ (ice-9 pretty-print) pretty-print)
;;  (rde-config-home-services ixy-config))

;; (define br ((@ (rde api store) build-with-store) ixy-he))
(dispatcher)


;;; TODO: Call reconfigure from scheme file.
;;; TODO: Rename configs.scm to main.scm?






(define (dispatcher)

  (define (env-var->symbol envname)
    (let* ((envvar (getenv envname))
           (sym (and envvar (string->symbol envvar)))
           (val (and sym (module-ref (current-module) sym #f))))
      (or var #f)))

  (let* ((rde-host-feature (env-var->symbol "RDE_HOST"))
         (rde-user-fature  (env-var->symbol "RDE_USER")))
    (if (and rde-host-feature
             rde-user-fature)
        (let ((config (rde-config
                       (features
                        (append rde-host-feature
                                rde-user-fature)))))
          (let ((rde-target (getenv "RDE_TARGET")))
            (match rde-target
              ("home" (rde-config-home-environment config))
              ("system" (rde-config-operating-system config))
              (_ #f))))
        (begin
          (format #t "Invalid RDE_TARGET: ~a\n" target)
          #f))))



(dispatcher)
