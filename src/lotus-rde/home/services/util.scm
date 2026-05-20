(define-module (lotus-rde home services utils)
  #:use-module (srfi srfi-1)
  #:use-module (guix records)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages freedesktop)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (rde serializers yaml)
  #:export ())




(define (shepherd-service-log-file name)
  "Return log file path for shepherd service NAME.
Usage: #:log-file #$(shepherd-service-log-file name)"
  (string-append (getenv "HOME") "/.logs/shepherd/" name ".log"))

(define shepherd-service-log-file-gexp
  ;; Usage: #:log-file (#$shepherd-service-log-file-gexp #$(service-name-fn))
  #~(lambda (name)
      (string-append (getenv "HOME") "/.logs/shepherd/" name ".log")))



