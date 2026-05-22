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
  #:use-module (gnu packages bash)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages package-management)
  #:use-module (rde serializers yaml)
  #:use-module (lotus-rde lib utils)
  #:export (home-bluetooth-auto-connect-configuration
            home-bluetooth-auto-connect-shepherd-services
            home-bluetooth-auto-connect-service-type

            home-power-monitor-configuration
            home-power-monitor-shepherd-services
            home-power-monitor-service-type))




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




