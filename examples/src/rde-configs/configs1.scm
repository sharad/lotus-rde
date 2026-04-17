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

(use-modules (rde features)
             (lotus-rde features)
             (rde-configs hosts gx2-guix-vmware)
             (rde-configs users sharad))

(define gx2-guix-vmware-config
  (rde-config
   (features
    (append %gx2-guix-vmware-features
            %sharad-features))))
(rde-config-operating-system gx2-guix-vmware-config)

;;; TODO: Call reconfigure from scheme file.
;;; TODO: Rename configs.scm to main.scm?
