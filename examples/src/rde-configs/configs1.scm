(define-module (rde-configs configs1)
  #:use-module (rde features)
  #:use-module (lotus-rde features)
  #:use-module (gnu services)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (rde-configs hosts guilem-kuv500)
  #:use-module (rde-configs users sharad)
  #:use-module (ice-9 pretty-print))


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
