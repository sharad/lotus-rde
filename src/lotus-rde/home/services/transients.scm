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
  #:export (home-ssh-tunnel-service-type
            home-autossh-tunnel-service-type
            home-spawner-service-type
            <home-spawner-configuration>
            make-home-spawner-configuration
            home-spawner-configuration?
            home-spawner-configuration-name
            home-spawner-configuration-constructor
            home-spawner-configuration-capable?))


;; (define-record-type* <home-spawner-configuration>
;;   home-spawner-configuration make-home-spawner-configuration
;;   home-spawner-configuration?
;;   (name          home-spawner-configuration-name)          ;; symbol e.g. 'autossh-tunnel
;;   (constructor   home-spawner-configuration-constructor)   ;; procedure: (inst-name svc-name-fn . kwargs) → gexp
;;   (capable?      home-spawner-configuration-capable?       ;; gexp: #~(lambda () bool)
;;                  (default #~(lambda () #t))))


(define-record-type* <home-spawner-configuration>
  home-spawner-configuration
  make-home-spawner-configuration
  home-spawner-configuration?
  (name
   home-spawner-configuration-name)
  ;; gexp evaluating to procedure
  (constructor-gexp
   home-spawner-configuration-constructor-gexp)
  (capable?
   home-spawner-configuration-capable?
   (default #~(lambda () #t))))


(define (spawner-config->shepherd-service config)
  (let* ((spawner-name (home-spawner-configuration-name config))
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
             (match args
               ((inst-name . vargs)
                (let* ((svc-sym (string->symbol
                                 (string-append "transient-"
                                                #$(symbol->string spawner-name)
                                                "-" inst-name)))
                       (existing (lookup-service svc-sym)))
                  (if (and existing (service-running? existing))
                      (format #t "Already running: ~a\n" svc-sym)
                      (if (not (#$capable?))
                          (format #t "Error: not capable\n")
                          (let ((svc (make <service>
                                       #:provides (list svc-sym)
                                       #:requires '()
                                       #:transient? #t
                                       #:respawn? #f
                                       #:start (apply (#$constructor)
                                                      inst-name
                                                      (lambda () (symbol->string svc-sym))
                                                      vargs)
                                       #:stop (make-kill-destructor))))
                            (register-services svc)
                            (start-service svc)
                            (format #t "Started: ~a\n" svc-sym))))))
               (_ (format #t "Usage: herd spawn ~a <inst-name>\n"
                          '#$spawner-name))))))

       (shepherd-action
        (name 'destroy)
        (documentation "herd destroy <spawner> <inst-name>")
        (procedure
         #~(lambda (running . args)
             (match args
               ((inst-name . vargs)
                (let* ((svc-sym (string->symbol
                                 (string-append "transient-"
                                                #$(symbol->string spawner-name)
                                                "-" inst-name)))
                       (svc (lookup-service svc-sym)))
                  (if (not svc)
                      (format #t "Not found: ~a\n" svc-sym)
                      (begin
                        (when (service-running? svc)
                          (stop-service svc))
                        (deregister-service svc-sym)
                        (format #t "Destroyed: ~a\n" svc-sym)))))
               (_ (format #t "Usage: herd destroy ~a <inst-name>\n"
                          '#$spawner-name))))))

       (shepherd-action
        (name 'list)
        (documentation "List spawned instances")
        (procedure
         #~(lambda (running . args)
             (let ((prefix (string-append "transient-"
                                          #$(symbol->string spawner-name)
                                          "-")))
               (for-each
                (lambda (svc)
                  (let ((name (symbol->string (car (service-provision svc)))))
                    (when (string-prefix? prefix name)
                      (format #t "~a => ~a\n" name
                              (if (service-running? svc)
                                  "running" "stopped")))))
                (running-services)))))))))))


(define home-spawner-service-type
  (service-type
   (name 'home-spawner)
   (extensions
    (list (service-extension
           home-shepherd-service-type
           (lambda (configs)
             (map spawner-config->shepherd-service configs)))))
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
               ;; (constructor
               ;;  (lambda* (inst-name service-name-fn
               ;;                      #:key (rport 2222) (lport 22)
               ;;                      #:allow-other-keys)
               ;;    #~(make-forkexec-constructor
               ;;       (list #$(file-append autossh "/bin/autossh")
               ;;             "-v" "-M" "0" "-N"
               ;;             "-R" #$(format #f "~d:localhost:~d" rport lport)
               ;;             #$inst-name)
               ;;       #:log-file #$(shepherd-service-log-file
               ;;                     (service-name-fn)))))
               (constructor-gexp
                #~(lambda* (inst-name
                            service-name-fn
                            #:key
                            (rport 2222)
                            (lport 22)
                            #:allow-other-keys)
                    (make-forkexec-constructor
                     (list #$(file-append autossh "/bin/autossh")
                           "-v"
                           "-M"
                           "0"
                           "-N"
                           "-R"
                           (format #f "~d:localhost:~d"
                                   rport
                                   lport)
                      inst-name)

                     #:log-file
                     (shepherd-service-log-file
                      (service-name-fn)))))
               (capable?
                #~(lambda ()
                    (let* ((p    (open-input-pipe "command -v autossh"))
                           (line (read-line p)))
                      (close-port p)
                      (and (string? line)
                           (not (string-null? line))))))))))))
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
               ;; (constructor
               ;;  (lambda* (inst-name service-name-fn
               ;;                      #:key (rport 2222) (lport 22) (port 22)
               ;;                      #:allow-other-keys)
               ;;    (let ((port-args (if (= port 22) '()
               ;;                         (list "-p" (number->string port)))))
               ;;      #~(make-forkexec-constructor
               ;;         (append (list #$(file-append openssh "/bin/ssh") "-v")
               ;;                 '#$port-args
               ;;                 (list "-N"
               ;;                       "-R" #$(format #f "~d:localhost:~d" rport lport)
               ;;                       #$inst-name))
               ;;         #:log-file #$(shepherd-service-log-file
               ;;                       (service-name-fn))))))


               (constructor-gexp
                #~(lambda* (inst-name
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
                      (make-forkexec-constructor
                       (append (list cmd "-v")
                               port-args
                               (list "-N"
                                     "-R"
                                     (format #f "~d:localhost:~d" rport lport)
                                inst-name))
                       #:log-file
                       (shepherd-service-log-file
                        (service-name-fn))))))
               (capable?
                #~(lambda ()
                    (let* ((p    (open-input-pipe "command -v ssh"))
                           (line (read-line p)))
                      (close-port p)
                      (and (string? line)
                           (not (string-null? line))))))))))))
   (default-value #f)
   (description "SSH tunnel spawner for guix home.")))



;; (home-environment
;;   (packages (list))
;;   (services
;;    (list
;;     (service home-autossh-tunnel-service-type)
;;     (service home-ssh-tunnel-service-type))))
