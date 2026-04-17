(define-module (rde-configs configs1)
  #:use-module (rde features)
  #:use-module (lotus-rde features)
  #:use-module (gnu services)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (rde-configs hosts gx2-guix-vmware)
  #:use-module (rde-configs users sharad)
  #:use-module (ice-9 pretty-print))


;;; gx2-guix-vmware

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
  gx2-guix-vmware-os)


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
