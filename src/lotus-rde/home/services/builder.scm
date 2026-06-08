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
  #:use-module (guix modules)
  #:use-module (guix profiles)
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
            home-flatpak-app-configuration?


            home-services-group-service-type
            home-services-group-configuration))




(define-record-type* <home-secfs-volume-configuration>
  home-secfs-volume-configuration make-home-secfs-volume-configuration
  home-secfs-volume-configuration?
  (volname  home-secfs-volume-configuration-volname)
  (mode     home-secfs-volume-configuration-mode
    (default "ro")))


(define secfs-mount-guile
  (program-file
   "secfs-mount"
   #~(begin
       (use-modules (ice-9 getopt-long)
                    (ice-9 popen)
                    (ice-9 rdelim)
                    (ice-9 format)
                    (srfi srfi-1))

       ;; ---------- defaults ----------
       (define fix-mount-issue #f)
       (define keepasscx-dep-mpbase "orgp")
       (define keepasscx-dep-mpbase-wait-sec 8)
       (define default-perm "ro")

       (define home (getenv "HOME"))

       (define secretcryptfs-path
         (string-append home "/.repos/git/main/resource/userorg/main/readwrite/private/user/secretcryptfs"))
       (define secretcryptfs-volume
         (string-append secretcryptfs-path "/enc/volumes"))
       (define secretcryptfs-mpoint
         (string-append secretcryptfs-path "/noenc/mountpoints"))
       (define secretcryptfs-base "secret")

       ;; ---------- helpers ----------
       (define (fatal . args)
         (apply format (current-error-port)
                (string-append "ERROR: " (string-join (map (lambda (x) "~a") args) " ") "\n")
                args)
         (exit 1))

       (define (info . args)
         (apply format #t
                (string-append (string-join (map (lambda (x) "~a") args) " ") "\n")
                args))

       (define (notify . args)
         (apply format #t
                (string-append "NOTIFY: " (string-join (map (lambda (x) "~a") args) " ") "\n")
                args))

       (define (basename* path)
         (car (last-pair (string-split path #\/))))

       (define (which* cmd)
         (let* ((port (open-input-pipe (string-append "which " cmd " 2>/dev/null")))
                (line (read-line port)))
           (close-pipe port)
           (and (not (eof-object? line))
                (not (string-null? line))
                line)))

       (define (run-command . args)
         (apply system* args))

       ;; ---------- show-help ----------
       (define (show-help pgm)
         (format #t "mount cryfs filesystem\n")
         (format #t "~a: [options] [component [permission]]\n" pgm)
         (format #t "  -h|-?                     show this help\n")
         (format #t "  -f                        fix mounting issue\n")
         (format #t "  -v                        verbose\n")
         (format #t "  -d device_encrypted_dir   Encrypted directory path\n")
         (format #t "  -m mountdir               Mountpoint directory path\n")
         (format #t "  -p permission             Permission ro or rw\n")
         (format #t "  -c configfile             configfile (default device_encrypted_dir/cryfs.config)\n")
         (exit 0))

       ;; ---------- main ----------
       (define (main args)
         (define pgm (basename* (car args)))

         ;; parse options
         (define option-spec
           '((help    (single-char #\h) (value #f))
             (fix     (single-char #\f) (value #f))
             (verbose (single-char #\v) (value #f))
             (dev     (single-char #\d) (value #t))
             (mp      (single-char #\m) (value #t))
             (perm    (single-char #\p) (value #t))
             (cfg     (single-char #\c) (value #t))))

         (define opts (getopt-long args option-spec))

         (when (option-ref opts 'help #f)
           (show-help pgm))

         (set! fix-mount-issue (option-ref opts 'fix #f))

         ;; fix-mount-issue mode
         (when fix-mount-issue
           (let* ((port  (open-input-pipe "date +%Y%m%d-%H%M%S"))
                  (ts    (read-line port))
                  (src   (string-append home "/.local/share/cryfs"))
                  (dst   (string-append home "/.local/share/cryfs-bkp-" ts)))
             (close-pipe port)
             (format #t "moving ~a to ~a\n" src dst)
             (rename-file src dst)
             (exit 0)))

         (define dev-opt  (option-ref opts 'dev  #f))
         (define mp-opt   (option-ref opts 'mp   #f))
         (define perm-opt (option-ref opts 'perm #f))
         (define cfg-opt  (option-ref opts 'cfg  #f))

         (define rest (option-ref opts '() '()))

         (define component      (and (pair? rest) (car rest)))
         (define component-perm (and (pair? rest) (pair? (cdr rest)) (car rest)))

         ;; resolve --dev
         (define __dev
           (or dev-opt
               (and component
                    (string-append secretcryptfs-volume "/" component "/" secretcryptfs-base))
               (fatal "device not provided with -d option, exiting")))

         ;; resolve --mp
         (define __mp
           (or mp-opt
               (and component
                    (string-append secretcryptfs-mpoint "/" component))
               (fatal "mountpoint not provided with -m option, exiting")))

         ;; resolve --perm
         (define __perm
           (or perm-opt
               component-perm
               default-perm))

         ;; validate paths
         (unless (file-exists? __dev)
           (fatal "device dir" __dev "not exists"))

         (unless (file-exists? __mp)
           (info "mountpoint dir" __mp "not exists, creating it")
           (system* "mkdir" "-p" __mp))

         (unless (file-is-directory? __mp)
           (fatal "mountpoint dir" __mp "not exists"))

         (unless (member __perm '("ro" "rw"))
           (fatal "permission" __perm "is not one of ro or rw"))

         ;; config
         (define __cfg
           (or cfg-opt
               (string-append __dev "/cryfs.config")))

         ;; display-dev: last 5 path components
         (define __display-dev
           (let ((parts (string-split __dev #\/)))
             (string-join (take-right parts (min 5 (length parts))) "/")))

         ;; check cryfs is available
         (unless (which* "cryfs")
           (fatal "cryfs command not found"))

         ;; echo the command (debug)
         (format #t "cryfs -f -o ~a,subtype=Cryfs,fsname=Cryfs@~a --allow-replaced-filesystem --config ~a/cryfs.config\n"
                 __perm __display-dev __dev)
         (format #t "cryfs -f -o ~a,subtype=Cryfs,fsname=Cryfs@~a --allow-replaced-filesystem --config ~a/cryfs.config ~a ~a\n"
                 __perm __display-dev __dev __dev __mp)

         ;; decrypt gpg password
         (define pass-port
           (open-input-pipe
            (string-append "gpg --batch --no-tty --pinentry-mode error --decrypt "
                           home "/.open-secrets/secret-0.1.key.gpg 2>/dev/null")))
         (define pass (read-line pass-port))
         (close-pipe pass-port)

         (if (and (not (eof-object? pass)) (not (string-null? pass)))
             (begin
               (define mpbase (basename* __mp))

               ;; keepassxc dependency handling
               (if (string=? keepasscx-dep-mpbase mpbase)
                   (let ((herd-logfile
                          (string-append home "/.logs/shepherd/secfs-"
                                         keepasscx-dep-mpbase "-" __perm ".log")))
                     (when (file-exists? herd-logfile)
                       (format #t "Checking in ~a log file\n" herd-logfile)
                       ;; run in background: tail log, wait for "Filesystem started", then restart keepassxc
                       (let ((pid (primitive-fork)))
                         (when (zero? pid)
                           (system
                            (format #f
                             "tail -f --lines=0 ~a | timeout ~a grep -m 1 'Filesystem started' && sleep 1 && timeout 2 herd stop keepassxc && sleep 1 && timeout 10 herd restart keepassxc"
                             herd-logfile keepasscx-dep-mpbase-wait-sec))
                           (primitive-exit 0)))))
                   (notify "Not restarting keepassxc as MPBASE=" mpbase))

               (setenv "CRYFS_FRONTEND" "noninteractive")

               (format #t "cryfs -f -o ~a,subtype=Cryfs,fsname=Cryfs@~a --allow-replaced-filesystem --config ~a/cryfs.config ~a ~a\n"
                       __perm __display-dev __dev __dev __mp)

               ;; run cryfs, piping the password via stdin
               (let* ((cmd (format #f
                             "echo ~s | cryfs -f -o ~a,subtype=Cryfs,fsname=Cryfs@~a --allow-replaced-filesystem --config ~a/cryfs.config ~a ~a"
                             pass __perm __display-dev __dev __dev __mp))
                      (ret (system cmd)))
                 (exit (if (zero? ret) 0 1))))

             (begin
               (format (current-error-port) "Authentication failed, exiting\n")
               (exit 1))))

       (main (command-line)))))

(define secfs-mount (local-file "scripts/git-annex-daemon"))

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
     (auto-start? #f)
     (stop  #~(make-kill-destructor))
     ;; (start #~(make-forkexec-constructor
     ;;           (list #$cmd
     ;;                 "-d" #$dev
     ;;                 "-m" #$mp
     ;;                 "-p" #$mode)
     ;;           #:log-file #$log))

     ;; (start #~(make-forkexec-constructor
     ;;           (list ;; #$secfs-mount
     ;;            (string-append (getenv "HOME")
     ;;                           "/.bin/secfs-mount")
     ;;            "-d" #$dev
     ;;            "-m" #$mp
     ;;            "-p" #$mode)
     ;;           #:log-file #$log))

     (start #~(lambda ( . args)
                (let* ((log-file   #$log-file-gexp)
                       (mode (if (pair? args)
                                 (car args)
                                 #$mode))
                       (log-file-loc (string-append "secfs-" #$volname "-" mode))
                       (constructor (make-forkexec-constructor (list #$cmd
                                                                     "-d" #$dev
                                                                     "-m" #$mp
                                                                     "-p" mode)
                                                               #:log-file (log-file log-file-loc))))
                  (apply constructor args)))))))


(define secfs-mount-entry
  (file->package "secfs-mount" secfs-mount-guile))

(define home-secfs-service-type
  (service-type
   (name 'home-secfs)

   (extensions
    (list

     ;; true profile installation
     (service-extension
      home-profile-service-type
      (const
       (list secfs-mount-entry)))

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
      (auto-start? #f)
      (start #~(make-forkexec-constructor
                (list #$dbus-launch #$flatpak "--user" "run" #$app)
                #:create-session? #t
                #:log-file #$log))
      (stop #~(let ((make-cmd-destructor #$make-cmd-destructor-gexp))
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
         (group-requirement (home-services-group-configuration-requirement config))
         (group-conflict    (home-services-group-configuration-conflict config))
         (name-str    (symbol->string name))
         (up          (string->symbol (string-append name-str "-up")))
         (down        (string->symbol (string-append name-str "-down"))))

    (shepherd-service
     (provision (list name))
     (requirement '())
     (auto-start? #f)
     (free-form
      #~(begin
          (use-modules (shepherd service))   ; service, register-services etc

          (let* ((once-started #f)
                 (name        '#$name)
                 (dependent   (quote #$dependent))
                 (requirement (quote #$group-requirement))
                 (conflict    (quote #$group-conflict))
                 (up          '#$up)
                 (down        '#$down))

            (format #t "name ~a - requirement ~a ~%" name requirement)
            (display requirement)
            (newline)

            (define (xrun-action-service srv action action-proc retval . args)
              (format #t "xrun-action1: ~a args[~a]~%" srv args)
              (if (lookup-service-action srv action)
                  (begin
                    (format #t "xrun-action2: action [~a] is present for ~a ~%"
                            action srv)
                    (apply perform-service-action srv action args))
                  (begin
                    (format #t "xrun-action3: action [~a] not present for ~a ~%"
                            action srv)
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
                   (service (list up)                  ; ← new API
                            #:requirement requirement
                            #:transient? #f
                            #:one-shot? #f
                            #:respawn? #f
                            #:start (lambda args
                                      (xstop-services conflict)
                                      #t)
                            #:stop (lambda args #t)))

                  (down-service
                   (service (list down)                ; ← new API
                            #:requirement dependent
                            #:transient? #f
                            #:one-shot? #f
                            #:respawn? #f
                            #:start (lambda _ #t)
                            #:stop  (lambda (running . args)
                                      (xstop-services conflict)
                                      #t))))

              (register-services (list up-service down-service))

              (service (list name)                     ; ← new API, returned to shepherd
                       #:requirement '()
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
                       (actions
                        (up       (xdefine-action 'up
                                                  (lambda (retval srv . args)
                                                    (format #t "Starting service ~a args [~a]~%" srv args)
                                                    (if srv
                                                        (begin
                                                          (enable-service srv)
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
                                            (if once-started "true" "false")))))))))))))

(define home-services-group-service-type
  (service-type
   (name 'home-services-group)
   (extensions
    (list (service-extension
           home-shepherd-service-type
           (lambda (configs)
             (map services-group->shepherd-service
                  configs)))))
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

