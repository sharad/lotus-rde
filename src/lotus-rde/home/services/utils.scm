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
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages gnupg)
  #:use-module (rde serializers yaml)
  #:use-module (lotus-rde lib utils)
  #:export (home-bluetooth-auto-connect-configuration
            home-bluetooth-auto-connect-shepherd-services
            home-bluetooth-auto-connect-service-type

            home-power-monitor-configuration
            home-power-monitor-shepherd-services
            home-power-monitor-service-type

            home-kpkey-configuration
            home-kpkey-shepherd-services
            home-kpkey-service-type

            home-ssh-add-key-configuration
            home-ssh-add-key-shepherd-services
            home-ssh-add-key-service-type))




;; ------------------------------------------------------------
;; Configuration
;; ------------------------------------------------------------

(define-configuration/no-serialization
  home-bluetooth-auto-connect-configuration

  ;; (package
  ;;  (package guile-dbus)
  ;;  "Guile DBus package.")

  (verbose?
   (boolean #t)
   "Enable verbose logging.")

  (daemon?
   (boolean #t)
   "Run in daemon mode."))

;; ------------------------------------------------------------
;; Program
;; ------------------------------------------------------------


(define bluetooth-auto-connect ;; not being used.
  (with-imported-modules
      (source-module-closure
       '((dbus)
         (dbus mainloop)
         (oop goops)))
    (program-file
     "bluetooth-auto-connect"

     #~(begin
         (use-modules
          (srfi srfi-1)
          (ice-9 match)
          (ice-9 format)
          (oop goops)
          (dbus)
          (dbus mainloop))

         ;; ------------------------------------------------------------
         ;; Config
         ;; ------------------------------------------------------------

         (define daemon?
           (member "--daemon"
                   (command-line)))

         (define verbose?
           (or (member "-v" (command-line))
               (member "--verbose"
                       (command-line))))

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
         ;; Helpers
         ;; ------------------------------------------------------------

         (define (managed-objects)
           (object-manager "GetManagedObjects"))

         (define (adapter? interfaces)
           (assoc-ref interfaces
                      "org.bluez.Adapter1"))

         (define (device? interfaces)
           (assoc-ref interfaces
                      "org.bluez.Device1"))

         (define (powered? adapter)
           (assoc-ref adapter "Powered"))

         (define (trusted? device)
           (assoc-ref device "Trusted"))

         (define (connected? device)
           (assoc-ref device "Connected"))

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
                            (not (connected? device)))

                   (vfmt
                    "connecting ~a\n"
                    path)

                   (catch #t

                     (lambda ()

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

                       (format
                        (current-error-port)
                        "failed ~a\n"
                        path)))))))

            (managed-objects)))

         ;; ------------------------------------------------------------
         ;; React to adapter power-on
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
              "adapter powered on: ~a\n"
              path)

             (connect-devices)))

         ;; ------------------------------------------------------------
         ;; Main
         ;; ------------------------------------------------------------

         ;; Initial connect
         (connect-devices)

         ;; Daemon mode
         (when daemon?

           (add-match
            bus
            properties-changed
            "type='signal',\
interface='org.freedesktop.DBus.Properties',\
sender='org.bluez'")

           ;; Keep process alive
           (let loop ()
             (sleep 3600)
             (loop)))))))


(define (bluetooth-auto-connect-program config)

  (let (;; (guile-dbus
        ;;  (home-bluetooth-auto-connect-configuration-package
        ;;   config))

        (verbose?
         (home-bluetooth-auto-connect-configuration-verbose?
          config))

        (daemon?
         (home-bluetooth-auto-connect-configuration-daemon?
          config)))

    ;; (with-extensions
    ;;     (list guile-dbus))

    (with-imported-modules
          (source-module-closure
           '((dbus)
             (dbus mainloop)
             (oop goops)))

        (program-file
         "bluetooth-auto-connect"

         #~(begin
             (use-modules
              (srfi srfi-1)
              (ice-9 match)
              (ice-9 format)
              (oop goops)
              (dbus)
              (dbus mainloop))

             ;; ------------------------------------------------------------
             ;; Config
             ;; ------------------------------------------------------------

             (define daemon?
               #$daemon?)

             (define verbose?
               #$verbose?)

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
             ;; Helpers
             ;; ------------------------------------------------------------

             (define (managed-objects)
               (object-manager "GetManagedObjects"))

             (define (device? interfaces)
               (assoc-ref interfaces
                          "org.bluez.Device1"))

             (define (trusted? device)
               (assoc-ref device "Trusted"))

             (define (connected? device)
               (assoc-ref device "Connected"))

             ;; ------------------------------------------------------------
             ;; Connect devices
             ;; ------------------------------------------------------------

             (define (connect-devices)

               (for-each

                (match-lambda

                  ((path . interfaces)

                   (let ((device
                          (device? interfaces)))

                     (when (and device
                                (trusted? device)
                                (not (connected? device)))

                       (vfmt
                        "connecting ~a\n"
                        path)

                       (catch #t

                         (lambda ()

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

                           (format
                            (current-error-port)
                            "failed ~a\n"
                            path)))))))

                (managed-objects)))

             ;; ------------------------------------------------------------
             ;; React to adapter power-on
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
                  "adapter powered on: ~a\n"
                  path)

                 (connect-devices)))

             ;; ------------------------------------------------------------
             ;; Main
             ;; ------------------------------------------------------------

             ;; Initial scan
             (connect-devices)

             ;; Daemon mode
             (when daemon?

               (add-match
                bus
                properties-changed
                "type='signal',\
interface='org.freedesktop.DBus.Properties',\
sender='org.bluez'")

               ;; Keep process alive
               (let loop ()
                 (sleep 3600)
                 (loop))))))))

;; ------------------------------------------------------------
;; Shepherd service
;; ------------------------------------------------------------

(define (home-bluetooth-auto-connect-shepherd-services config)

  (let ((program
         (bluetooth-auto-connect-program config)))

    (list

     (shepherd-service
      (provision '(bluetooth-auto-connect))

      (documentation
       "Automatically connect trusted Bluetooth devices.")

      (requirement '(dbus))

      (respawn? #t)

      (start
       #~(make-forkexec-constructor
          (list #$program)
          #:log-file
          #$(log-file "bluetooth-auto-connect.log")))

      (stop
       #~(make-kill-destructor))))))

;; ------------------------------------------------------------
;; Service type
;; ------------------------------------------------------------

(define home-bluetooth-auto-connect-service-type

  (service-type
   (name 'home-bluetooth-auto-connect)

   (extensions
    (list

     ;; install binary into profile
     (service-extension
      home-profile-service-type
      (const (list bluetooth-auto-connect)))


     (service-extension
      home-shepherd-service-type
      home-bluetooth-auto-connect-shepherd-services)))

   (default-value
     (home-bluetooth-auto-connect-configuration))

   (description
    "Automatically connect trusted Bluetooth devices using BlueZ DBus.")))

;; (service
;;  home-bluetooth-auto-connect-service-type)
;; (service
;;  home-bluetooth-auto-connect-service-type

;;  (home-bluetooth-auto-connect-configuration
;;   (verbose? #t)
;;   (daemon? #t)))




(define-configuration/no-serialization
  home-power-monitor-configuration

  (notify-level
   (integer 10)
   "Notify every N percentage.")

  (poll-interval
   (integer 10)
   "Polling interval in seconds.")

  (battery-path
   (string "/sys/class/power_supply/BAT0/capacity")
   "Battery sysfs capacity path."))

;; ------------------------------------------------------------
;; Program
;; ------------------------------------------------------------


(define battery-monitor                 ;not being used
 (program-file
  "battery-monitor"
  #~(begin

      (use-modules
       (srfi srfi-1)
       (ice-9 match)
       (ice-9 textual-ports)
       (ice-9 popen)
       (ice-9 format)
       (ice-9 ftw))

      ;; ------------------------------------------------------------
      ;; Store paths
      ;; ------------------------------------------------------------

      (define notify-send
        #$(file-append libnotify "/bin/notify-send"))

      (define zenity
        #$(file-append zenity "/bin/zenity"))

      (define bash
        #$(file-append bash-minimal "/bin/bash"))

      (define poweroff
        #$(file-append shepherd "/sbin/poweroff"))

      ;; ------------------------------------------------------------
      ;; Actions
      ;; ------------------------------------------------------------

      (define power-low-action
        `((disposition . "below")

          (5 . ,poweroff)

          (7 . ,(string-append
                 zenity
                 " --warning --text "
                 "\"Battery is only at 7%, will poweroff it at 5%\""))

          (8 . ,(string-append
                 zenity
                 " --warning --text "
                 "\"Battery is only at 8%, will poweroff it at 5%\""))

          (9 . ,(string-append
                 zenity
                 " --warning --text "
                 "\"Battery is only at 9%, will poweroff it at 5%\""))))

      (define power-high-action
        `((disposition . "above")

          (70 . ,(string-append
                  notify-send
                  " 'charge up to 70%'"))))

      ;; ------------------------------------------------------------
      ;; Battery reading from sysfs
      ;; ------------------------------------------------------------

      (define battery-capacity-file
        "/sys/class/power_supply/BAT0/capacity")

      (define (read-status)

        (unless (file-exists? battery-capacity-file)
          (error
           "Battery capacity file not found"
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
                   "Invalid battery percentage"
                   txt))))))

      ;; ------------------------------------------------------------
      ;; Execute action
      ;; ------------------------------------------------------------

      (define (execute-action key actions)

        (define notify-percent-factor
          10)

        (define disposition
          (assoc-ref actions 'disposition))

        (define action
          (assoc-ref actions key))

        (cond

         ;; Explicit action
         ((and action (string? action))

          (system*
           bash
           "-c"
           action))

         ;; Generic notification
         ((zero? (modulo key notify-percent-factor))

          (system*
           notify-send
           (format
            #f
            "charged ~a ~a%%"
            disposition
            key)))))

      ;; ------------------------------------------------------------
      ;; Main monitoring loop
      ;; ------------------------------------------------------------

      (define (take-action)

        (let loop ((prev-charge
                    (read-status)))

          (let ((curr-charge
                 (read-status)))

            (cond

             ;; Charging
             ((> curr-charge prev-charge)

              (execute-action
               curr-charge
               power-high-action))

             ;; Discharging
             ((< curr-charge prev-charge)

              (execute-action
               curr-charge
               power-low-action)))

            (format
             #t
             "Battery: ~a% -> ~a%\n"
             prev-charge
             curr-charge)

            (sleep 10)

            (loop curr-charge))))
      (take-action))))

(define (power-monitor-program config)

  (let ((notify-level
         (home-power-monitor-configuration-notify-level
          config))

        (poll-interval
         (home-power-monitor-configuration-poll-interval
          config))

        (battery-path
         (home-power-monitor-configuration-battery-path
          config)))

    (program-file
     "battery-monitor"

     #~(begin

         (use-modules
          (srfi srfi-1)
          (ice-9 match)
          (ice-9 textual-ports)
          (ice-9 format)
          (ice-9 ftw))

         ;; ------------------------------------------------------------
         ;; Store paths
         ;; ------------------------------------------------------------

         (define notify-send
           #$(file-append libnotify "/bin/notify-send"))

         (define zenity
           #$(file-append zenity "/bin/zenity"))

         (define bash
           #$(file-append bash-minimal "/bin/bash"))

         (define poweroff
           #$(file-append shepherd "/sbin/poweroff"))

         ;; ------------------------------------------------------------
         ;; Config
         ;; ------------------------------------------------------------

         (define notify-percent-factor
           #$notify-level)

         (define poll-interval
           #$poll-interval)

         (define battery-capacity-file
           #$battery-path)

         ;; ------------------------------------------------------------
         ;; Actions
         ;; ------------------------------------------------------------

         (define power-low-action
           `((disposition . "below")

             (5 . ,poweroff)

             (7 . ,(string-append
                    zenity
                    " --warning --text "
                    "\"Battery is only at 7%, will poweroff it at 5%\""))

             (8 . ,(string-append
                    zenity
                    " --warning --text "
                    "\"Battery is only at 8%, will poweroff it at 5%\""))

             (9 . ,(string-append
                    zenity
                    " --warning --text "
                    "\"Battery is only at 9%, will poweroff it at 5%\""))))

         (define power-high-action
           `((disposition . "above")

             (70 . ,(string-append
                     notify-send
                     " 'charge up to 70%'"))))

         ;; ------------------------------------------------------------
         ;; Read battery percentage
         ;; ------------------------------------------------------------

         (define (read-status)

           (unless (file-exists? battery-capacity-file)

             (error
              "Battery capacity file not found"
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
                      "Invalid battery percentage"
                      txt))))))

         ;; ------------------------------------------------------------
         ;; Execute action
         ;; ------------------------------------------------------------

         (define (execute-action key actions)

           (define disposition
             (assoc-ref actions 'disposition))

           (define action
             (assoc-ref actions key))

           (cond

            ;; Explicit action
            ((and action (string? action))

             (system*
              bash
              "-c"
              action))

            ;; Generic notification
            ((zero? (modulo key
                             notify-percent-factor))

             (system*
              notify-send
              (format
               #f
               "charged ~a ~a%%"
               disposition
               key)))))

         ;; ------------------------------------------------------------
         ;; Main loop
         ;; ------------------------------------------------------------

         (define (take-action)

           (let loop ((prev-charge
                       (read-status)))

             (let ((curr-charge
                    (read-status)))

               (cond

                ;; Charging
                ((> curr-charge prev-charge)

                 (execute-action
                  curr-charge
                  power-high-action))

                ;; Discharging
                ((< curr-charge prev-charge)

                 (execute-action
                  curr-charge
                  power-low-action)))

               (format
                #t
                "Battery: ~a%% -> ~a%%\n"
                prev-charge
                curr-charge)

               (sleep poll-interval)

               (loop curr-charge))))

         ;; ------------------------------------------------------------
         ;; Entry
         ;; ------------------------------------------------------------

         (take-action)))))

;; ------------------------------------------------------------
;; Shepherd services
;; ------------------------------------------------------------

(define (home-power-monitor-shepherd-services config)

  (let ((program
         (power-monitor-program config)))

    (list

     (shepherd-service
      (provision '(power-monitor pm))

      (documentation
       "Battery/power monitoring daemon.")

      (requirement '(dbus))

      (respawn? #t)

      (start
       #~(make-forkexec-constructor
          (list #$program)
          #:log-file
          #$(log-file "power-monitor.log")))

      (stop
       #~(make-kill-destructor))))))

;; ------------------------------------------------------------
;; Service type
;; ------------------------------------------------------------

(define home-power-monitor-service-type

  (service-type
   (name 'home-power-monitor)

   (extensions
    (list
     ;; install binary into profile
     (service-extension
      home-profile-service-type
      (const (list battery-monitor)))

     (service-extension
       home-shepherd-service-type
       home-power-monitor-shepherd-services)))

   (default-value
     (home-power-monitor-configuration))

   (description
    "Battery/power monitoring daemon service.")))



;; (service
;;  home-power-monitor-service-type
;;  (home-power-monitor-configuration
;;   (poll-interval 15)
;;   (notify-level 5)))


;; ------------------------------------------------------------
;; Configuration
;; ------------------------------------------------------------

;; (define-configuration/no-serialization
;;   home-kpkey-configuration

;;   (respawn?
;;    (boolean #f))

;;   (one-shot?
;;    (boolean #t))

;;   (create-session?
;;    (boolean #f))

;;   (secure-mount
;;    (string
;;     (string-append
;;      (getenv "HOME")
;;      "/.repos/git/main/resource/userorg/main/readwrite/private/user/secretcryptfs/noenc/mountpoints/secure")))

;;   (key-dir
;;    (string
;;     (string-append
;;      (getenv "HOME")
;;      "/.pi/.kp/mem")))

;;   (gpg-secret
;;    (string
;;     (string-append
;;      (getenv "HOME")
;;      "/.open-secrets/secret-0.1.key.gpg"))))



(define-configuration/no-serialization
  home-kpkey-configuration

  (respawn?
   (boolean #f)
   "Respawn service.")

  (one-shot?
   (boolean #t)
   "Run once.")

  (create-session?
   (boolean #f)
   "Create shepherd session.")

  (secure-mount
   (string
    (string-append
     (getenv "HOME")
     "/.repos/git/main/resource/userorg/main/readwrite/private/user/secretcryptfs/noenc/mountpoints/secure"))
   "Secure mount path.")

  (key-dir
   (string
    (string-append
     (getenv "HOME")
     "/.pi/.kp/mem"))
   "Key directory.")

  (gpg-secret
   (string
    (string-append
     (getenv "HOME")
     "/.open-secrets/secret-0.1.key.gpg"))
   "GPG secret file."))


;; ------------------------------------------------------------
;; Program
;; ------------------------------------------------------------

(define (kpkey-program config)

  (let ((secure-mount
         (home-kpkey-configuration-secure-mount
          config))

        (key-dir
         (home-kpkey-configuration-key-dir
          config))

        (gpg-secret
         (home-kpkey-configuration-gpg-secret
          config)))

    (program-file
     "kpkey"

     #~(begin

         (use-modules
          (srfi srfi-1)
          (ice-9 match)
          (ice-9 ftw)
          (ice-9 format)
          (ice-9 textual-ports)
          (ice-9 binary-ports)
          (ice-9 popen))

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

         (define gpgconf
           #$(file-append gnupg "/bin/gpgconf"))

         ;; ------------------------------------------------------------
         ;; Config
         ;; ------------------------------------------------------------

         (define secure-mount
           #$secure-mount)

         (define key-dir
           #$key-dir)

         (define gpg-secret
           #$gpg-secret)

         ;; ------------------------------------------------------------
         ;; Helpers
         ;; ------------------------------------------------------------

         (define (notify fmt . args)

           (apply
            system*
            notify-send
            (list
             (apply format #f fmt args))))

         (define (mounted? path)

           ;; Avoid external df/mount parsing
           ;; by checking device change.

           (let ((st-root
                  (stat "/"))

                 (st-path
                  (false-if-exception
                   (stat path))))

             (and st-path
                  (not (= (stat:dev st-root)
                          (stat:dev st-path))))))

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

         (define (decrypt-file file)

           (let* ((target
                   (string-drop-right file 4))

                  (secret-port
                   (open-input-pipe
                    (string-append
                     gpg
                     " --batch --quiet --decrypt "
                     gpg-secret)))

                  (passphrase
                   (string-trim-right
                    (get-string-all secret-port)
                    #\newline)))

             (close-pipe secret-port)

             (system*
              gpg
              "--batch"
              "--yes"
              "--pinentry-mode"
              "loopback"
              "--passphrase"
              passphrase
              "--output"
              target
              "--decrypt"
              file)))

         (define (decrypt-files files)

           (for-each

            (lambda (f)

              (unless
                  (file-exists?
                   (string-drop-right f 4))

                (decrypt-file f)))

            files))

         ;; ------------------------------------------------------------
         ;; Commands
         ;; ------------------------------------------------------------

         (define (checkin)

           (mkdir-p key-dir)

           (chdir key-dir)

           (let ((files
                  (key-files)))

             (if (null? files)

                 (notify "already checked in")

                 (begin

                   (for-each

                    (lambda (f)

                      (system* shred "-u" f))

                    files)

                   (notify
                    "Successfully checked in")))))

         (define (checkout)

           (unless (mounted? secure-mount)

             (format
              (current-error-port)
              "secure mount not mounted\n")

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
             (string-append
              (dirname key-dir)
              "/.keys")
             "\\.keyx\\.gpg$"))

           ;; ------------------------------------------------------------
           ;; Decrypt
           ;; ------------------------------------------------------------

           (decrypt-files
            (encrypted-key-files))

           (if (null? (key-files))

               (notify
                "Failed to check out")

               (notify
                "Successfully checked out"))

           ;; Restart keepassxc
           (primitive-fork)

           (system*
            herd
            "restart"
            "keepassxc"))

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

           (("ci")
            (checkin))

           (("co")
            (checkout))

           ((or ("st")
                ("status"))
            (status))

           (_

            (format
             (current-error-port)
             "Usage: kpkey {ci|co|st}\n")

            (exit 1)))))))

;; ------------------------------------------------------------
;; Shepherd services
;; ------------------------------------------------------------

(define (home-kpkey-shepherd-services config)

  (let ((kpkey
         (kpkey-program config))

        (respawn?
         (home-kpkey-configuration-respawn?
          config))

        (one-shot?
         (home-kpkey-configuration-one-shot?
          config))

        (create-session?
         (home-kpkey-configuration-create-session?
          config)))

    (list

     (shepherd-service

      (provision '(kpkey kpkeys))

      (documentation
       "KeePassXC key checkout service.")

      (requirement '())

      (respawn? respawn?)

      (one-shot? one-shot?)

      (start
       #~(make-forkexec-constructor
          (list #$kpkey "co")
          #:create-session? #$create-session?
          #:log-file
          #$(log-file "kpkey.log")))

      (stop
       #~(make-kill-destructor))))))

;; ------------------------------------------------------------
;; Service type
;; ------------------------------------------------------------

(define home-kpkey-service-type

  (service-type
   (name 'home-kpkey)

   (extensions
    (list
     ;; install binary into profile
     (service-extension
      home-profile-service-type
      (const (list kpkey-program)))

     (service-extension
      home-shepherd-service-type
      home-kpkey-shepherd-services)))

   (default-value
     (home-kpkey-configuration))

   (description
    "KeePassXC key checkout/checkin service.")))



;; ------------------------------------------------------------
;; Configuration
;; ------------------------------------------------------------

(define-configuration/no-serialization
  home-ssh-add-key-configuration

  (attr-key
   (string "rclone-config")
   "Attribute key.")

  (attr-value
   (string "rclone-config")
   "Attribute value.")

  (max-tries
   (integer 5)
   "Maximum tries.")

  (min-keys-count
   (integer 4)
   "Minimum SSH keys required.")

  (dialog-timeout
   (integer 5)
   "Zenity timeout.")

  (wait-count
   (integer 50)
   "Retry count while waiting.")

  (wait-seconds
   (integer 2)
   "Seconds between retries.")

  (create-session?
   (boolean #f)
   "Create shepherd session.")

  (respawn?
   (boolean #f)
   "Respawn service.")

  (one-shot?
   (boolean #t)
   "Run once.")

  (mount-base
   (string (string-append
            (getenv "HOME")
            "/.repos/git/main/resource/userorg/main/readwrite/private/user/secretcryptfs/noenc/mountpoints"))
   "Base mount directory."))

;; ------------------------------------------------------------
;; Program
;; ------------------------------------------------------------

(define (ssh-add-key-program config)

  (let ((attr-key
         (home-ssh-add-key-configuration-attr-key
          config))

        (attr-value
         (home-ssh-add-key-configuration-attr-value
          config))

        (max-tries
         (home-ssh-add-key-configuration-max-tries
          config))

        (min-keys-count
         (home-ssh-add-key-configuration-min-keys-count
          config))

        (dialog-timeout
         (home-ssh-add-key-configuration-dialog-timeout
          config))

        (wait-count
         (home-ssh-add-key-configuration-wait-count
          config))

        (wait-seconds
         (home-ssh-add-key-configuration-wait-seconds
          config))

        (mount-base
         (home-ssh-add-key-configuration-mount-base
          config)))

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
         ;; Config
         ;; ------------------------------------------------------------

         (define ATTR-KEY
           #$attr-key)

         (define ATTR-VALUE
           #$attr-value)

         (define MAX-TRIES
           #$max-tries)

         (define MIN-KEYS-COUNT
           #$min-keys-count)

         (define DIALOG-TIMEOUT
           #$dialog-timeout)

         (define WAIT-COUNT
           #$wait-count)

         (define WAIT-SECONDS
           #$wait-seconds)

         (define MP-BASE
           #$mount-base)

         (define mtrg-orgp
           (string-append MP-BASE "/orgp"))

         (define mtrg-secure
           (string-append MP-BASE "/secure"))

         ;; ------------------------------------------------------------
         ;; Helpers
         ;; ------------------------------------------------------------

         ;; Better than external df parsing.
         ;; Compare mount device IDs.
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

             ;; Count lines instead of wc.
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
             (number->string DIALOG-TIMEOUT))
            "--warning"
            "--title=Secret Locked or Not Found"
            "--text=Secret not available. Please unlock the appropriate database in KeePassXC."))

         (define (lookup-secret)

           ;; We only care whether lookup succeeds.
           ;; No need to capture output.
           (zero?
            (system*
             secret-tool
             "lookup"
             ATTR-KEY
             ATTR-VALUE)))

         ;; ------------------------------------------------------------
         ;; Wait for mounts
         ;; ------------------------------------------------------------

         (define (wait-for-mounts)

           (let loop ((count WAIT-COUNT))

             (cond

              ((and (mounted? mtrg-secure)
                    (mounted? mtrg-orgp))

               #t)

              ((<= count 0)

               #f)

              (else

               (format
                #t
                "waiting ~a\n"
                count)

               (sleep WAIT-SECONDS)

               (loop (- count 1))))))

         ;; ------------------------------------------------------------
         ;; Main
         ;; ------------------------------------------------------------

         (if (not (wait-for-mounts))

             (begin
               (format
                (current-error-port)
                "mounts unavailable\n")
               (exit 1))

             (let loop ((tries 0))

               (when (and (< tries MAX-TRIES)
                          (< (ssh-key-count)
                             MIN-KEYS-COUNT))

                 ;; start keepassxc
                 (system* herd "enable" "keepassxc")

                 (primitive-fork)

                 (system* herd "start" "keepassxc")

                 (sleep 1)

                 (lookup-secret)

                 (sleep 1)

                 (when (< (ssh-key-count)
                          MIN-KEYS-COUNT)

                   (sleep 5)

                   (show-warning))

                 (loop (+ tries 1)))))))))

;; ------------------------------------------------------------
;; Shepherd services
;; ------------------------------------------------------------

(define (home-ssh-add-key-shepherd-services config)

  (let ((program
         (ssh-add-key-program config))

        (create-session?
         (home-ssh-add-key-configuration-create-session?
          config))

        (respawn?
         (home-ssh-add-key-configuration-respawn?
          config))

        (one-shot?
         (home-ssh-add-key-configuration-one-shot?
          config)))

    (list

     (shepherd-service
      (provision '(ssh-add ssh-add-key))

      (documentation
       "SSH key auto-loading service.")

      (requirement '())

      (respawn? respawn?)

      (one-shot? one-shot?)

      (start
       #~(make-forkexec-constructor
          (list #$program)
          #:create-session? #$create-session?
          #:log-file
          #$(log-file "ssh-add-key.log")))

      (stop
       #~(make-kill-destructor))))))

;; ------------------------------------------------------------
;; Service type
;; ------------------------------------------------------------

(define home-ssh-add-key-service-type

  (service-type
   (name 'home-ssh-add-key)

   (extensions
    (list
     (service-extension
      home-shepherd-service-type
      home-ssh-add-key-shepherd-services)))

   (default-value
     (home-ssh-add-key-configuration))

   (description
    "Automatically unlock and load SSH keys via KeePassXC/libsecret.")))




