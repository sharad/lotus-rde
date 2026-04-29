
(define-module (rde-configs configs)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (ice-9 pretty-print)
  #:use-module (gnu services)
  #:use-module (rde features)
  #:use-module (lotus-rde features))

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


;;; Dispatcher, which helps to return various values based on environment
;;; variable value.


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


;;; TODO: Call reconfigure from scheme file.
;;; TODO: Rename configs.scm to main.scm?




;; ixy-config RDE_HOST=ixy RDE_USER=abcdw
;; live-config RDE_HOST=live RDE_USER=guest
(define (dispatcher)

  (define (env-features->symbol envname)
    (let* ((envvar (getenv envname))
           (sym (and envvar (string->symbol (string-append "%" envvar "-features"))))
           (val (and sym (module-ref (current-module) sym #f))))
      (format #t "envname: ~a, envvar: ~a, sym: ~a, null?: ~a\n" envname envvar sym (not val))
      val))

  (let* ((rde-host-features (env-features->symbol "RDE_HOST"))
         (rde-user-fatures  (env-features->symbol "RDE_USER")))

    (format #t "RDE_TARGET: ~a\n" (getenv "RDE_TARGET"))

    (if (and rde-host-features
             rde-user-fatures)
        (let ((config (lotus-make-rde-config #:features
                                             (append rde-host-features
                                                     rde-user-fatures))))
          (let ((rde-target (getenv "RDE_TARGET")))
            (match rde-target
              ("home" (rde-config-home-environment config))
              ("system" (rde-config-operating-system config))
              (_ #f))))
        (begin
          (format #t "Invalid RDE_HOST: ~a or RDE_USER: ~a\n" rde-host-features rde-user-fatures)
          #f))))



(dispatcher)
