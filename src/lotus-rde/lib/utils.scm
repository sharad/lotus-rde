(define-module (lotus-rde lib utils)
  #:use-module (ice-9 match)
  #:use-module (ice-9 hash-table)
  #:use-module (ice-9 format)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 threads)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (srfi srfi-13)
  #:use-module (system foreign)
  #:use-module (guix gexp)
  #:use-module (guix modules)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  ;; #:use-module (gnu packages)
  ;; #:use-module (gnu packages base)
  #:use-module (guix build utils)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system uuid)
  #:use-module (gnu packages linux)
  #:export (log-file
            make-cmd-destructor
            program-file->package
            lotus-assert
            ensure-rw-mount
            ensure-umount))


(define (lotus-assert condition . msg)
  (throw-message
   condition
   (if (null? msg)
       (list "Assertion failed")
       msg)))



;; (define (shepherd-service-log-file name)
;;   "Return log file path for shepherd service NAME.
;; Usage: #:log-file #$(shepherd-service-log-file name)"
;;   (string-append (getenv "HOME") "/.logs/shepherd/" name ".log"))

;; (define shepherd-service-log-file-gexp
;;   ;; Usage: #:log-file (#$shepherd-service-log-file-gexp #$(service-name-fn))
;;   #~(lambda (name)
;;       (string-append (getenv "HOME") "/.logs/shepherd/" name ".log")))



;; (define (shepherd-service-log-file name)
;;   "Return log file path for shepherd service NAME.
;; Usage: #:log-file #$(shepherd-service-log-file name)"
;;   (string-append (getenv "HOME") "/.logs/shepherd/" name ".log"))

;; (define shepherd-service-log-file-gexp
;;   ;; Usage: #:log-file (#$shepherd-service-log-file-gexp #$(service-name-fn))
;;   #~(lambda (name)
;;       (string-append (getenv "HOME") "/.logs/shepherd/" name ".log")))


(define (log-file name)
  #~(string-append
     (or (getenv "XDG_STATE_HOME")
         (string-append (getenv "HOME")
                        "/.local/state"))
     "/log/"
     #$name
     ".log"))

(define (make-cmd-destructor . command)
  (let ((system-destructor (apply make-system-destructor command))
        (kill-destructor   (make-kill-destructor)))
    (lambda (running . args)
      (apply kill-destructor running args)
      (apply system-destructor running args))))


(define (program-file->package name prog)
  (package
    (name name)
    (version "0")
    (source #f)

    (build-system trivial-build-system)

    (arguments
     (list
      #:builder
      #~(let ((out
               (assoc-ref %outputs "out")))

          ;; mkdir -p equivalent
          (mkdir
           (string-append out "/bin"))

          ;; install wrapper
          (symlink
           #$prog
           (string-append
            out
            "/bin/"
            #$name)))))

    (synopsis name)
    (description name)
    (home-page "")

    ;; choose real license later
    (license #f)))

;; (define (program-file->package name prog)
;;   (package
;;     (name name)
;;     (version "0")
;;     (source #f)
;;     (build-system trivial-build-system)

;;     (arguments
;;      (list
;;       #:builder
;;       #~(begin

;;           (use-modules
;;            (guix build utils))

;;           (let ((out
;;                  (assoc-ref %outputs "out")))

;;             (mkdir-p
;;              (string-append out "/bin"))

;;             (symlink
;;              #$prog
;;              (string-append
;;               out
;;               "/bin/"
;;               #$name))))))

;;     (synopsis name)
;;     (description name)
;;     (home-page "")
;;     (license #f)))


(define* (define-spawner-service spawner-service
                                 #:key constructor-fn is-capable-fn?)

  (shepherd-service
   (provision (list spawner-service))
   (documentation (format #f "Spawner for ~a services" spawner-service))
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
              (let* ((svc-sym  (string->symbol
                                (string-append "transient-"
                                               #$(symbol->string spawner-service)
                                               "-" inst-name)))
                     (existing (lookup-service svc-sym)))
                (if (and existing (service-running? existing))
                    (format #t "Already running: ~a\n" svc-sym)
                    (if (not (#$is-capable-fn?))
                        (format #t "Error: not capable\n")
                        (let* ((log-file (string-append
                                          (getenv "HOME")
                                          "/.local/var/log/shepherd/"
                                          (symbol->string svc-sym) ".log"))
                               (svc (make <service>
                                      #:provides (list svc-sym)
                                      #:requires '()
                                      #:transient? #t
                                      #:respawn? #f
                                      #:start (#$constructor-fn
                                               inst-name
                                               (lambda () (symbol->string svc-sym)))
                                      #:stop (make-kill-destructor))))
                          (register-services svc)
                          (start-service svc)
                          (format #t "Started: ~a\n" svc-sym))))))
             (_ (format #t "Usage: herd spawn ~a <inst-name>\n"
                        '#$spawner-service))))))

     (shepherd-action
      (name 'destroy)
      (documentation "herd destroy <spawner> <inst-name>")
      (procedure
       #~(lambda (running . args)
           (match args
             ((inst-name . vargs)
              (let* ((svc-sym  (string->symbol
                                (string-append "transient-"
                                               #$(symbol->string spawner-service)
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
                        '#$spawner-service))))))

     (shepherd-action
      (name 'list)
      (documentation "List all spawned instances")
      (procedure
       #~(lambda (running . args)
           (let ((prefix (string-append "transient-"
                                        #$(symbol->string spawner-service)
                                        "-")))
             (for-each
              (lambda (svc)
                (let ((name (symbol->string (car (service-provision svc)))))
                  (when (string-prefix? prefix name)
                    (format #t "~a => ~a\n" name
                            (if (service-running? svc)
                                "running" "stopped")))))
              (running-services))))))))))




(define (autossh-tunnel-spawner-service)
  (define* (constructor-fn inst-name service-name-fn
                            #:key (rport 2222) (lport 22)
                            #:allow-other-keys)
    #~(make-forkexec-constructor
       (list #$(file-append autossh "/bin/autossh") "-v" "-M" "0" "-N"
             "-R" #$(format #f "~d:localhost:~d" rport lport)
             #$inst-name)
       #:log-file #$(shepherd-service-log-file (service-name-fn))))

  (define is-capable-fn?
    #~(lambda ()
        (let* ((p    (open-input-pipe "command -v autossh"))
               (line (read-line p)))
          (close-port p)
          (and (string? line) (not (string-null? line))))))

  (define-spawner-service 'autossh-tunnel
                          #:constructor-fn constructor-fn
                          #:is-capable-fn? is-capable-fn?))


(define (ssh-tunnel-spawner-service)
  (define* (constructor-fn inst-name service-name-fn
                            #:key (rport 2222) (lport 22) (port 22)
                            #:allow-other-keys)
    (let ((port-args (if (= port 22) '()
                         (list "-p" (number->string port)))))
      #~(make-forkexec-constructor
         (append (list #$(file-append openssh "/bin/ssh") "-v") '#$port-args
                 (list "-N"
                       "-R" #$(format #f "~d:localhost:~d" rport lport)
                       #$inst-name))
         #:log-file #$(shepherd-service-log-file (service-name-fn)))))

  (define is-capable-fn?
    #~(lambda ()
        (let* ((p    (open-input-pipe "command -v ssh"))
               (line (read-line p)))
          (close-port p)
          (and (string? line) (not (string-null? line))))))

  (define-spawner-service 'ssh-tunnel
                          #:constructor-fn constructor-fn
                          #:is-capable-fn? is-capable-fn?))


;; ;; usage
;; (use-modules (gnu home)
;;              (gnu home services)
;;              (gnu home services shepherd)
;;              (shepherd service))

;; ;; ... your define-spawner-service definition ...
;; ;; ... your ssh-tunnel-spawner-service definition ...
;; ;; ... your autossh-tunnel-spawner-service definition ...

;; (home-environment
;;   (packages (list))

;;   (services
;;    (list
;;     (simple-service 'my-shepherd-services
;;                     home-shepherd-service-type
;;                     (list
;;                      (ssh-tunnel-spawner-service)
;;                      (autossh-tunnel-spawner-service))))))


(define (make-secfs-service volname . mode)
  (let* ((home   (getenv "HOME"))
         (sym    (string->symbol (string-append "secfs-" volname)))
         (base   (string-append home "/.repos/git/main/resource/userorg/main/readwrite/private/user/secretcryptfs/"))
         (dev    (string-append base "enc/volumes/"  volname "/secret"))
         (mp     (string-append base "noenc/mountpoints/" volname))
         (cmd    (string-append home "/.bin/secfs-mount"))
         (mode   (if (null? mode) "ro" (car mode)))
         (log    (shepherd-service-log-file (string-append "secfs-" volname "-" mode))))

    (shepherd-service
      (provision (list sym))
      (requirement '(secfs-down))
      (respawn? #f)
      (respawn-delay 10)
      (respawn-limit 2)
      (stop #~(make-kill-destructor))
      (start #~(make-forkexec-constructor
                (list #$cmd
                      "-d" #$dev
                      "-m" #$mp
                      "-p" #$mode)
                #:log-file #$log))
      (actions
       (list
        (shepherd-action
          (name 'remount)
          (documentation "herd remount secfs-orgp rw")
          (procedure
           #~(lambda (running new-mode)
               (system* #$cmd "-d" #$dev "-m" #$mp "-p" new-mode)))))))))


;; (define secfs-orgp     (make-secfs-service "orgp"))
;; (define secfs-secure   (make-secfs-service "secure"))
;; (define secfs-volatile (make-secfs-service "volatile" "rw"))


(define* (make-services-group-dep-service name
                                          #:key
                                          (dependent '())
                                          (requirement '())
                                          (conflict '()))
  (let* ((name-str (symbol->string name))
         (up       (string->symbol (string-append name-str "-up")))
         (down     (string->symbol (string-append name-str "-down"))))

    (shepherd-service
     (provision (list name))
     (requirement '())
     (free-form
      #~(let* ((once-started #f)
               (name      '#$name)
               (dependent '#$dependent)
               (requirement '#$requirement)
               (conflict  '#$conflict)
               (up        '#$up)
               (down      '#$down))

          (define (xrun-action-service srv action action-proc retval . args)
            (format #t "xrun-action1: ~a args[~a]~%" srv args)
            (if (lookup-service-action srv action)
                (begin
                  (format #t "xrun-action2: action [~a] present for ~a~%" action srv)
                  (apply perform-service-action srv action args))
                (begin
                  (format #t "xrun-action3: action [~a] not present for ~a~%" action srv)
                  (apply action-proc retval srv args))))

          (define (xdefine-action action action-proc)
            (lambda (retval . args)
              (for-each (lambda (sym)
                          (let ((srv (lookup-service sym)))
                            (apply xrun-action-service
                                   srv action action-proc retval args)))
                        (append requirement (list up down)))
              (let ((srv (lookup-service name)))
                (apply action-proc retval srv args))))

          (define (xstop-services services)
            (for-each stop-service services))

          (let ((up-service
                 (make <service>
                   #:provides (list up)
                   #:requires requirement
                   #:transient? #f
                   #:one-shot? #f
                   #:respawn? #f
                   #:start (lambda args
                             (xstop-services conflict)
                             #t)
                   #:stop  (lambda args #t)))

                (down-service
                 (make <service>
                   #:provides (list down)
                   #:requires dependent
                   #:transient? #f
                   #:one-shot? #f
                   #:respawn? #f
                   #:start (lambda _ #t)
                   #:stop  (lambda (running . args)
                             (xstop-services conflict)
                             #t))))

            (register-services up-service down-service)

            (make <service>
              #:provides (list name)
              #:requires '()
              #:transient? #f
              #:one-shot? #f
              #:respawn? #f
              #:start (lambda args
                        (set! once-started #t)
                        (apply start-service up-service args)
                        #t)
              #:stop  (lambda (running . args)
                        (apply stop-service down-service args)
                        #t)
              #:actions
              (make-actions
               (up       (xdefine-action 'up
                           (lambda (retval srv . args)
                             (format #t "Starting service ~a args [~a]~%" srv args)
                             (if srv
                                 (begin (enable-service srv)
                                        (apply start-service srv args))
                                 (format #t "No service ~a~%" name)))))
               (down     (xdefine-action 'down
                           (lambda (running srv . args)
                             (format #t "Stopping service ~a~%" srv)
                             (if srv
                                 (apply stop-service srv args)
                                 (format #t "No service ~a~%" name)))))
               (xenable  (xdefine-action 'xenable
                           (lambda (retval srv . args)
                             (format #t "Enabling service ~a~%" srv)
                             (if srv
                                 (enable-service srv)
                                 (format #t "No service ~a~%" name)))))
               (xdisable (xdefine-action 'xdisable
                           (lambda (retval srv . args)
                             (format #t "Disabling service ~a~%" srv)
                             (if srv
                                 (disable-service srv)
                                 (format #t "No service ~a~%" name)))))
               (xstatus  (xdefine-action 'xstatus
                           (lambda (retval srv . args)
                             (format #t "Service status ~a~%" srv)
                             (if srv
                                 (display-service-status srv)
                                 (format #t "No service ~a~%" name)))))
               (once     (lambda (x)
                           (format #t "~a~%"
                                   (if once-started "true" "false"))))))))))))


;; (define secfs
;;   (make-services-group-dep-service 'secfs
;;                                    #:dependent '(awaken-session-down)
;;                                    #:requirement (map (lambda (s)
;;                                                         (car (service-provision s)))
;;                                                       (list secfs-orgp
;;                                                             secfs-secure))))

;; (define xawaken-session
;;   (make-services-group-dep-service 'xawaken-session
;;                                    #:dependent '(xdelayed-login-session-down)
;;                                    #:requirement '(dbus pipewire)))


;; Check if mounted
(define (mounted? mount-point)
  (call-with-input-file "/proc/mounts"
    (lambda (port)
      (let loop ()
        (let ((line (read-line port 'concat)))
          (if (eof-object? line)
              #f
              (let* ((fields (string-split line #\space))
                     (target (list-ref fields 1)))
                (if (string=? target mount-point)
                    #t
                    (loop)))))))))


;; Ensure mount is rw
(define (ensure-rw-mount mount-point)

  (define MS_REMOUNT 32)

  ;; Find device from /etc/fstab
  (define (find-device-for mount-point)
    (call-with-input-file "/etc/fstab"
      (lambda (port)
        (let loop ()
          (let ((line (read-line port 'concat)))
            (cond
             ((eof-object? line)
              #f)

             ;; skip comments/empty
             ((or (string-prefix? "#" line)
                  (string-null? (string-trim line)))
              (loop))

             (else
              (let ((fields
                     (filter
                      (lambda (x)
                        (not (string-null? x)))
                      (string-split line #\space))))

                (if (and (>= (length fields) 2)
                         (string=? (list-ref fields 1)
                                   mount-point))
                    (list-ref fields 0)
                    (loop))))))))))

  ;; Check if mounted read-only
  (define (mount-read-only? mount-point)
    (call-with-input-file "/proc/mounts"
      (lambda (port)
        (let loop ()
          (let ((line (read-line port 'concat)))
            (if (eof-object? line)
                #f
                (let* ((fields (string-split line #\space))
                       (target (list-ref fields 1))
                       (opts   (list-ref fields 3)))
                  (if (string=? target mount-point)
                      (member "ro"
                              (string-split opts #\,))
                      (loop)))))))))

  ;; Find filesystem type using blkid
  (define (filesystem-type device)
    (let* ((pipe (open-pipe* OPEN_READ
                             "blkid"
                             "-o"
                             "value"
                             "-s"
                             "TYPE"
                             device))
           (result (string-trim-right (read-string pipe))))
      (close-pipe pipe)
      result))




  (let ((device (find-device-for mount-point)))
    (if (not device)
        (error "No device found for mount-point"
               mount-point)

        (let ((fs-type (filesystem-type device)))
          (cond

           ;; not mounted
           ((not (mounted? mount-point))
            (format #t "Mounting ~a on ~a\n"
                    device mount-point)
            (mount device mount-point fs-type 0 "rw"))

           ;; mounted ro
           ((mount-read-only? mount-point)
            (format #t "Remounting ~a rw\n"
                    mount-point)
            (mount device
                   mount-point
                   fs-type
                   MS_REMOUNT
                   "rw"))

           ;; already rw
           (else
            (format #t "~a already rw\n"
                   mount-point)))))))


;; Ensure unmounted
(define (ensure-umount mount-point)
  (if (mounted? mount-point)

      (begin
        (format #t
                "Unmounting ~a\n"
                mount-point)

        (umount mount-point))

      (format #t
              "~a already unmounted\n"
              mount-point)))

;; Example:
;; (ensure-rw "/boot/efi")


