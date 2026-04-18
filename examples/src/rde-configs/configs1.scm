(define-module (rde-configs configs1)
  #:use-module (rde features)
  #:use-module (lotus-rde features)
  #:use-module (gnu services)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (rde-configs hosts guilem-kuv500)
  #:use-module (rde-configs users sharad)
  #:use-module (ice-9 pretty-print))



(use-modules (rde features)
             (lotus-rde features)
             (rde-configs hosts guilem-kuv500)
             (rde-configs users sharad))


;; (display %guilem-kuv500-features)


(define guilem-kuv500-config
  (rde-config
   (features
    (append %guilem-kuv500-features
            %sharad-features))))
(display "HELLO")
(newline)
(display %sharad-features)
(newline)
(display "HELLO")
(newline)

(let ((os (rde-config-operating-system guilem-kuv500-config)))
  (display os)
  (newline)
  os)


