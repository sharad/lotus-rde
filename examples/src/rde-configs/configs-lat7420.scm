(define-module (rde-configs configs-lat7420)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  ;; #:use-module (rde-configs hosts guilem-lat7420)
  ;; #:use-module (rde-configs users sharad)
  #:use-module (ice-9 pretty-print)
  #:use-module (gnu system)
  #:use-module (gnu services)
  #:use-module (rde features)
  #:use-module (lotus-rde features))

(use-modules (rde features)
             (lotus-rde features)
             (rde-configs hosts guilem-lat7420)
             (rde-configs users sharad))

(display "Hello")

(define guilem-lat7420-config
  (lotus-make-rde-config #:features (append %guilem-lat7420-features
                                            %sharad-features)))

(display "Starting to build now...")
(newline)

(let ((os (rde-config-operating-system guilem-lat7420-config)))
  (display "File system configuration:\n")
  (pretty-print (operating-system-file-systems os))
  (display "Mapped devices:\n")
  (pretty-print (operating-system-mapped-devices os))
  (display "Bootloader:\n")
  (pretty-print (operating-system-bootloader os))
  (display "Services:\n")
  (pretty-print (operating-system-services os))

  os)


