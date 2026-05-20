;;; rde --- Reproducible development environment.
;;;
;;; Copyright © 2022, 2023 Andrew Tropin <andrew@trop.in>
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

(define-module (lotus-rde features networking)
  #:use-module (rde features)
  #:use-module (rde predicates)

  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (rde home services i2p)
  #:use-module (gnu services networking)
  #:use-module (gnu system nss)
  ;; #:use-module (rde system services networking)
  #:use-module (rde system services accounts)

  #:use-module (gnu packages i2p)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages gnome)
  #:use-module (rde packages)

  #:use-module (guix gexp)

  #:export (feature-lotus-networking))




(define* (feature-lotus-networking
          #:key
          (dns "default")
          (vpn-plugins '())
          (extra-configuration-files '())
          (iwd? #t)
          (iwd-autoconnect? #t)
          (network-manager network-manager)
          (network-manager-applet network-manager-applet)
          mdns?)
  "Configure iwd and everything."
  (ensure-pred file-like? network-manager)
  (ensure-pred file-like? network-manager-applet)

  (define f-name 'networking)
  (define (get-home-services config)
    (list
     (simple-service 'network-manager-applet-package
                     home-profile-service-type
                     (list network-manager-applet))
     ;; TODO: Disable nm-applet notification by default
     ;; gsettings set org.gnome.nm-applet disable-connected-notifications true
     (simple-service
      'networking-nm-applet-shepherd-service
      home-shepherd-service-type
      (list
       (shepherd-service
        (provision '(nm-applet))
        (requirement '(dbus))
        (stop  #~(make-kill-destructor))
        (start #~(make-forkexec-constructor
                  (list #$(file-append network-manager-applet "/bin/nm-applet")
                        "--indicator")
                  #:log-file (string-append
                              (getenv "XDG_STATE_HOME") "/log"
                              "/nm-applet.log"))))))))

  (define (get-system-services config)
    (list
     (service network-manager-service-type
              (network-manager-configuration
                (network-manager network-manager)
                (shepherd-requirement (if iwd?
                                          '(iwd)
                                          '(wireless-daemon)))
                (dns dns)
                (vpn-plugins vpn-plugins)
                (iwd? (if iwd?
                          '(iwd)
                          #f))
                (extra-configuration-files extra-configuration-files)))
     (if iwd?
         (service iwd-service-type
                  (iwd-configuration
                    (config
                     (iwd-settings
                       (general
                        (iwd-general-settings
                          (extra-options
                           `((AutoConnect . ,iwd-autoconnect?)))))))))
         (service wpa-supplicant-service-type))    ;needed by NetworkManager
     (service modem-manager-service-type)
     (service usb-modeswitch-service-type)))

  (feature
   (name f-name)
   (values `((,f-name . #t)
             ,@(if mdns?
                   `((name-service . ,%mdns-host-lookup-nss)
                     (mdns . #t))
                   '())))
   (home-services-getter get-home-services)
   (system-services-getter get-system-services)))

