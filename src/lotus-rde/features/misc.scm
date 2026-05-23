(define-module (lotus-rde features misc)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (rde system services admin)

  #:use-module (guix gexp)
  #:use-module (guix modules)

  #:use-module (gnu system)
  #:use-module (gnu system setuid)
  #:use-module (gnu services)
  #:use-module (gnu services admin)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services base)
  #:use-module (gnu services desktop)
  #:use-module (gnu services sound)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services xorg)
  #:use-module (gnu services admin)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services networking)
  #:use-module (gnu services avahi)
  #:use-module (gnu services dbus)
  #:use-module (gnu home services)
  #:use-module (gnu home services admin)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services shepherd)

  #:use-module (gnu packages avahi)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages glib)
  ;; #:use-module (gnu packages bash)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages nfs)
  ;; #:use-module (gnu packages gnome)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages mpd)
  #:use-module (gnu packages jupyter)
  #:use-module (gnu packages monitoring)
  #:use-module (gnu packages compton)
  #:use-module (gnu packages ibus)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages hardware)
  #:use-module (gnu packages version-control)
  #:use-module (rde packages)

  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  #:use-module (guix diagnostics)
  #:use-module (guix i18n)

  #:use-module (ice-9 match)
  #:use-module (srfi srfi-11)
  #:use-module (guix gexp)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system accounts)
  #:use-module (gnu system shadow)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system privilege)
  #:use-module (gnu system linux-initrd)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services avahi)
  #:use-module (gnu services mcron)
  ;; #:use-module (gnu services ssh)
  ;; #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages avahi)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages idutils)
  ;; #:use-module (gnu packages ssh)

  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages python)
  #:use-module (gnu packages jupyter)
  #:use-module (gnu packages music)
  #:use-module (gnu packages messaging)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages linux)
  #:use-module (rde features)

  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages base)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages music)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services)

  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde predicates)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features guile)
  #:use-module (rde features networking)
  #:use-module (rde features system)
  #:use-module (lotus-rde packages python-xyz)
  #:use-module (lotus-rde packages utils)
  #:use-module (lotus-rde home services builder)
  #:use-module (lotus-rde home services utils)
  #:use-module (lotus-rde lib utils)
  #:export (feature-lotus-nox-services
            feature-lotus-x-services
            feature-msteam
            feature-zoom
            feature-doc-publishing
            feature-bluetooth-auto-connect
            feature-power-monitor))





(define* (feature-lotus-nox-services
          #:key
          (polkit polkit)
          (mpd mpd)
          (znc znc)
          (jupyter jupyter)
          (bluez-autoconnect
           (local-file "/home/s/.bin/bluetooth-autoconnect"))
          (power-mon
           (local-file "/home/s/.bin/power-mon"))
          (usrhttpd rust-usrhttpd))

  (define (get-home-services config)
    (list
       ;; packages
       (simple-service
        'lotus-user-service-packages
        home-profile-service-type
        (list
         polkit
         mpd
         znc
         jupyter))

       ;; shepherd services
       (simple-service
        'lotus-user-shepherd-services
        home-shepherd-service-type

        (list


         ;; pkttyagent
         (shepherd-service
          (provision '(pkttyagent))
          (documentation "Run pkttyagent")
          (start
           #~(make-forkexec-constructor
              (list #$(file-append polkit
                                   "/bin/pkttyagent"))
              #:log-file #$(log-file "pkttyagent")))
          (stop #~(make-kill-destructor))
          (respawn? #t))


         ;; attnmgr
         (shepherd-service
           (provision '(attnmgr))
           (documentation "Attention manager")
           (start
            #~(make-forkexec-constructor
               (list #$(file-append python-attnmgr "/bin/attnmgr"))
               #:log-file #$(log-file "attnmgr")))
           (stop #~(make-kill-destructor))
           (respawn? #t))

         ;; udiskie - not required -- use home-udiskie-service-type (rde home services desktop)
         ;; geoclue-service-type is part of feature-desktop-services as system service
         ;; ssh-agent
         ;; home-gnupg-service-type
         ;; pulseaudio
         ;; pipewire;;
         ;; pipewire-pulse;;
         ;; wireplumber;;
         ;; emacs;;




         ;; mpd
         (shepherd-service
          (provision '(mpd))
          (documentation "Music Player Daemon")
          (start
           #~(make-forkexec-constructor
              (list #$(file-append mpd "/bin/mpd")
                    "--no-daemon"
                    (string-append (getenv "HOME")
                                   "/.config/mpd/mpd.conf"))
              #:log-file #$(log-file "mpd")))
          (stop #~(make-kill-destructor))
          (respawn? #t))



         ;; znc
         (shepherd-service
          (provision '(znc))
          (documentation "ZNC IRC bouncer")
          (start
           #~(make-forkexec-constructor
              (list #$(file-append znc "/bin/znc")
                    "-f")
              #:log-file #$(log-file "znc")))
          (stop #~(make-kill-destructor))
          (respawn? #t))



         ;; usrhttpd
         (shepherd-service
          (provision '(usrhttpd))
          (documentation "Simple user http server")
          (start #~(make-forkexec-constructor
                    (list #$(file-append usrhttpd "/bin/usrhttpd")
                          "-H"
                          "0.0.0.0"
                          (string-append (getenv "HOME")
                                         "/public_html/sites/default"))
                    #:log-file #$(log-file "usrhttpd")))
          (stop #~(make-kill-destructor))
          (respawn? #f))



         ;; jupyter
         (shepherd-service
          (provision '(jupyter))
          (documentation "Jupyter notebook server")
          (start
           #~(make-forkexec-constructor
              (list #$(file-append jupyter "/bin/jupyter")
                    "server"
                    "--no-browser"
                    "--ServerApp.quit_button=False"
                    "--ServerApp.base_url=/Documents/Compositions/Drafts/misc/jupyter/"
                    "--NotebookApp.token=mytoken"
                    (format #f
                            "--ServerApp.root_dir=~a/public_html/sites/default/Documents/Compositions/Drafts/misc/jupyter/"
                            (getenv "HOME")))
              #:log-file #$(log-file "jupyter")))
          (stop #~(make-kill-destructor))
          (respawn? #f))



         ;; keepawaken
         (shepherd-service
          (provision '(keepawaken))
          (documentation "Prevent suspend temporarily")
          (start
           #~(make-forkexec-constructor
              (list #$(file-append elogind "/bin/elogind-inhibit")
                    "sleep"
                    "1h")
              #:log-file #$(log-file "keepawaken")))
          (stop #~(make-kill-destructor))
          (respawn? #t))))))

  (feature
   (name 'lotus-nox-services)
   (home-services-getter get-home-services)))



(define* (feature-lotus-x-services
          #:key
          (conky conky)
          (eww eww)
          (keynav keynav)
          (xautolock xautolock)
          (autocutsel autocutsel)
          (picom picom)
          (dunst dunst)
          (ibus ibus)
          (gnome-keyring gnome-keyring)
          (blueman blueman)
          (pasystray pasystray)
          ;; (barrier barrier)
          (git git)
          (autossh autossh))


  (define* (mk/simple-service provision command
                              #:key
                              (respawn? #t)
                              (requirements '())
                              (one-shot? #f)
                              ;; (transient? #f)
                              (create-session? #f)
                              (documentation "")
                              (actions '()))

    (shepherd-service
      (provision provision)
      (documentation documentation)
      (requirement requirements)

      (start
       #~(make-forkexec-constructor
          #$command
          #:create-session? #$create-session?
          #:log-file #$(log-file
                        (symbol->string
                         (car provision)))))

      (stop #~(make-kill-destructor))

      (respawn? respawn?)
      (one-shot? one-shot?)
      ;; (transient? transient?)

      (actions actions)))

  (feature
   (name 'lotus-x-services)

   (home-services-getter
    (lambda (_)

      (list

       ;; packages
       (simple-service
        'lotus-shepherd-packages
        home-profile-service-type

        (list
         conky
         eww
         keynav
         xautolock
         autocutsel
         picom
         dunst
         ibus
         gnome-keyring
         blueman
         pasystray
         ;; barrier
         git
         autossh))




       ;; shepherd services
       (simple-service
        'lotus-user-services
        home-shepherd-service-type

        (list

         ;; redshift
         ;; polkit-gnome-agent -- polkit-wheel-service in feature-desktop system service should help
         ;; nm-applet -- nm-applet

         ;; 1 conky
         (mk/simple-service
          '(conky)
          #~(list #$(file-append conky "/bin/conky")
                  "-c"
                  (string-append (getenv "HOME")
                                 "/.conkyrc/main/conkyrc")))



         ;; 2 eww
         (mk/simple-service
          '(eww)
          #~(list #$(file-append eww "/bin/eww")
                  "daemon"
                  "--no-daemonize"))



         ;; 3 keynav
         (mk/simple-service
          '(keynav)
          #~(list #$(file-append keynav "/bin/keynav")))



         ;; 4 xautolock
         (shepherd-service
          (provision '(xautolock))
          (requirement '(xrdb))

          (start
           #~(make-forkexec-constructor
              (list #$(file-append xautolock "/bin/xautolock")
                    "-detectsleep"
                    "-resetsaver")
              #:log-file #$(log-file "xautolock")))

          (stop #~(make-kill-destructor))

          (respawn? #t)

          (actions
           (list

            (shepherd-action
             (name 'locknow)
             (documentation "Lock now")
             (procedure
              #~(lambda _
                  (system* #$(file-append xautolock
                                          "/bin/xautolock")
                           "-locknow"))))

            (shepherd-action
             (name 'vdisable)
             (documentation "Disable xautolock")
             (procedure
              #~(lambda _
                  (system* #$(file-append xautolock
                                          "/bin/xautolock")
                           "-disable"))))

            (shepherd-action
             (name 'venable)
             (documentation "Enable xautolock")
             (procedure
              #~(lambda _
                  (system* #$(file-append xautolock
                                          "/bin/xautolock")
                           "-enable")))))))


         ;; 5 autocutsel
         (mk/simple-service
          '(autocutsel)
          #~(list #$(file-append autocutsel
                                 "/bin/autocutsel")))



         ;; 6 picom/compton
         (mk/simple-service
          '(picom)
          #~(list #$(file-append picom "/bin/picom")))



         ;; 7 osdsh
         (mk/simple-service
          '(osdsh)
          #~(list "osdsh"))



         ;; 8 dunst
         (mk/simple-service
          '(dunst)
          #~(list
             #$(file-append dunst "/bin/dunst")))



         ;; 9 notification
         (mk/simple-service
          '(notification)
          #~(list (string-append (getenv "HOME")
                                 "/.guix-profile/libexec/notification")))



         ;; 10 ibus-portal
         (mk/simple-service
          '(ibus-portal)
          #~(list
             (string-append
              (getenv "HOME")
              "/.setup/guix-config/per-user/s/profiles/01-simple/profiles.d/profile/libexec/ibus-portal")))



         ;; 11 ibus-daemon
         (mk/simple-service
          '(ibus-daemon)
          #~(list #$(file-append ibus "/bin/ibus-daemon")))



         ;; 12 ibus-x11
         (mk/simple-service
          '(ibus-x11)
          #~(list (string-append (getenv "HOME")
                                 "/.setup/guix-config/per-user/s/profiles/01-simple/profiles.d/profile/libexec/ibus-x11")
                  "--kill-daemon"))



         ;; 13 gnome-keyring
         (mk/simple-service
          '(gnome-keyring)
          #~(list #$(file-append gnome-keyring
                                 "/bin/gnome-keyring-daemon")
                  "--start"
                  "--foreground"
                  "--components=secrets")
          #:respawn? #f)



         ;; 14 keepassxc
         (mk/simple-service
          '(keepassxc)
          #~(list "/run/privileged/bin/firejail"
                  "--noprofile"
                  "keepassxc"
                  "--minimized"
                  "--keyfile"
                  (string-append (getenv "HOME")
                                 "/.key.keyx")
                  (string-append (getenv "HOME")
                                 "/.db.kdbx"))
          #:requirements
          '(kpkeys))
            ;; secfs-orgp
            ;; xawaken-session-down
         ;; 15 blueman-applet
         (mk/simple-service
          '(blueman-applet)
          #~(list #$(file-append blueman
                                 "/bin/blueman-applet")))



         ;; 16 keymap
         (mk/simple-service
          '(keymap)
          #~(list #$(file-append xmodmap "/bin/xmodmap")
                  (string-append (getenv "HOME")
                                 "/.xmodmaprc"))
          #:respawn? #f
          #:one-shot? #t)



         ;; 17 xrdb
         (mk/simple-service
          '(xrdb)
          #~(list "sh" "-c" "m4 -I ~/.setup/m4 \
                 -I ~/.setup/osetup/lib/m4.d \
                 -I ~/.setup/osetup/info/common/m4.d \
                 -I ~/.setup/osetup/info/hosts/${HOST}/m4.d \
                 -I ~/.Xresources \
                 ~/.Xresources/init 2>/dev/null \
                 | xrdb -merge -")
          #:respawn? #f
          #:one-shot? #t)



         ;; 18 synclient
         (mk/simple-service
          '(synclient)
          #~(list "synclient"
                  "TapButton1=1")
          #:respawn? #f
          #:one-shot? #t)



         ;; 19 annex
         (mk/simple-service
          '(annex)
          #~(list #$(file-append git "/bin/git")
                  "annex"
                  "daemon"
                  "assistant")
          #:requirements
          '(keepassxc
            ssh-add)
            ;; xawaken-session-down
          #:respawn? #f)



         ;; 20 pwr-applet
         (mk/simple-service
          '(pwr-applet)
          #~(list (string-append (getenv "HOME")
                                 "/.bin/pwr-applet"))
          #:respawn? #f)



         ;; 21 logind-applet
         (mk/simple-service
          '(logind-applet)
          #~(list (string-append
                   (getenv "HOME")
                   "/.bin/logind-applet"))
          #:respawn? #f)



         ;; 22 pasystray
         (mk/simple-service
          '(pasystray)
          #~(list #$(file-append pasystray
                                 "/bin/pasystray")))

         ;; 23 deskflow-server
         (mk/simple-service
          '(deskflow-server)
          #~(list #$deskflow "/bin/deskflow-core"
                  "server"
                  "--no-daemon"
                  "--debug"
                  "DEBUG1"
                  "--name"
                  (or (getenv "HOST")
                      "host")
                  "--enable-crypto"
                  "--log"
                  (string-append
                   (getenv "HOME")
                   "/.logs/deskflow-server.log")
                  "--address"
                  "0.0.0.0:24800"
                  "--config"
                  (string-append
                   (getenv "HOME")
                   "/.config/Deskflow/deskflow-server.conf")
                  "--tls-cert"
                  (string-append
                   (getenv "HOME")
                   "/.config/Deskflow/tls/deskflow-server.pem"))
          #:requirements
          '();; xawaken-session-down
          #:respawn? #f)



         ;; 25 deskflow-client
         (mk/simple-service
          '(deskflow-client)
          #~(list #$deskflow "deskflow-core"
                  "client"
                  "--debug"
                  "DEBUG1"
                  "--sync-language"
                  "--name"
                  (or (getenv "HOST")
                      "host")
                  "--enable-crypto"
                  "--log"
                  (string-append
                   (getenv "HOME")
                   "/.logs/deskflow-client.log")
                  "--tls-cert"
                  (string-append
                   (getenv "HOME")
                   "/.config/Deskflow/tls/deskflow-client.pem")
                  "deskflow-server-host:24800")
          #:requirements
          '();; xawaken-session-down
          #:respawn? #f)



         ;; ;; 26 kpkeys
         ;; (mk/simple-service
         ;;  '(kpkeys)
         ;;  #~(list "sh"
         ;;          "-c"
         ;;          (string-append (getenv "HOME")
         ;;                         "/.bin/kpkeys -s co"))
         ;;  #:requirements
         ;;  '();; secfs-secure
         ;;    ;; xawaken-session-down
         ;;  #:respawn? #f)



         ;; ;; 27 ssh-add
         ;; (mk/simple-service
         ;;  '(ssh-add)
         ;;  #~(list "sh"
         ;;          "-c"
         ;;          (string-append (getenv "HOME")
         ;;                         "/.bin/ssh-add-key 4 5"))
         ;;  #:requirements
         ;;  '(ssh-agent
         ;;    keepassxc)
         ;;    ;; xawaken-session-down
         ;;  #:respawn? #f)



         ;; 28 proxy-fclient
         (mk/simple-service
          '(proxy-fclient)
          #~(list #$(file-append autossh
                                 "/bin/autossh")
                  "-N" "-S" "none" "-M" "20000"
                  "-o" "ControlMaster=no"
                  "-o" "ControlPath=/dev/null"
                  "-o" "ControlPersist=no"
                  "proxy-server-fclient")
          #:requirements
          '(ssh-add)
            ;; awaken-session-down
          #:respawn? #t)

         ;; 29 xdg-autostart
         (mk/simple-service
          '(xdg-autostart)
          #~(list "xdg-autostart")
          #:create-session? #t))))))))



(define* (feature-msteam)
  (define* (get-home-services config)
    (list
     (simple-service 'my-flatpak-apps
                     home-flatpak-service-type
                     (list
                      (home-flatpak-app-configuration
                       (name 'msteam)
                       (app  "com.github.IsmaelMartinez.teams_for_linux"))))))

  (feature
   (name 'msteam)
   (home-services-getter get-home-services)))


(define* (feature-zoom)
  (define* (get-home-services config)
    (list
     (simple-service 'my-flatpak-apps
                     home-flatpak-service-type
                     (list
                      (home-flatpak-app-configuration
                       (name 'zoom)
                       (app  "us.zoom.Zoom"))))))

  (feature
   (name 'zoom)
   (home-services-getter get-home-services)))


(define* (feature-doc-publishing)
  (define* (get-home-services config)
    (list
     (simple-service 'my-flatpak-apps
                     home-flatpak-service-type
                     (list
                      ;; (home-flatpak-app-configuration
                      ;;  (name 'pandoc)
                      ;;  (app  "io.github.jgm.pandoc"))

                      (home-flatpak-app-configuration
                       (name 'logseq)
                       (app  "com.logseq.Logseq.Locale"))

                      (home-flatpak-app-configuration
                       (name 'obsidian)
                       (app  "md.obsidian.Obsidian"))))))

  (feature
   (name 'doc-publishing)
   (home-services-getter get-home-services)))


(define (feature-bluetooth-auto-connect)

  (define (get-home-services config)
    (list
     (service
      home-bluetooth-auto-connect-service-type

      (home-bluetooth-auto-connect-configuration
       (verbose? #t)
       (daemon? #t)))))

  (feature
   (name 'bluetooth-auto-connect)
   (home-services-getter get-home-services)))





(define (feature-power-monitor)

  (define (get-home-services config)
    (list
     (service
      home-power-monitor-service-type
      (home-power-monitor-configuration
       (poll-interval 15)
       (notify-level 5)))))

  (feature
   (name 'power-monitor)
   (home-services-getter get-home-services)))



