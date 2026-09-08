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
  #:use-module (guix records)

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


(define-record-type* <lotus-server>
  lotus-server
  make-lotus-server
  lotus-server?
  (server-name lotus-server-name
               (default '("_")))
  (listen lotus-server-listen
          (default '("80" "[::]:80")))
  (root lotus-server-root
        (default "/srv/http"))
  (index lotus-server-index
         (default "index.html"))
  (server-tokens lotus-server-tokens
                 (default #f))
  (ssl-certificate lotus-server-ssl-certificate
                   (default #f))
  (ssl-certificate-key lotus-server-ssl-certificate-key
                        (default #f))
  (raw-content lotus-server-raw-content
               (default '()))
  (services lotus-server-services
            (default '())))


(define* (feature-lotus-webserver
          #:key
          (nginx nginx)
          (nginx-rtmp-module nginx-rtmp-module)
          (servers
           (list

            ;; Default server.
            (lotus-server
             (server-name '("_"))
             (listen '("80 default_server"
                       "[::]:80 default_server"))
             (services
              '((publish 8080 "/~s")
                (home 8080 "/home")
                (openclaw 18789 "/openclaw"))))

            ;; Home.
            (lotus-server
             (server-name '("home.local"))
             (services
              '((home 8080 "/home"))))

            ;; OpenClaw.
            (lotus-server
             (server-name '("openclaw.local"))
             (services
              '((openclaw 18789 "/openclaw"))))

            ;; ;; HTTPS application.
            ;; ;;
            ;; ;; The certificate and key must exist when nginx starts.
            ;; (lotus-server
            ;;  (server-name '("app1.example.org"))
            ;;  (listen '("443 ssl"
            ;;            "[::]:443 ssl"))
            ;;  (ssl-certificate
            ;;   "/etc/letsencrypt/live/app1/fullchain.pem")
            ;;  (ssl-certificate-key
            ;;   "/etc/letsencrypt/live/app1/privkey.pem")
            ;;  (services
            ;;   '((app1 8080 "/app1"))))


            ;; Example application.
            (lotus-server
             (server-name '("example.local"))
             (services
              '((app2-api 888 "/api")
                (app2-admin 999 "/admin")))))))

  (define (get-home-services config)
    (list))

  (define (get-system-services config)

    ;; ------------------------------------------------------------
    ;; Generate one link for a service.
    ;; ------------------------------------------------------------

    (define (service->link service)
      (let ((name   (symbol->string (car service)))
            (prefix (caddr service)))
        (string-append
         "<li><a href=\"" prefix "\">"
         name
         " (" prefix ")"
         "</a></li>\n")))


    ;; ------------------------------------------------------------
    ;; Generate the index page for one server.
    ;; ------------------------------------------------------------

    (define (server->index-page server)
      (let ((host     (car (lotus-server-name server)))
            (services (lotus-server-services server)))
        (string-append
         "<!DOCTYPE html>\n"
         "<html>\n"
         "<head>\n"
         "  <meta charset=\"UTF-8\">\n"
         "  <title>"
         (match host
           ("_" "Default server")
           (_ host))
         "</title>\n"
         "</head>\n"
         "<body>\n"
         "  <h1>" host "</h1>\n"
         "  <ul>\n"
         (apply string-append
                (map service->link services))
         "  </ul>\n"
         "</body>\n"
         "</html>\n")))

    ;; ------------------------------------------------------------
    ;; Convert one Lotus service into nginx locations.
    ;;
    ;; Example:
    ;;
    ;;   (home 8080 "/home")
    ;;
    ;; becomes:
    ;;
    ;;   location /home {
    ;;       return 301 /home/;
    ;;   }
    ;;
    ;;   location /home/ {
    ;;       proxy_pass http://127.0.0.1:8080/;
    ;;   }
    ;;
    ;; The trailing "/" in proxy_pass causes nginx to strip
    ;; "/home/" before forwarding to port 8080.
    ;; ------------------------------------------------------------

    (define (service->locations service)
      (let ((port   (cadr service))
            (prefix (caddr service)))

        (list

         ;; /home -> /home/
         (nginx-location-configuration
          (uri prefix)
          (body
           (list
            (string-append
             "return 301 "
             prefix
             "/;"))))

         ;; /home/... -> backend /...
         (nginx-location-configuration
          (uri (string-append prefix "/"))
          (body
           (list
            (string-append
             "proxy_pass http://127.0.0.1:"
             (number->string port)
             "/;")

            "proxy_set_header Host $host;"
            "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
            "proxy_set_header X-Forwarded-Proto $scheme;"))))))


    ;; ------------------------------------------------------------
    ;; Generate the locations belonging to one server.
    ;; ------------------------------------------------------------

    (define (server->locations server)

      (cons

       ;; Server index.
       (nginx-location-configuration
        (uri "/")
        (body
         (list
          "default_type text/html;"
          (string-append
           "return 200 '"
           (server->index-page server)
           "';"))))

       ;; Service locations.
       (apply append
              (map service->locations
                   (lotus-server-services server)))))


    ;; ------------------------------------------------------------
    ;; Convert one lotus-server into an nginx-server-configuration.
    ;; ------------------------------------------------------------

    (define (server->server-block server)

      (nginx-server-configuration

       ;; server_name
       (server-name
        (lotus-server-name server))

       ;; listen
       (listen
        (lotus-server-listen server))

       ;; root
       (root
        (lotus-server-root server))

       ;; index expects a list in Guix's nginx configuration.
       (index
        (list
         (lotus-server-index server)))

       ;; Guix calls this field server-tokens?.
       (server-tokens?
        (lotus-server-tokens server))

       ;; These are emitted only when non-#f.
       (ssl-certificate
        (lotus-server-ssl-certificate server))

       (ssl-certificate-key
        (lotus-server-ssl-certificate-key server))

       ;; Arbitrary additional nginx directives.
       (raw-content
        (lotus-server-raw-content server))

       ;; /
       ;; /prefix
       ;; /prefix/
       (locations
        (server->locations server))))


    ;; ------------------------------------------------------------
    ;; Services.
    ;; ------------------------------------------------------------

    (list

     ;; Let's Encrypt / Certbot.
     (service certbot-service-type
              (certbot-configuration
               (certificates
                (list

                 (certificate-configuration
                  (name "app1")
                  (domains
                   '("app1.example.org")))

                 (certificate-configuration
                  (name "app2")
                  (domains
                   '("app2.example.org")))))))


     ;; Nginx.
     (service nginx-service-type
              (nginx-configuration
               (nginx nginx)

               (server-blocks
                (map server->server-block
                     servers))))))


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

