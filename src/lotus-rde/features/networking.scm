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
  #:use-module (gnu services certbot)
  #:use-module (gnu services web)
  #:use-module (gnu system nss)
  ;; #:use-module (rde system services networking)
  #:use-module (rde system services accounts)

  #:use-module (gnu packages i2p)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages web)
  #:use-module (rde packages)

  #:use-module (guix gexp)

  #:export (feature-lotus-networking
            feature-lotus-webserver
            feature-dnsmasq-services))





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
   (values `((shepherd-nm-applet (wmlogin))
             (,f-name . #t)
             ,@(if mdns?
                   `((name-service . ,%mdns-host-lookup-nss)
                     (mdns . #t))
                   '())))
   (home-services-getter get-home-services)
   (system-services-getter get-system-services)))


(define* (feature-lotus-webserver
          #:key
          (nginx nginx)
          (nginx-rtmp-module nginx-rtmp-module)
          (sites
           '((("localhost")
              (publish 8080 "/~s")
              (home 8080 "/home")
              (openclaw 19789 "/openclaw"))

             (("home.local")
              (home 8080 "/home"))

             (("openclaw.local")
              (openclaw 19789 "/openclaw"))

             (("example.local")
              (app2-api 888 "/api")
              (app2-admin 999 "/admin")))))

  (define (get-home-services config)
    (list))

  (define (get-system-services config)

    (define (site->link host site)
      (let ((name   (symbol->string (car site)))
            (prefix (caddr site)))
        (string-append
         "<li><a href=\"" prefix "\">"
         name
         " (" prefix ")"
         "</a></li>\n")))

    (define (server->index-page server)
      (let ((host  (car (car server)))
            (sites (cdr server)))
        (string-append
         "<!DOCTYPE html>\n"
         "<html>\n"
         "<head>\n"
         "  <meta charset=\"UTF-8\">\n"
         "  <title>" host "</title>\n"
         "</head>\n"
         "<body>\n"
         "  <h1>" host "</h1>\n"
         "  <ul>\n"
         (apply string-append
                (map (lambda (site)
                       (site->link host site))
                     sites))
         "  </ul>\n"
         "</body>\n"
         "</html>\n")))

    ;; Convert one site specification into an nginx-location-configuration.
    (define (site->location site)
      (let ((port   (cadr site))
            (prefix (caddr site)))
        (nginx-location-configuration
         (uri prefix)
         (body
          (list
           (string-append
            "proxy_pass http://127.0.0.1:"
            (number->string port)
            ;; ";"
            "/;")
           "proxy_set_header Host $host;"
           "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
           "proxy_set_header X-Forwarded-Proto $scheme;")))))

    ;; Convert one server specification into an nginx-server-configuration.
    (define (server->server-block server)
      (let ((hosts (car server))
            (sites (cdr server)))
        (nginx-server-configuration
         (server-name hosts)
         (listen '("80" "[::]:80"))
         (locations
          (cons
           ;; Index for this particular server.
           (nginx-location-configuration
            (uri "/")
            (body
             (list
              "default_type text/html;"
              (string-append
               "return 200 '"
               (server->index-page server)
               "';"))))
           ;; Proxies for this server.
           (map site->location sites))))))

    (list
     (service certbot-service-type
              (certbot-configuration
               (certificates
                (list
                 (certificate-configuration
                  (name "app1")
                  (domains '("app1.example.org")))
                 (certificate-configuration
                  (name "app2")
                  (domains '("app2.example.org")))))))

     (service nginx-service-type
              (nginx-configuration
               (nginx nginx)
               (server-blocks
                (map server->server-block sites))))))

  (feature
   (name 'webserver)
   (values '())
   (home-services-getter get-home-services)
   (system-services-getter get-system-services)))

(define* (feature-dnsmasq-services
          #:key
          (no-resolv? #t)
          (local-service? #t))
  ;; https://notabug.org/thomassgn/guixsd-configuration/src/master/config.scm
  ;; https://guix.gnu.org/manual/en/html_node/Networking-Services.html
  ;; https://jonathansblog.co.uk/using-dnsmasq-as-an-internal-dns-server-to-block-online-adverts
  ;; https://stackoverflow.com/questions/48644841/multiple-addn-hosts-conf-in-dnsmasq
  (define (get-home-services config)
    (list))

  (define (get-system-services config)
    (list
     (service dnsmasq-service-type
              (dnsmasq-configuration
                (no-resolv? no-resolv?)
                (local-service? local-service?)))))

  (feature
   (name 'dnsmasq)
   (values `())
   (home-services-getter get-home-services)
   (system-services-getter get-system-services)))


;; (define* (feature-network-manager-services
;;           #:key
;;           (vpn-plugins (list network-manager-fortisslvpn
;;                              network-manager-openconnect))
;;           (dns "dnsmasq"))
;;   ;; https://guix.gnu.org/manual/en/html_node/Networking-Services.html
;;   (define (get-home-services config)
;;     (list))

;;   (define (get-system-services config)
;;     (list
;;      (service network-manager-service-type
;;               (network-manager-configuration
;;                (vpn-plugins vpn-plugins)
;;                (dns dns)))))

;;   (feature
;;    (name 'network-manager-vpn)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))

;; (define* (feature-dns-services)
;;   ;; https://guix.gnu.org/manual/en/html_node/Avahi-Services.html
;;   (define (get-home-services config)
;;     (list))

;;   (define (get-system-services config)
;;     (list
;;      (service avahi-service-type)))

;;   (feature
;;    (name 'avahi)
;;    (values `())
;;    (home-services-getter get-home-services)
;;    (system-services-getter get-system-services)))



