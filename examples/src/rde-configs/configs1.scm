(define-module (rde-configs configs1)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (rde-configs hosts gx2-guix-vmware)
  #:use-module (rde-configs users sharad)
  #:use-module (ice-9 pretty-print)
  #:use-module (gnu system)
  #:use-module (gnu services)
  #:use-module (rde features)
  #:use-module (lotus-rde features))

(use-modules (rde features)
             (lotus-rde features)
             (rde-configs hosts gx2-guix-vmware)
             (rde-configs users sharad))

(define gx2-guix-vmware-config
  (lotus-make-rde-config #:features (append %gx2-guix-vmware-features
                                            %sharad-features)))

(display "RDE configuration for gx2-guix-vmware:")
;; (display gx2-guix-vmware-config)

(display "Starting to build now...")
(newline)

(let ((os (rde-config-operating-system gx2-guix-vmware-config)))
  (display "File system configuration:\n")
  (pretty-print (operating-system-file-systems os))
  (display "Mapped devices:\n")
  (pretty-print (operating-system-mapped-devices os))
  (display "Bootloader:\n")
  (pretty-print (operating-system-bootloader os))
  (display "Services:\n")
  (pretty-print (operating-system-services os))

  os)


