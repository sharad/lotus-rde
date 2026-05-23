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

(define-module (lotus-rde home services builder)
  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  ;; #:use-module (guix modules)
  #:use-module (guix records)
  #:use-module (gnu services)
  #:use-module (gnu services dbus)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages crypto)
  #:use-module (rde serializers yaml)
  #:use-module (lotus-rde lib utils)
  #:export (home-secfs-service-type
            home-secfs-volume-configuration
            secfs-volume->shepherd-service

            home-flatpak-service-type
            home-flatpak-app-configuration


            home-services-group-service-type
            services-group->shepherd-service))




(define-record-type* <home-secfs-volume-configuration>
  home-secfs-volume-configuration make-home-secfs-volume-configuration
  home-secfs-volume-configuration?
  (volname  home-secfs-volume-configuration-volname)
  (mode     home-secfs-volume-configuration-mode
    (default "ro")))


(define secfs-mount
    (program-file
     "secfs-mount"
     #~(begin
         (use-modules
          (srfi srfi-1)
          (ice-9 match)
          (ice-9 popen)
          (ice-9 textual-ports)
          (ice-9 getopt-long)
          (ice-9 format)
          (ice-9 ftw))

         (let ((cryfs #$(file-append cryfs "/bin/cryfs"))
               (gpg #$(file-append gnupg "/bin/gpg"))
               (herd #$(file-append shepherd "/bin/herd"))
               (mv #$(file-append coreutils "/bin/mv"))
               (mkdir #$(file-append coreutils "/bin/mkdir"))
               (tail #$(file-append coreutils "/bin/tail"))
               (timeout #$(file-append coreutils "/bin/timeout"))
               (sleep #$(file-append coreutils "/bin/sleep"))
               (HOME (or (getenv "HOME") ""))
               (SECRETCRYPTFS-PATH (string-append HOME
                                                  "/.repos/git/main/resource/userorg/main/readwrite/private/user/secretcryptfs"))
               (SECRETCRYPTFS-VOLUME (string-append SECRETCRYPTFS-PATH "/enc/volumes"))
               (SECRETCRYPTFS-MPOINT (string-append SECRETCRYPTFS-PATH "/noenc/mountpoints"))
               (SECRETCRYPTFS-BASE "secret")

               (args (cdr (command-line)))
               (component (and (pair? args)
                               (car args)))
               (component-perm
                 (and (> (length args) 1)
                      (cadr args)))
               (dev (if component
                        (string-append SECRETCRYPTFS-VOLUME "/" component "/" SECRETCRYPTFS-BASE)
                        #f))

               (mount-point (if component
                                (string-append SECRETCRYPTFS-MPOINT "/" component)
                                #f))

               (permission (or component-perm "ro"))
               (password (let* ((port
                                 (open-input-pipe
                                  (string-append gpg " --batch --no-tty --pinentry-mode error --decrypt "
                                                 HOME
                                                 "/.open-secrets/secret-0.1.key.gpg")))
                                (txt (get-string-all port)))
                           (close-port port)
                           (trim-newline txt))))


           (define (fatal fmt . args)
            (apply format
                   (current-error-port)
                   (string-append fmt "\n")
                   args)
            (exit 1))

          (define (trim-newline s)
            (if (and (> (string-length s) 0)
                     (char=? (string-ref s (- (string-length s) 1))
                             #\newline))
                (string-drop-right s 1)
                s))

          (unless dev
            (fatal "No component provided"))

          (unless (file-exists? dev)
            (fatal "Encrypted dir does not exist: ~a" dev))

          (unless (file-exists? mount-point)
            (mkdir mount-point))

          (when (string-null? password)
            (fatal "Authentication failed"))

          ;; ------------------------------------------------------------
          ;; Restart keepassxc if needed
          ;; ------------------------------------------------------------
          (when (string=? component "orgp")
            (system* herd "stop" "keepassxc")
            (system* herd "restart" "keepassxc"))

          ;; ------------------------------------------------------------
          ;; Run cryfs
          ;; ------------------------------------------------------------

          (setenv "CRYFS_FRONTEND" "noninteractive")

          (let ((port (open-pipe* OPEN_WRITE
                                  cryfs "-f" "-o" (string-append permission
                                                                 ",subtype=Cryfs")
                                  "--allow-replaced-filesystem"
                                  "--config"
                                  (string-append dev "/cryfs.config")
                                  dev
                                  mount-point)))
            (display password port)
            (newline port)
            (force-output port)
            (close-pipe port))))))

(define (secfs-volume->shepherd-service config)

 (let* ((home    (getenv "HOME"))
        (volname (home-secfs-volume-configuration-volname config))
        (mode    (home-secfs-volume-configuration-mode config))
        (sym     (string->symbol (string-append "secfs-" volname)))
        (base    (string-append home "/.secfs/")) ;; "/.repos/git/main/resource/userorg/main/readwrite/private/user/secretcryptfs/"
        (dev     (string-append base "enc/volumes/" volname "/secret"))
        (mp      (string-append base "noenc/mountpoints/" volname))
        (cmd     (string-append home "/.bin/secfs-mount"))
        (log     (log-file (string-append "secfs-" volname "-" mode))))

   (shepherd-service
    (provision (list sym))
    (requirement '());; secfs-down
    (respawn? #f)
    (respawn-delay 10)
    (respawn-limit 2)
    (stop  #~(make-kill-destructor))
    ;; (start #~(make-forkexec-constructor
    ;;           (list #$cmd
    ;;                 "-d" #$dev
    ;;                 "-m" #$mp
    ;;                 "-p" #$mode)
    ;;           #:log-file #$log))
    (start #~(make-forkexec-constructor
              (list #$secfs-mount
                    "-d" #$dev
                    "-m" #$mp
                    "-p" #$mode)
              #:log-file #$log)))))

;; (define home-secfs-service-type
;;   (service-type
;;     (name 'home-secfs)
;;     (extensions
;;      (list (service-extension
;;             home-shepherd-service-type
;;             (lambda (configs)
;;               (map secfs-volume->shepherd-service configs)))))
;;     (compose concatenate)
;;     (extend append)
;;     (default-value '())
;;     (description "Manages secfs encrypted volume mount services.")))


(define home-secfs-service-type
  (service-type
   (name 'home-secfs)

   (extensions
    (list

     ;; install binary into profile
     (service-extension
      home-profile-service-type
      (const (list secfs-mount)))

     ;; shepherd services
     (service-extension
      home-shepherd-service-type
      (lambda (configs)
        (map secfs-volume->shepherd-service
             configs)))))

   (compose concatenate)
   (extend append)
   (default-value '())
   (description
    "Manages secfs encrypted volume mount services.")))



;; (simple-service 'my-secfs-volumes
;;                 home-secfs-service-type
;;                 (list
;;                  (home-secfs-volume-configuration
;;                   (volname "orgp"))
;;                  (home-secfs-volume-configuration
;;                   (volname "secure"))
;;                  (home-secfs-volume-configuration
;;                   (volname "volatile")
;;                   (mode "rw"))))


(define-record-type* <home-flatpak-app-configuration>
  home-flatpak-app-configuration make-home-flatpak-app-configuration
  home-flatpak-app-configuration?
  (name           home-flatpak-app-configuration-name)
  (app            home-flatpak-app-configuration-app)
  (respawn?       home-flatpak-app-configuration-respawn?
                  (default #f))
  (respawn-delay  home-flatpak-app-configuration-respawn-delay
                  (default 10))
  (respawn-limit  home-flatpak-app-configuration-respawn-limit
                  (default 300))
  (requirement    home-flatpak-app-configuration-requirement
                  (default '())))


(define (flatpak-app->shepherd-service config)
  (let* ((name          (home-flatpak-app-configuration-name config))
         (app           (home-flatpak-app-configuration-app config))
         (respawn?      (home-flatpak-app-configuration-respawn? config))
         (respawn-delay (home-flatpak-app-configuration-respawn-delay config))
         (respawn-limit (home-flatpak-app-configuration-respawn-limit config))
         (requirement   (home-flatpak-app-configuration-requirement config))
         (name-str      (symbol->string name))
         (log           (log-file name-str))
         (dbus-launch   (file-append dbus "/bin/dbus-launch"))
         (flatpak       (file-append flatpak "/bin/flatpak")))

    (shepherd-service
      (provision (list name))
     (requirement requirement)
     (respawn? respawn?)
     (respawn-delay respawn-delay)
     (respawn-limit respawn-limit)
     (start #~(make-forkexec-constructor
               (list #$dbus-launch #$flatpak "--user" "run" #$app)
               #:create-session? #t
               #:log-file #$log))

     (stop #~(let ((make-cmd-destructor
                    (lambda command
                      (let ((system-destructor
                             (apply make-system-destructor
                                    command))
                            (kill-destructor
                             (make-kill-destructor)))
                        (lambda (running . args)
                          (apply kill-destructor
                                 running
                                 args)
                          (apply system-destructor
                                 running
                                 args))))))

               (make-cmd-destructor
                (string-append #$flatpak
                               " kill "
                               #$app
                               " >> "
                               #$log
                               " 2>&1")))))))

(define home-flatpak-service-type
  (service-type
    (name 'home-flatpak)
    (extensions
     (list (service-extension
            home-shepherd-service-type
            (lambda (configs)
              (map flatpak-app->shepherd-service configs)))))
    (compose concatenate)
    (extend append)
    (default-value '())
    (description
     "Manages flatpak applications as shepherd services.")))



;; (simple-service 'my-flatpak-apps
;;                 home-flatpak-service-type
;;                 (list
;;                  (home-flatpak-app-configuration
;;                   (name 'zoom)
;;                   (app  "us.zoom.Zoom"))

;;                  (home-flatpak-app-configuration
;;                   (name 'msteam)
;;                   (app  "com.github.IsmaelMartinez.teams_for_linux"))

;;                  (home-flatpak-app-configuration
;;                   (name 'logseq)
;;                   (app  "com.logseq.Logseq.Locale"))

;;                  (home-flatpak-app-configuration
;;                   (name 'obsidian)
;;                   (app  "md.obsidian.Obsidian"))))


(define-record-type* <home-services-group-configuration>
  home-services-group-configuration make-home-services-group-configuration
  home-services-group-configuration?
  (name        home-services-group-configuration-name)
  (dependent   home-services-group-configuration-dependent
               (default '()))
  (requirement home-services-group-configuration-requirement
               (default '()))
  (conflict    home-services-group-configuration-conflict
               (default '())))



(define (services-group->shepherd-service config)
  (let* ((name        (home-services-group-configuration-name config))
         (dependent   (home-services-group-configuration-dependent config))
         (requirement (home-services-group-configuration-requirement config))
         (conflict    (home-services-group-configuration-conflict config))
         (name-str    (symbol->string name))
         (up          (string->symbol (string-append name-str "-up")))
         (down        (string->symbol (string-append name-str "-down"))))

    (shepherd-service
     (provision (list name))
     (requirement '())
     (free-form
      #~(let* ((once-started #f)
               (name        '#$name)
               (dependent   '#$dependent)
               (requirement '#$requirement)
               (conflict    '#$conflict)
               (up          '#$up)
               (down        '#$down))

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
                   #:stop (lambda args #t)))

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
                                   (if once-started
                                       "true"
                                       "false"))))))))))))



(define home-services-group-service-type
  (service-type
   (name 'home-services-group)
   (extensions
    (list (service-extension
           home-shepherd-service-type
           (lambda (configs)
             (map services-group->shepherd-service configs)))))
   (compose concatenate)
   (extend append)
   (default-value '())
   (description
    "Manages groups of dependent shepherd services with up/down/xenable/xdisable actions.")))



;; (simple-service 'my-service-groups
;;                 home-services-group-service-type
;;                 (list
;;                  (home-services-group-configuration
;;                   (name 'secfs)
;;                   (dependent '(awaken-session-down))
;;                   (requirement '(secfs-orgp secfs-secure)))))

;;                  (home-services-group-configuration
;;                   (name 'xawaken-session)
;;                   (dependent '(xdelayed-login-session-down))
;;                   (requirement '(dbus pipewire)))

;;                  (home-services-group-configuration
;;                   (name 'xdelayed-login-session)
;;                   (requirement '(xawaken-session
;;                                  delayed-login-session)))))

