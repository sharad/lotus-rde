;;; rde --- Reproducible development environment.
;;;
;;; Copyright © 2023 Miguel Ángel Moreno <mail@migalmoreno.com>
;;;
;;; This file is part of rde.
;;;
;;; rde is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; rde is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with rde.  If not, see <http://www.gnu.org/licenses/>.

(define-module (lotus-rde home services transients)
  #:use-module (srfi srfi-1)
  #:use-module (guix records)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages ssh)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (rde serializers yaml)
  #:use-module (lotus-rde lib utils)
  #:export (home-ssh-tunnel-service-type
            home-autossh-tunnel-service-type
            home-ssh-gpg-tunnel-service-type
            home-spawner-service-type
            <home-spawner-configuration>
            make-home-spawner-configuration
            home-spawner-configuration?
            home-spawner-configuration-name
            home-spawner-configuration-constructor-gexp
            home-spawner-configuration-capable?))


(define-record-type* <home-spawner-configuration>
  home-spawner-configuration
  make-home-spawner-configuration
  home-spawner-configuration?
  (name
   home-spawner-configuration-name)
  ;; gexp evaluating to a procedure: (inst-name service-name-fn . kwargs) -> <start-value>
  (constructor-gexp
   home-spawner-configuration-constructor-gexp)
  (capable?
   home-spawner-configuration-capable?
   (default #~(lambda _ #t))))

;; Shared helper definitions, staged once and spliced (via #$helpers)
;; into every action's own gexp below. They MUST live inside a gexp:
;; they run inside the shepherd process, not inside the process that
;; builds this home-environment, so they can't be plain closures here.
(define helpers
  #~(begin
      (define (plist-ref plist key default)
        (let ((p (memq key plist)))
          (cond
           ((not p) default)
           ((null? (cdr p)) (error "Keyword without value" key))
           (else (cadr p)))))

      (define (string->keyword s)
        (symbol->keyword (string->symbol s)))

      (define (string->value s)
        (cond
         ((string=? s "t") #t)
         ((string=? s "f") #f)
         ((string->number s) => values)
         (else s)))

      (define (strings->keyword-args lst)
        (let loop ((lst lst) (out '()))
          (cond
           ((null? lst) (reverse out))
           ((null? (cdr lst)) (error "Odd number of keyword arguments" lst))
           (else
            (loop (cddr lst)
                  (cons (string->value (cadr lst))
                        (cons (string->keyword (car lst)) out)))))))

      (define (service-running-safe? svc-name)
        (let ((svc (lookup-service svc-name)))
          (if svc (service-running? svc) svc)))

      (define (string-has-prefix? prefix str)
        (let ((plen (string-length prefix)))
          (and (<= plen (string-length str))
               (string=? prefix (substring str 0 plen)))))

      (define* (service-sym spawner-service
                            inst-name
                            #:key
                            (transient? #t))
        (string->symbol (service-name-str spawner-service
                                          inst-name
                                          #:transient? transient?)))

      (define* (service-name-str spawner-service
                                 inst-name
                                 #:key (transient? #t))
        (format #f "~a~a-~a"
                (if transient?
                    "transient-"
                    "")
                (symbol->string spawner-service)
                inst-name))

      (define (is-service-sym? spawner-service service)
        (let ((prefix (symbol->string spawner-service)))
          (or (string-has-prefix? (format #f "~a-" prefix) (symbol->string service))
              (string-has-prefix? (format #f "transient-~a-" prefix) (symbol->string service)))))

      (define* (make-spawner-service spawner-service
                                     constructor-fn
                                     inst-name
                                     #:key
                                     (respawn? #f)
                                     (respawn-delay 5)
                                     (respawn-limit 20)
                                     (transient? #t)
                                     (one-shot? #f)
                                     #:allow-other-keys
                                     #:rest rest-keys)
        (service (list (service-sym spawner-service inst-name #:transient? transient?))
                 #:start (apply constructor-fn inst-name
                                (lambda () (service-name-str spawner-service inst-name #:transient? transient?))
                                (append (list #:transient? transient?)
                                        rest-keys))
                 #:stop (make-kill-destructor)
                 #:requirement (list spawner-service)
                 #:respawn-delay respawn-delay
                 #:respawn-limit respawn-limit
                 #:respawn? respawn?
                 #:transient? transient?
                 #:one-shot? one-shot?))))

(define (spawner-config->shepherd-service config)
  (let ((spawner-name (home-spawner-configuration-name config))
        (constructor  (home-spawner-configuration-constructor-gexp config))
        (capable?     (home-spawner-configuration-capable? config)))
    (shepherd-service
     (provision (list spawner-name))
     (documentation (format #f "Spawner for ~a services" spawner-name))
     (start #~(lambda args #t))
     (stop  #~(lambda args #t))
     (respawn? #f)
     (actions
      (list
       (shepherd-action
        (name 'spawn)
        (documentation "herd spawn <spawner> <inst-name> [key val ...]")
        (procedure
         #~(lambda (running . args)
             #$helpers
             (if (null? args)
                 (format #t "Usage: herd spawn ~a <inst-name> [key val ...]\n"
                         '#$spawner-name)
                 (let* ((inst-name (car args))
                        (vargs (cdr args))
                        (kw-args  (strings->keyword-args vargs))
                        (svc-name (service-sym '#$spawner-name inst-name #:transient? (plist-ref kw-args #:transient? #t))))
                   (format #t "spawn: svc-name = ~a\n" svc-name)
                   (if (not (#$capable?))
                       (begin
                         (format #t "Error: Not able to run this service.\n")
                         #f)
                       (if (not (service-running-safe? svc-name))
                           (let ((svc (apply make-spawner-service
                                             '#$spawner-name
                                             #$constructor
                                             inst-name
                                             kw-args)))
                             (register-services (list svc))
                             (apply start-service svc vargs)
                             (format #t "Started new service: ~a\n" svc-name))
                           (format #t "Service ~a already running.\n" svc-name))))))))

       (shepherd-action
        (name 'destroy)
        (documentation "herd destroy <spawner> <inst-name> [unregister]")
        (procedure
         #~(lambda (running . args)
             #$helpers
             (if (null? args)
                 (format #t "Usage: herd destroy ~a <inst-name> [unregister]\n"
                         '#$spawner-name)
                 (let* ((inst-name (car args))
                        (unregister? (member "unregister" (cdr args)))
                        (kw-args  (if unregister?
                                      (strings->keyword-args (cdr args))
                                      (strings->keyword-args args)))
                        (svc-name (service-sym '#$spawner-name inst-name #:transient? (plist-ref kw-args #:transient? #t)))
                        (svc (lookup-service svc-name)))
                   (if (not svc)
                       (format #t "Not found: ~a\n" svc-name)
                       (begin
                         (when (service-running? svc)
                           (stop-service svc))
                         (if unregister?
                             (begin
                               (unregister-services (list svc))
                               (format #t "Stopped and unregistered ~a\n" svc-name))
                             (format #t "Stopped: ~a\n" svc-name)))))))))
       (shepherd-action
        (name 'list)
        (documentation "List spawned instances")
        (procedure
         #~(lambda (running . args)
             #$helpers
             (for-each-service (lambda (svc)
                                 (when (is-service-sym? '#$spawner-name (car (service-provision svc)))
                                   (format #t "~a => ~a\n"
                                           (car (service-provision svc))
                                           (if (service-running-safe? (car (service-provision svc)))
                                               "running" "stopped")))))))))))))


(define home-spawner-service-type
  (service-type
   (name 'home-spawner)
   (extensions
    (list (service-extension
           home-shepherd-service-type
           (lambda (configs)
             (map spawner-config->shepherd-service
                  configs)))))
   (compose concatenate)
   (extend append)
   (default-value '())
   (description "Generic spawner service. Extend with home-spawner-configuration records.")))


(define home-autossh-tunnel-service-type
  (service-type
   (name 'home-autossh-tunnel)
   (extensions
    (list (service-extension
           home-spawner-service-type
           (lambda (_)
             (list
              (home-spawner-configuration
               (name 'autossh-tunnel)
               (constructor-gexp #~(lambda* (inst-name
                                             service-name-fn
                                             #:key
                                             (rport 2222)
                                             (lport 22)
                                             #:allow-other-keys)
                                     (make-forkexec-constructor (list #$(file-append autossh "/bin/autossh")
                                                                      "-v"
                                                                      "-M"
                                                                      "0"
                                                                      "-N"
                                                                      "-R"
                                                                      (format #f "~d:localhost:~d"
                                                                              rport
                                                                              lport)
                                                                 inst-name)
                                                                #:log-file (#$log-file-gexp (service-name-fn)))))
               (capable? #~(const #t))))))))
   (default-value #f)
   (description "Autossh tunnel spawner for guix home.")))


(define home-ssh-tunnel-service-type
  (service-type
   (name 'home-ssh-tunnel)
   (extensions
    (list (service-extension
           home-spawner-service-type
           (lambda (_)
             (list
              (home-spawner-configuration
               (name 'ssh-tunnel)
               (constructor-gexp #~(lambda* (inst-name
                                             service-name-fn
                                             #:key
                                             (rport 2222)
                                             (lport 22)
                                             (port 22)
                                             #:allow-other-keys)
                                     (let ((port-args
                                            (if (= port 22)
                                                '()
                                                (list "-p" (number->string port))))
                                           (cmd
                                            #$(file-append openssh "/bin/ssh")))
                                       (make-forkexec-constructor (append (list cmd "-v")
                                                                          port-args
                                                                          (list "-N"
                                                                                "-R"
                                                                                (format #f "~d:localhost:~d" rport lport)
                                                                           inst-name))
                                                                  #:log-file (#$log-file-gexp (service-name-fn))))))
               (capable?
                #~(const #t))))))))
   (default-value #f)
   (description "SSH tunnel spawner for guix home.")))


(define home-ssh-gpg-tunnel-service-type
  (service-type
   (name 'home-ssh-gpg-tunnel)
   (extensions
    (list (service-extension
           home-spawner-service-type
           (lambda (_)
             (list
              (home-spawner-configuration
               (name 'ssh-gpg-tunnel)
               (constructor-gexp #~(lambda* (inst-name
                                             service-name-fn
                                             #:key
                                             (rsock "/run/user/1000/gnupg/S.gpg-agent")
                                             (lsock "/run/user/1000/gnupg/S.gpg-agent")
                                             (port 22)
                                             #:allow-other-keys)
                                     (let ((port-args
                                            (if (= port 22)
                                                '()
                                                (list "-p" (number->string port))))
                                           (cmd
                                            #$(file-append openssh "/bin/ssh")))
                                       (make-forkexec-constructor (append (list cmd "-v")
                                                                          port-args
                                                                          (list "-N"
                                                                                "-R"
                                                                                (format #f "~s:localhost:~s" rsock lsock)
                                                                                "-o" "StreamLocalBindUnlink=yes"
                                                                                inst-name))
                                                                  #:log-file (#$log-file-gexp (service-name-fn))))))
               (capable?
                #~(const #t))))))))
   (default-value #f)
   (description "SSH tunnel spawner for guix home.")))


;; (home-environment
;;   (packages (list))
;;   (services
;;    (list
;;     (service home-autossh-tunnel-service-type)
;;     (service home-ssh-tunnel-service-type))))


