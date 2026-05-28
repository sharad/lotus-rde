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

(define-module (lotus-rde home services utils)
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
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages gnupg)
  #:use-module (rde serializers yaml)
  #:use-module (lotus-rde lib utils)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages wm)
  #:use-module (gnu services shepherd)
  #:export (home-bluetooth-autoconnect-service
            home-power-monitor-service
            home-kpkey-service
            home-ssh-add-key-service
            home-git-annex-daemon-service))


;; ------------------------------------------------------------
;; Program
;; ------------------------------------------------------------
(define bluetooth-autoconnect-guile
  (with-imported-modules
        (source-module-closure
         '((dbus)
           (dbus mainloop)
           (oop goops)))

      (program-file
       "bluetooth-autoconnect"
       #~(begin
           (use-modules
            (srfi srfi-1)
            (ice-9 match)
            (ice-9 format)
            (oop goops)
            (dbus)
            (dbus mainloop))

           ;; ------------------------------------------------------------
           ;; Command line arguments
           ;; ------------------------------------------------------------

           ;; bluetooth-autoconnect
           ;; bluetooth-autoconnect --daemon
           ;; bluetooth-autoconnect --verbose
           ;; bluetooth-autoconnect --only-audio
           ;; bluetooth-autoconnect --retry 3

           (define args
             (cdr (command-line)))

           (define daemon?
             (member "--daemon"
                     args))

           (define verbose?
             (member "--verbose"
                     args))

           (define only-audio?
             (member "--only-audio"
                     args))

           (define retry-count

             (let loop ((lst args))

               (match lst

                 (("--retry" value rest ...)
                  (or (string->number value)
                      3))

                 ((_ rest ...)
                  (loop rest))

                 (_ 3))))

           ;; ------------------------------------------------------------
           ;; Helpers
           ;; ------------------------------------------------------------

           (define (vfmt fmt . args)

             (when verbose?

               (apply format #t fmt args)

               (force-output)))

           ;; ------------------------------------------------------------
           ;; DBus
           ;; ------------------------------------------------------------

           (define bus
             (make-system-dbus-connection))

           (define object-manager
             (dbus-proxy
              bus
              "org.bluez"
              "/"
              "org.freedesktop.DBus.ObjectManager"))

           ;; ------------------------------------------------------------
           ;; Device helpers
           ;; ------------------------------------------------------------

           (define (managed-objects)

             (object-manager
              "GetManagedObjects"))

           (define (device? interfaces)

             (assoc-ref
              interfaces
              "org.bluez.Device1"))

           (define (trusted? device)

             (assoc-ref
              device
              "Trusted"))

           (define (connected? device)

             (assoc-ref
              device
              "Connected"))

           (define (audio-device? device)

             (let ((uuids
                    (assoc-ref device "UUIDs")))

               (and uuids

                    (any

                     (lambda (uuid)

                       (or
                        (string-contains uuid
                                         "110B") ;; Audio Sink
                        (string-contains uuid
                                         "110E") ;; A/V Remote
                        (string-contains uuid
                                         "111E"))) ;; Handsfree

                     uuids))))

           ;; ------------------------------------------------------------
           ;; Connect device
           ;; ------------------------------------------------------------

           (define (connect-device path)

             (let loop ((n retry-count))

               (when (> n 0)

                 (catch #t

                   (lambda ()

                     (vfmt
                      "connecting ~a\n"
                      path)

                     ((dbus-proxy
                       bus
                       "org.bluez"
                       path
                       "org.bluez.Device1")

                      "Connect")

                     (format
                      #t
                      "connected ~a\n"
                      path))

                   (lambda (k . a)

                     (vfmt
                      "failed ~a retry ~a\n"
                      path
                      n)

                     (sleep 2)

                     (loop (- n 1)))))))

           ;; ------------------------------------------------------------
           ;; Connect trusted devices
           ;; ------------------------------------------------------------

           (define (connect-devices)

             (for-each

              (match-lambda

                ((path . interfaces)

                 (let ((device
                        (device? interfaces)))

                   (when (and device
                              (trusted? device)
                              (not (connected? device))
                              (or (not only-audio?)
                                  (audio-device? device)))

                     (connect-device path)))))

              (managed-objects)))

           ;; ------------------------------------------------------------
           ;; Adapter power signal
           ;; ------------------------------------------------------------

           (define (properties-changed
                    interface
                    changed
                    invalidated
                    path)

             (when (and
                    (string=? interface
                               "org.bluez.Adapter1")

                    (assoc-ref changed
                               "Powered"))

               (vfmt
                "adapter powered on ~a\n"
                path)

               (connect-devices)))

           ;; ------------------------------------------------------------
           ;; Main
           ;; ------------------------------------------------------------

           ;; initial connect
           (connect-devices)

           ;; daemon mode
           (when daemon?

             (add-match
              bus
              properties-changed
              "type='signal',\
interface='org.freedesktop.DBus.Properties',\
sender='org.bluez'")

             ;; Keep alive
             (let loop ()

               (sleep 3600)

               (loop)))))))

(define bluetooth-autoconnect (local-file "scripts/bluetooth-autoconnect"))

(define bluetooth-autoconnect-entry
  (file->package "bluetooth-autoconnect"
                 bluetooth-autoconnect-guile))

;; ------------------------------------------------------------
;; Single instance service
;; ------------------------------------------------------------
(define-public home-bluetooth-autoconnect-service

  (list

   ;; Put executable into profile
   (simple-service
    'bluetooth-autoconnect-profile
    home-profile-service-type
    (list bluetooth-autoconnect-entry))


   ;; Singleton shepherd service
   (simple-service
    'bluetooth-autoconnect-shepherd
    home-shepherd-service-type

    (list

     (shepherd-service
       (provision '(bluetooth-autoconnect bt-autoconnect))
       (documentation
        "Bluetooth trusted device auto-connect daemon.")
       (requirement '(dbus))
       (auto-start? #f)
       (start
        #~(make-forkexec-constructor
           (list
            ;; #$bluetooth-autoconnect
            (string-append (getenv "HOME")
                           "/.bin/bluetooth-autoconnect")
            "--daemon"
            "--verbose"
            "--only-audio"
            "--retry" "3")
           #:create-session? #f
           #:log-file
           #$(log-file "bluetooth-autoconnect")))
       (stop
        #~(make-kill-destructor))
       (respawn? #t)
       (one-shot? #f))))))



;; ------------------------------------------------------------
;; Program
;; ------------------------------------------------------------
(define power-monitor-guile
  (program-file
   "power-monitor"

   #~(begin

       (use-modules
        (ice-9 match)
        (ice-9 format)
        (ice-9 textual-ports)
        (ice-9 ftw)
        (srfi srfi-1))

       ;; ------------------------------------------------------------
       ;; Store paths
       ;; ------------------------------------------------------------

       (define notify-send
         #$(file-append libnotify "/bin/notify-send"))

       (define zenity
         #$(file-append zenity "/bin/zenity"))

       (define poweroff
         #$(file-append shepherd "/sbin/poweroff"))

       ;; ------------------------------------------------------------
       ;; CLI arguments
       ;; ------------------------------------------------------------

       ;; power-monitor
       ;; power-monitor --interval 5
       ;; power-monitor --low 5
       ;; power-monitor --high 70
       ;; power-monitor --no-notify
       ;; power-monitor --no-poweroff
       ;; power-monitor --verbose

       (define args
         (cdr (command-line)))

       (define (arg-value flag default)

         (let loop ((lst args))

           (match lst

             ((flag* value rest ...)
              (if (string=? flag flag*)
                  value
                  (loop (cons value rest))))

             (_ default))))

       (define interval
         (or
          (and=> (arg-value "--interval" #f)
                 string->number)
          10))

       (define low-threshold
         (or
          (and=> (arg-value "--low" #f)
                 string->number)
          5))

       (define high-threshold
         (or
          (and=> (arg-value "--high" #f)
                 string->number)
          70))

       (define notify?
         (not
          (member "--no-notify"
                  args)))

       (define auto-poweroff?
         (not
          (member "--no-poweroff"
                  args)))

       (define verbose?
         (member "--verbose"
                 args))

       ;; ------------------------------------------------------------
       ;; Battery sysfs
       ;; ------------------------------------------------------------

       (define battery-capacity-file
         "/sys/class/power_supply/BAT0/capacity")

       ;; ------------------------------------------------------------
       ;; Helpers
       ;; ------------------------------------------------------------

       (define (vfmt fmt . args)

         (when verbose?

           (apply format #t fmt args)

           (force-output)))

       (define (notify fmt . args)

         (when notify?

           (apply
            system*
            notify-send
            (list
             (apply format #f fmt args)))))

       (define (read-status)

         (unless (file-exists?
                  battery-capacity-file)

           (error
            "Battery capacity file missing"
            battery-capacity-file))

         (call-with-input-file
             battery-capacity-file

           (lambda (port)

             (let ((txt
                    (string-trim-right
                     (get-string-all port)
                     #\newline)))

               (or (string->number txt)

                   (error
                    "Invalid battery value"
                    txt))))))

       ;; ------------------------------------------------------------
       ;; Low battery actions
       ;; ------------------------------------------------------------

       (define (handle-low-battery level)

         (vfmt
          "low battery ~a%%\n"
          level)

         ;; warnings
         (when (member level '(9 8 7))

           (system*
            zenity
            "--warning"
            "--text"
            (format
             #f
             "Battery is only at ~a%%"
             level)))

         ;; shutdown
         (when (and auto-poweroff?
                    (<= level low-threshold))

           (notify
            "Battery critical: ~a%%"
            level)

           (sleep 2)

           (system* poweroff)))

       ;; ------------------------------------------------------------
       ;; High battery actions
       ;; ------------------------------------------------------------

       (define (handle-high-battery level)

         (vfmt
          "high battery ~a%%\n"
          level)

         (when (= level high-threshold)

           (notify
            "Battery charged to ~a%%"
            level)))

       ;; ------------------------------------------------------------
       ;; Main loop
       ;; ------------------------------------------------------------

       (define (monitor-loop)

         (let loop ((prev-charge
                     (read-status)))

           (let ((curr-charge
                  (read-status)))

             (vfmt
              "Battery ~a%% -> ~a%%\n"
              prev-charge
              curr-charge)

             ;; charging
             (when (> curr-charge
                      prev-charge)

               (handle-high-battery
                curr-charge))

             ;; discharging
             (when (< curr-charge
                      prev-charge)

               (handle-low-battery
                curr-charge))

             (sleep interval)

             (loop curr-charge))))

       ;; ------------------------------------------------------------
       ;; Entry
       ;; ------------------------------------------------------------

       (monitor-loop))))

(define power-monitor (local-file "scripts/power-monitor"))

(define power-monitor-entry
  (file->package "power-monitor"
                 power-monitor-guile))

;; ------------------------------------------------------------
;; Single instance service
;; ------------------------------------------------------------
(define-public home-power-monitor-service

  (list
   ;; Put executable into profile
   (simple-service
    'power-monitor-profile
    home-profile-service-type
    (list power-monitor-entry))

   ;; Singleton shepherd service
   (simple-service
    'power-monitor-shepherd
    home-shepherd-service-type

    (list
     (shepherd-service
       (provision '(power-monitor pm))
       (documentation
        "Battery and power monitoring service.")
       (requirement '())
       (auto-start? #f)
       (start
        #~(make-forkexec-constructor
           (list
            ;; #$power-monitor
            (string-append (getenv "HOME")
                           "/.bin/power-mon")
            "--interval" "10"
            "--low" "5"
            "--high" "70"
            "--verbose")
           #:create-session? #f
           #:log-file
           #$(log-file "power-monitor")))
       (stop
        #~(make-kill-destructor))
       (respawn? #t)
       (one-shot? #f))))))


;; ------------------------------------------------------------
;; Program
;; ------------------------------------------------------------
(define kpkey-guile
  (program-file
   "kpkey"

   #~(begin

       (use-modules
        (ice-9 match)
        (ice-9 format)
        (ice-9 ftw)
        (ice-9 popen)
        (ice-9 textual-ports)
        (srfi srfi-1))

       ;; ------------------------------------------------------------
       ;; Store paths
       ;; ------------------------------------------------------------

       (define gpg
         #$(file-append gnupg "/bin/gpg"))

       (define notify-send
         #$(file-append libnotify "/bin/notify-send"))

       (define zenity
         #$(file-append zenity "/bin/zenity"))

       (define shred
         #$(file-append coreutils "/bin/shred"))

       (define herd
         #$(file-append shepherd "/bin/herd"))

       ;; ------------------------------------------------------------
       ;; Constants
       ;; ------------------------------------------------------------

       (define home
         (or (getenv "HOME") ""))

       (define key-dir
         (string-append home "/.pi/.kp/mem"))

       (define key-source-dir
         (string-append home "/.pi/.kp/.keys"))

       (define secret-file
         (string-append
          home
          "/.open-secrets/secret-0.1.key.gpg"))

       (define secure-mount
         (string-append
          home
          "/.repos/git/main/resource/userorg/main/readwrite/private/user/secretcryptfs/noenc/mountpoints/secure"))

       ;; ------------------------------------------------------------
       ;; Helpers
       ;; ------------------------------------------------------------

       ;; Better than parsing mount output.
       ;; Compare device IDs.
       (define (mounted? path)

         (let ((st
                (false-if-exception
                 (stat path)))

               (root
                (stat "/")))

           (and st
                (not
                 (= (stat:dev st)
                    (stat:dev root))))))

       (define (notify fmt . args)

         (apply
          system*
          notify-send
          (list
           (apply format #f fmt args))))

       (define (key-files)

         (filter
          (lambda (f)
            (string-suffix? ".keyx" f))
          (scandir ".")))

       (define (encrypted-key-files)

         (filter
          (lambda (f)
            (string-suffix? ".keyx.gpg" f))
          (scandir ".")))

       ;; ------------------------------------------------------------
       ;; Decrypt file
       ;; ------------------------------------------------------------

       (define (decrypt-file file)

         ;; Obtain passphrase
         (let* ((port
                 (open-input-pipe
                  (string-append
                   gpg
                   " --batch --quiet --decrypt "
                   secret-file)))

                (passphrase
                 (string-trim-right
                  (get-string-all port)
                  #\newline)))

           (close-pipe port)

           ;; decrypt target
           (system*
            gpg
            "--batch"
            "--yes"
            "--pinentry-mode"
            "loopback"
            "--passphrase"
            passphrase
            "--output"
            (string-drop-right file 4)
            "--decrypt"
            file)))

       ;; ------------------------------------------------------------
       ;; Checkout
       ;; ------------------------------------------------------------

       (define (checkout)

         (unless (mounted? secure-mount)

           (format
            (current-error-port)
            "secure mount unavailable\n")

           (exit 1))

         (mkdir-p key-dir)

         (chdir key-dir)

         ;; ------------------------------------------------------------
         ;; Symlink encrypted files
         ;; ------------------------------------------------------------

         (for-each

          (lambda (f)

            (let ((target
                   (string-append
                    key-dir
                    "/"
                    (basename f))))

              (unless (file-exists? target)

                (symlink f target))))

          (find-files
           key-source-dir
           "\\.keyx\\.gpg$"))

         ;; ------------------------------------------------------------
         ;; Decrypt files
         ;; ------------------------------------------------------------

         (for-each

          (lambda (f)

            (unless
                (file-exists?
                 (string-drop-right f 4))

              (decrypt-file f)))

          (encrypted-key-files))

         ;; ------------------------------------------------------------
         ;; Result
         ;; ------------------------------------------------------------

         (if (null? (key-files))

             (notify
              "Failed to checkout keys")

             (notify
              "Successfully checked out keys"))

         ;; restart keepassxc
         (primitive-fork)

         (system*
          herd
          "restart"
          "keepassxc"))

       ;; ------------------------------------------------------------
       ;; Checkin
       ;; ------------------------------------------------------------

       (define (checkin)

         (mkdir-p key-dir)

         (chdir key-dir)

         (let ((files
                (key-files)))

           (if (null? files)

               (notify
                "Already checked in")

               (begin

                 (for-each

                  (lambda (f)

                    ;; secure delete
                    (system*
                     shred
                     "-u"
                     f))

                  files)

                 (notify
                  "Successfully checked in")))))

       ;; ------------------------------------------------------------
       ;; Status
       ;; ------------------------------------------------------------

       (define (status)

         (mkdir-p key-dir)

         (chdir key-dir)

         (for-each
          (lambda (f)
            (format #t "~a\n" f))
          (key-files)))

       ;; ------------------------------------------------------------
       ;; Main
       ;; ------------------------------------------------------------

       (match (cdr (command-line))

         (("co")
          (checkout))

         (("ci")
          (checkin))

         ((or ("st")
              ("status"))
          (status))

         (_

          (format
           (current-error-port)
           "Usage: kpkey {co|ci|st}\n")

          (exit 1))))))

(define kpkey (local-file "scripts/kpkey"))

(define kpkey-entry
  (file->package "kpkey" kpkey-guile))

;; ------------------------------------------------------------
;; Single instance service
;; ------------------------------------------------------------
(define-public home-kpkey-service

  (list
   ;; Put executable into profile
   (simple-service
    'kpkey-profile
    home-profile-service-type
    (list kpkey-entry))

   ;; Singleton shepherd service
   (simple-service
    'kpkey-shepherd
    home-shepherd-service-type

    (list
     (let ((cmd (string-append (getenv "HOME") "/.bin/kpkeys")))
      (shepherd-service
        (provision '(kpkey))
        (documentation
         "KeePassXC key checkout service.")
        (requirement '())
        (auto-start? #f)
        ;; (start
        ;;  #~(make-forkexec-constructor
        ;;     ;; (list #$kpkey "co")
        ;;     (list (string-append (getenv "HOME")
        ;;                          "/.bin/kpkeys") "co")
        ;;     #:create-session? #f
        ;;     #:log-file
        ;;     #$(log-file "kpkey")))
        ;; (stop
        ;;  #~(make-kill-destructor))
        (start #~(lambda ( . args)
                   (let* ((cli (string-join (append (list #$cmd "-s") args '("co"))
                                            " "))
                          (constructor (make-system-constructor cli " >> " #$(log-file "kpkeys") " 2>&1")))
                     (format #t "Running ~a~%" cli)
                     (apply constructor args))))
        (stop  #~(lambda (running . args)
                   (let* ((cli (string-join (append (list #$cmd "-s") args '("ci")) " ")
                            (destructor (make-system-destructor cli " >> " #$(log-file "kpkeys") " 2>&1"))))
                     (format #t "Running ~a~%" cli
                       (apply destructor running args)))))
        (one-shot? #t)
        (respawn? #f)))))))


;; ------------------------------------------------------------
;; Program
;; ------------------------------------------------------------
(define ssh-add-key-guile
  (program-file
   "ssh-add-key"
   #~(begin

       (use-modules
        (ice-9 match)
        (ice-9 format)
        (ice-9 popen)
        (ice-9 textual-ports)
        (ice-9 ftw)
        (srfi srfi-1))

       ;; ------------------------------------------------------------
       ;; Store paths
       ;; ------------------------------------------------------------

       (define ssh-add
         #$(file-append openssh "/bin/ssh-add"))

       (define secret-tool
         #$(file-append libsecret "/bin/secret-tool"))

       (define herd
         #$(file-append shepherd "/bin/herd"))

       (define zenity
         #$(file-append zenity "/bin/zenity"))

       ;; ------------------------------------------------------------
       ;; Command line arguments
       ;; ------------------------------------------------------------

       ;; ssh-add-key MIN-KEYS MAX-TRIES
       ;;
       ;; Examples:
       ;;
       ;; ssh-add-key
       ;; ssh-add-key 4 5
       ;; ssh-add-key 6 10

       (define args
         (cdr (command-line)))

       (define min-keys-count
         (if (>= (length args) 1)
             (or (string->number
                  (list-ref args 0))
                 4)
             4))

       (define max-tries
         (if (>= (length args) 2)
             (or (string->number
                  (list-ref args 1))
                 5)
             5))

       ;; ------------------------------------------------------------
       ;; Constants
       ;; ------------------------------------------------------------

       (define wait-count
         50)

       (define wait-seconds
         2)

       (define dialog-timeout
         5)

       (define home
         (or (getenv "HOME") ""))

       (define mp-base
         (string-append
          home
          "/.repos/git/main/resource/userorg/main/readwrite/private/user/secretcryptfs/noenc/mountpoints"))

       (define mtrg-orgp
         (string-append mp-base "/orgp"))

       (define mtrg-secure
         (string-append mp-base "/secure"))

       ;; ------------------------------------------------------------
       ;; Helpers
       ;; ------------------------------------------------------------

       ;; Avoid external df/mount parsing.
       ;; Compare device IDs instead.
       (define (mounted? path)

         (let ((st
                (false-if-exception
                 (stat path)))

               (root
                (stat "/")))

           (and st
                (not
                 (= (stat:dev st)
                    (stat:dev root))))))

       (define (ssh-key-count)

         (let* ((port
                 (open-input-pipe
                  (string-append
                   ssh-add
                   " -l 2>/dev/null")))

                (txt
                 (get-string-all port)))

           (close-pipe port)

           (length
            (filter
             (lambda (x)
               (not (string-null? x)))
             (string-split txt #\newline)))))

       (define (show-warning)

         (system*
          zenity
          (string-append
           "--timeout="
           (number->string dialog-timeout))
          "--warning"
          "--title=Secret Locked or Not Found"
          "--text=Unlock KeePassXC database"))

       (define (wait-for-mounts)

         (let loop ((count wait-count))

           (cond

            ((and (mounted? mtrg-secure)
                  (mounted? mtrg-orgp))

             #t)

            ((<= count 0)

             #f)

            (else

             (sleep wait-seconds)

             (loop (- count 1))))))

       ;; ------------------------------------------------------------
       ;; Main
       ;; ------------------------------------------------------------

       (unless (wait-for-mounts)

         (format
          (current-error-port)
          "mounts unavailable\n")

         (exit 1))

       (let loop ((tries 0))

         (when (and (< tries max-tries)
                    (< (ssh-key-count)
                       min-keys-count))

           ;; ensure keepassxc running
           (system* herd "enable" "keepassxc")

           (primitive-fork)

           (system* herd "start" "keepassxc")

           (sleep 1)

           ;; trigger secret retrieval
           (system*
            secret-tool
            "lookup"
            "rclone-config"
            "rclone-config")

           (sleep 1)

           (when (< (ssh-key-count)
                    min-keys-count)

             (sleep 5)

             (show-warning))

           (loop (+ tries 1)))))))

(define ssh-add-key (local-file "scripts/ssh-add-key"))

(define ssh-add-key-entry
  (file->package "ssh-add-key"
                 ssh-add-key-guile))

;; ------------------------------------------------------------
;; Single instance shepherd service
;; ------------------------------------------------------------
(define-public home-ssh-add-key-service

  (list

   ;; Put executable into profile
   (simple-service
    'ssh-add-key-profile
    home-profile-service-type
    (list ssh-add-key-entry))

   ;; Singleton shepherd service
   (simple-service
    'ssh-add-key-shepherd
    home-shepherd-service-type
    (list
     (shepherd-service
      (provision '(ssh-add))
      (documentation "SSH key auto-loader.")
      (requirement '())
      (auto-start? #f)
      (start
       #~(make-forkexec-constructor
          (list ;; #$ssh-add-key
           (string-append (getenv "HOME")
                          "/.bin/ssh-add-key")
           "4"   ;; minimum keys required
           "5")  ;; maximum retry count
          #:create-session? #f
          #:log-file
          #$(log-file "ssh-add-key")))
      (stop
       #~(make-kill-destructor))
      (one-shot? #t)
      (respawn? #f))))))



;; ------------------------------------------------------------
;; Program
;; ------------------------------------------------------------


(define git-annex-daemon-guile
  (program-file
   "git-annex-daemon"

   #~(begin

       (use-modules
        (ice-9 match)
        (ice-9 format)
        (ice-9 popen)
        (ice-9 textual-ports)
        (ice-9 ftw)
        (ice-9 regex)
        (srfi srfi-1)
        (srfi srfi-13))

       ;; ------------------------------------------------------------
       ;; Store paths
       ;; ------------------------------------------------------------

       (define git
         #$(file-append git "/bin/git"))

       (define git-annex
         #$(file-append git-annex "/bin/git-annex"))

       (define secret-tool
         #$(file-append libsecret "/bin/secret-tool"))

       (define notify-send
         #$(file-append libnotify "/bin/notify-send"))

       (define zenity
         #$(file-append zenity "/bin/zenity"))

       (define timeout
         #$(file-append coreutils "/bin/timeout"))

       (define pkill
         #$(file-append procps "/bin/pkill"))

       (define ps
         #$(file-append procps "/bin/ps"))

       ;; ------------------------------------------------------------
       ;; Constants
       ;; ------------------------------------------------------------

       (define PROGRAM-INITIAL-WAIT-TIME
         (* 8 60))

       (define RCLONE-PASS-MAX-ATTEMPTS
         10)

       (define RCLONE-PASS-INTERVAL
         60)

       (define PPID-AGE-MINS-MAX
         10)

       (define ANNEX-ALLOWED-BRANCH
         "annex/auto/inbox")

       ;; ------------------------------------------------------------
       ;; Runtime
       ;; ------------------------------------------------------------

       (define home
         (or (getenv "HOME") ""))

       (define autostart-file
         (string-append
          home
          "/.config/git-annex/autostart"))

       (define rclone-config-link
         (string-append
          home
          "/.config/rclone/rclone.conf"))

       ;; ------------------------------------------------------------
       ;; Helpers
       ;; ------------------------------------------------------------

       (define (notify fmt . args)

         (apply
          system*
          notify-send
          (list
           (apply format #f fmt args))))

       (define (error-block fmt . args)

         (define msg
           (apply format #f fmt args))

         (system*
          notify-send
          msg)

         (system*
          zenity
          "--error"
          "--timeout=10000"
          "--text"
          msg))

       (define (info-block fmt . args)

         (define msg
           (apply format #f fmt args))

         (system*
          notify-send
          msg)

         (system*
          zenity
          "--info"
          "--timeout=10000"
          "--text"
          msg))

       ;; ------------------------------------------------------------
       ;; Shepherd parent detection
       ;; ------------------------------------------------------------

       (define (process-cmd pid)

         (let* ((port
                 (open-input-pipe
                  (string-append
                   ps
                   " -p "
                   (number->string pid)
                   " -o cmd=")))

                (txt
                 (string-trim-right
                  (get-string-all port)
                  #\newline)))

           (close-pipe port)

           txt))

       (define (process-ppid pid)

         (let* ((port
                 (open-input-pipe
                  (string-append
                   ps
                   " -p "
                   (number->string pid)
                   " -o ppid=")))

                (txt
                 (string-trim-both
                  (get-string-all port))))

           (close-pipe port)

           (or (string->number txt)
               0)))

       (define (process-age-mins pid)

         (let* ((port
                 (open-input-pipe
                  (string-append
                   ps
                   " -p "
                   (number->string pid)
                   " -o etimes=")))

                (txt
                 (string-trim-both
                  (get-string-all port))))

           (close-pipe port)

           (quotient
            (or (string->number txt)
                0)
            60)))

       (define (find-shepherd-parent)

         (let loop ((pid (getppid)))

           (cond

            ((<= pid 0)
             #f)

            ((string-contains
              (process-cmd pid)
              "/run/current-system/profile/bin/shepherd")

             pid)

            (else
             (loop
              (process-ppid pid))))))

       ;; ------------------------------------------------------------
       ;; Initial wait
       ;; ------------------------------------------------------------

       (define (sleep-if-parent-not-old)

         (let ((parent
                (find-shepherd-parent)))

           (when parent

             (let ((age
                    (process-age-mins parent)))

               (notify
                "Parent shepherd ~a age ~a mins"
                parent
                age)

               (when (< age
                        PPID-AGE-MINS-MAX)

                 (notify
                  "Sleeping initial wait")

                 (sleep
                  PROGRAM-INITIAL-WAIT-TIME))))))

       ;; ------------------------------------------------------------
       ;; Rclone config
       ;; ------------------------------------------------------------

       (define rclone-config
         (false-if-exception
          (canonicalize-path
           rclone-config-link)))

       (define rclone-config-dir
         (and rclone-config
              (dirname rclone-config)))

       (define (git-dir-clean? dir file)

         (zero?
          (system*
           git
           "-C"
           dir
           "diff"
           "--quiet"
           "--"
           file)))

       (define (rclone-config-push)

         (when (and rclone-config-dir
                    (not
                     (git-dir-clean?
                      rclone-config-dir
                      (basename rclone-config))))

           (notify
            "Committing rclone config")

           (system*
            git
            "-C"
            rclone-config-dir
            "add"
            (basename rclone-config))

           (system*
            git
            "-C"
            rclone-config-dir
            "commit"
            "-m"
            "rclone.conf modified")

           (system*
            git
            "-C"
            rclone-config-dir
            "push")))

       (define (rclone-config-pull)

         (when rclone-config-dir

           (rclone-config-push)

           (notify
            "Pulling rclone config")

           (system*
            git
            "-C"
            rclone-config-dir
            "pull"
            "--rebase")))

       (define (rclone-config-rebase-abort)

         (when rclone-config-dir

           (system*
            git
            "-C"
            rclone-config-dir
            "rebase"
            "--abort")))

       ;; ------------------------------------------------------------
       ;; Secret retrieval
       ;; ------------------------------------------------------------

       (define (get-rclone-pass)

         (let* ((port
                 (open-input-pipe
                  (string-append
                   timeout
                   " 60 "
                   secret-tool
                   " lookup rclone-config rclone-config")))

                (txt
                 (string-trim-right
                  (get-string-all port)
                  #\newline)))

           (close-pipe port)

           (and (not (string-null? txt))
                txt)))

       (define (ensure-rclone-pass)

         (let loop ((attempts 0))

           (cond

            ((>= attempts
                  RCLONE-PASS-MAX-ATTEMPTS)

             #f)

            ((get-rclone-pass)

             =>

             (lambda (pass)

               (setenv
                "RCLONE_CONFIG_PASS"
                pass)

               pass))

            (else

             (notify
              "Failed to get RCLONE_CONFIG_PASS attempt ~a"
              attempts)

             (sleep
              RCLONE-PASS-INTERVAL)

             (system*
              pkill
              "-u"
              (number->string (getuid))
              "gnome-keyr")

             (info-block
              "Enable Secret Service for KeepassXC")

             (loop (+ attempts 1))))))

       ;; ------------------------------------------------------------
       ;; Allowed branches
       ;; ------------------------------------------------------------

       (define (repo-current-branch repo)

         (let* ((port
                 (open-input-pipe
                  (string-append
                   git
                   " -C "
                   repo
                   " rev-parse --abbrev-ref HEAD")))

                (txt
                 (string-trim-right
                  (get-string-all port)
                  #\newline)))

           (close-pipe port)

           txt))

       (define (allowed-branch? repo)

         (let ((branch
                (repo-current-branch repo)))

           (or
            (string=?
             branch
             ANNEX-ALLOWED-BRANCH)

            (zero?
             (system*
              git
              "-C"
              repo
              "config"
              "--get-all"
              "annex-extention.assistant.allowedBranch"
              branch)))))

       (define (all-allowed-branches?)

         (if (not (file-exists? autostart-file))

             #f

             (call-with-input-file
                 autostart-file

               (lambda (port)

                 (let loop ((lines
                             (read-lines port)))

                   (cond

                    ((null? lines)
                     #t)

                    ((string-null?
                      (string-trim-both
                       (car lines)))

                     (loop (cdr lines)))

                    (else

                     (let ((repo
                            (car lines)))

                       (and
                        (file-exists?
                         (string-append repo "/.git"))

                        (allowed-branch? repo)

                        (loop
                         (cdr lines)))))))))))

       ;; ------------------------------------------------------------
       ;; Main
       ;; ------------------------------------------------------------

       (let* ((args
               (cdr (command-line)))

              (command
               (if (pair? args)
                   (car args)
                   #f)))

         (unless command

           (format
            (current-error-port)
            "Usage: git-annex-daemon [assistant|webapp|stop]\n")

           (exit 1))

         (unless (string=? command
                            "stop")

           (setenv
            "SSH_AUTH_SOCK"
            "/run/user/1000/keyring/ssh")

           (sleep-if-parent-not-old)

           (rclone-config-pull)

           (unless (ensure-rclone-pass)

             (error-block
              "Failed to get RCLONE_CONFIG_PASS")

             (exit 1))

           ;; validate rclone config
           (unless
               (zero?
                (system*
                 "rclone"
                 "config"
                 "show"))

             (error-block
              "Failed to decrypt rclone config")

             (exit 1)))

         ;; ------------------------------------------------------------
         ;; Dispatch
         ;; ------------------------------------------------------------

         (match command

           ("stop"

            (execl
             git
             git
             "annex"
             "assistant"
             "--autostop"
             "--explain"
             "--notify-finish"
             "--notify-start"))

           ("webapp"

            (unless
                (all-allowed-branches?)

              (error-block
               "Branch policy violation")

              (exit 1))

            (execl
             git
             git
             "annex"
             "webapp"
             "-v"
             "-d"
             "--explain"
             "--notify-finish"
             "--notify-start"))

           ("assistant"

            (unless
                (all-allowed-branches?)

              (error-block
               "Branch policy violation")

              (exit 1))

            (execl
             git
             git
             "annex"
             "assistant"
             "-v"
             "-d"
             "--autostart"
             "--foreground"
             "--explain"
             "--notify-finish"
             "--notify-start"))

           (_

            (format
             (current-error-port)
             "Unknown command ~a\n"
             command)

            (exit 1)))))))

(define git-annex-daemon (local-file "scripts/git-annex-daemon"))

(define git-annex-daemon-entry
  (file->package "git-annex-daemon"
                 git-annex-daemon-guile))


;; ------------------------------------------------------------
;; Single instance service
;; ------------------------------------------------------------

(define-public home-git-annex-daemon-service

  (list

   ;; Install into actual profile
   (simple-service
    'git-annex-daemon-profile
    home-profile-service-type
    (list git-annex-daemon-entry))

   ;; Singleton shepherd service
   (simple-service
    'git-annex-daemon-shepherd
    home-shepherd-service-type

    (list

     (let ((component (car '("assistant"
                             "webapp"
                             "stop")))
           (cmd (file-append git "/bin/git")))
      (shepherd-service
       (provision '(annex git-annex-daemon))
       (documentation
        "Git Annex daemon service.")
       (requirement
        '(keepassxc
          ssh-add))
           ;; xawaken-session-down
       (respawn? #f)
       (respawn-delay 600)
       (respawn-limit 10)
       (auto-start? #f)
       ;; (start
       ;;  #~(make-forkexec-constructor
       ;;     (list
       ;;      #$git-annex-daemon
       ;;      "assistant"
       ;;      "--verbose")
       ;;     #:log-file
       ;;     #$(log-file "annex-assistant")))
       (start #~(lambda ( . args)
                  (let* ((component (if (pair? args)
                                        (car args)
                                        #$component))
                         (log-file-loc (string-append "annex" "-" component))
                         (constructor (make-forkexec-constructor (list #$cmd "annex" "daemon" component)
                                                                 ;; https://issues.guix.gnu.org/67175
                                                                 #:log-file (log-file log-file-loc))))
                    (apply constructor args))))
       ;; Use annex daemon stop
       ;; instead of kill.
       ;; (stop
       ;;  #~(let ((destructor

       ;;            (make-system-destructor
       ;;             (string-append
       ;;              ;; #$git-annex-daemon
       ;;              (getenv "HOME") "/.bin/git-annex-daemon"
       ;;              " stop"
       ;;              " >> "
       ;;              #$(log-file "annex-stop")
       ;;              " 2>&1"))))

       ;;      (lambda (running . args)

       ;;        (apply destructor
       ;;               running
       ;;               args))))
       (stop #~(let* ((make-cmd-destructor
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
                                      args)))))
                      (component "stop")
                      (log-file-loc (string-append "annex" "-" component))
                      (destructor (make-cmd-destructor (string-join (list #$cmd "annex" "daemon" component) " ")
                                                       ;; " >> "
                                                       ;; (log-file log-file-loc)
                                                       " 2>&1")))
                   destructor))
       (one-shot? #f)))))))


