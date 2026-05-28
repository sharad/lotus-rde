(define-module (lotus-rde lib shepherd-utils)
  #:export (;; log-file
            make-cmd-destructor))




(define (make-cmd-destructor . command)
  (let ((system-destructor (apply make-system-destructor command))
        (kill-destructor   (make-kill-destructor)))
    (lambda (running . args)
      (apply kill-destructor running args)
      (apply system-destructor running args))))


