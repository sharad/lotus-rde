

(define-module (lotus-rde features profiles)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (rde system services admin)

  ;; #:use-module (guix gexp)
  ;; #:use-module (guix modules)

  ;; #:use-module (nongnu packages linux)
  ;; #:use-module (nongnu system linux-initrd)
  ;; #:use-module (rde predicates)
  ;; #:use-module (rde home services emacs)
  #:use-module (rde features)
  ;; #:use-module (rde features base)
  ;; #:use-module (rde features guile)
  ;; #:use-module (rde features networking)
  ;; #:use-module (rde features system)
  ;; #:use-module (lotus-rde packages python-xyz)
  ;; #:use-module (lotus-rde packages utils)
  #:use-module (lotus-rde home scoped-profiles)
  ;; #:use-module (lotus-rde home services builder)
  ;; #:use-module (lotus-rde home services transients)
  ;; #:use-module (lotus-rde home services utils)
  ;; #:use-module (lotus-rde lib utils)
  #:export (feature-metal-common-profile))




;; 01-doc
;; 01-tools
;; 01-otools
;; 01-crypto
;; 01-x
;; 01-dev
;; 01-text
;; 01-dynamic-hash
;; 01-net
;; 91-build-heavy
;; 01-essential
;; 01-emacs
;; 71-sysdev
;; 60-lengthy
;; 01-simple
;; 01-console
;; 90-heavy
;; 40-servers
;; 01-games
;; 02-java
;; 99-tmp
;; 02-test
;; 99-failed



;; 01-doc
(define home-doc-profile-service-type
  (make-home-profile-service-type 'doc 1))
;; 01-tools
(define home-tools-profile-service-type
  (make-home-profile-service-type 'tools 1))
;; 01-otools
(define home-otools-profile-service-type
  (make-home-profile-service-type 'otools 1))
;; 01-crypto
(define home-crypto-profile-service-type
  (make-home-profile-service-type 'crypto 1))
;; 01-x
(define home-x-profile-service-type
  (make-home-profile-service-type 'x 1))
;; 01-dev
(define home-dev-profile-service-type
  (make-home-profile-service-type 'dev 1))
;; 01-text
(define home-text-profile-service-type
  (make-home-profile-service-type 'text 1))
;; 01-dynamic-hash
(define home-dynamic-hash-profile-service-type
  (make-home-profile-service-type 'dynamic-hash 1))
;; 01-net
(define home-net-profile-service-type
  (make-home-profile-service-type 'net 1))
;; 91-build-heavy
(define home-build-heavy-profile-service-type
  (make-home-profile-service-type 'build-heavy 91))
;; 01-essential
(define home-essential-profile-service-type
  (make-home-profile-service-type 'essential 1))
;; 01-emacs
(define home-emacs-profile-service-type
  (make-home-profile-service-type 'emacs 1))
;; 71-sysdev
(define home-sysdev-profile-service-type
  (make-home-profile-service-type 'sysdev 71))
;; 60-lengthy
(define home-lengthy-profile-service-type
  (make-home-profile-service-type 'lengthy 60))
;; 01-simple
(define home-simple-profile-service-type
  (make-home-profile-service-type 'simple 1))
;; 01-console
(define home-console-profile-service-type
  (make-home-profile-service-type 'console 1))
;; 90-heavy
(define home-heavy-profile-service-type
  (make-home-profile-service-type 'heavy 90))
;; 40-servers
(define home-servers-profile-service-type
  (make-home-profile-service-type 'servers 40))
;; 01-games
(define home-games-profile-service-type
  (make-home-profile-service-type 'games 1))
;; 02-java
(define home-java-profile-service-type
  (make-home-profile-service-type 'java 2))
;; 99-tmp
(define home-tmp-profile-service-type
  (make-home-profile-service-type 'tmp 99))
;; 02-test
(define home-test-profile-service-type
  (make-home-profile-service-type 'test 2))
;; 99-failed
(define home-failed-profile-service-type
  (make-home-profile-service-type 'failed 99))

