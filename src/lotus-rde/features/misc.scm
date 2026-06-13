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
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages mpd)
  #:use-module (gnu packages jupyter)
  #:use-module (gnu packages monitoring)
  #:use-module (gnu packages compton)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages gnupg)
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
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services)

  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde predicates)
  #:use-module (rde home services emacs)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features guile)
  #:use-module (rde features networking)
  #:use-module (rde features system)
  #:use-module (lotus-rde packages python-xyz)
  #:use-module (lotus-rde packages utils)
  #:use-module (lotus-rde home services builder)
  #:use-module (lotus-rde home services transients)
  #:use-module (lotus-rde home services utils)
  #:use-module (lotus-rde lib utils)
  #:export (feature-lotus-nox-services
            feature-lotus-x-services
            feature-lotus-nox-group-services
            feature-lotus-x-group-services
            feature-msteam
            feature-zoom
            feature-doc-publishing
            feature-bluetooth-autoconnect
            feature-power-monitor
            feature-git-annex-daemon
            feature-ssh-transient))





(define* (feature-lotus-nox-services
          #:key
          (emacs emacs)
          (openssh openssh-sans-x)
          (gnupg gnupg)
          (polkit polkit)
          (mpd mpd)
          (znc znc)
          (jupyter jupyter)
          (usrhttpd rust-usrhttpd))
  (define (get-home-services config)
    (list
       ;; packages
       (simple-service
        'lotus-user-service-packages
        home-profile-service-type
        (list emacs
              polkit
              mpd
              znc
              jupyter))

       ;; (service
       ;;  home-emacs-service-type
       ;;  (home-emacs-configuration
       ;;   (emacs-servers '(spacemacs))))

       ;; shepherd services
       (simple-service
        'lotus-user-shepherd-services
        home-shepherd-service-type

        (list
         (shepherd-service
          (provision '(emacs-lotus))
          (start #~(let* ((make-env (lambda (name value)
                                      (string-append name "=" value)))
                          (server "spacemacs")
                          (env (default-environment-variables))
                          (xdg-runtime-dir (getenv "XDG_RUNTIME_DIR"))
                          (emacs-runtime-dir (if (and xdg-runtime-dir
                                                      (file-exists? xdg-runtime-dir))
                                                 (string-append xdg-runtime-dir
                                                                "/emacs")
                                                 (string-append (getenv "HOME")
                                                                "/.emacs.d")))
                          (emacs-runtime-dir-server (string-append emacs-runtime-dir
                                                                   "/server"))
                          (emacs-envs (list (make-env "EMACS_SERVER_HOST" "0.0.0.0")
                                            (make-env "EMACS_RUNTIME_DIR" emacs-runtime-dir)
                                            (make-env "EMACS_SERVER_AUTH_DIR" emacs-runtime-dir-server)
                                            (make-env "EMACS_SERVER_SOCKET_DIR" emacs-runtime-dir-server)
                                            (make-env "EMACS_SERVER_DIR" emacs-runtime-dir-server))))
                     (make-forkexec-constructor (list #$(file-append emacs "/bin/emacs") (format #f "--fg-daemon=~a" server))
                                                #:log-file
                                                #$(log-file "emacs")
                                                #:environment-variables (append emacs-envs
                                                                                env))))
          (stop #~(let* ((xdg-runtime-dir (getenv "XDG_RUNTIME_DIR"))
                         (server "spacemacs")
                         (emacs-runtime-dir (if (and xdg-runtime-dir
                                                     (file-exists? xdg-runtime-dir))
                                                (string-append xdg-runtime-dir
                                                               "/emacs")
                                                (string-append (getenv "HOME")
                                                                      "/.emacs.d")))
                         (server-dir (string-append emacs-runtime-dir
                                                           "/server"))
                         (make-cmd-destructor #$make-cmd-destructor-gexp))
                    (make-cmd-destructor (format #f "emacsclient -f ~a --eval \"(kill-emacs)\" >> ~a 2>&1"
                                                 (string-append server-dir "/" server)
                                                 #$(log-file "emacs")))))
          (respawn? #f))
         (shepherd-service
          (provision '(ssh-agent))
          (requirement '())
          (respawn? #f)
          (start #~(lambda args
                     (let* ((uid (number->string (passwd:uid (getpwuid (getlogin)))))
                            (rundir (string-append "/run/user/"
                                                   uid))
                            (auth-sock-envar (or (getenv "SSH_AUTH_SOCK")
                                                 ""))
                            (auth-sock-default-envar (or (getenv "SSH_AUTH_SOCK_DEFAULT") ""))
                            (auth-sock (cond
                                        ((not (string-null?
                                               auth-sock-envar))
                                         auth-sock-envar)
                                        ((not (string-null?
                                               auth-sock-default-envar))
                                         auth-sock-default-envar)
                                        (else
                                         (string-append rundir "/keyring/ssh"))))
                            (constructor (make-forkexec-constructor
                                          (list #$(file-append openssh "/bin/ssh-agent") "-D" "-a" auth-sock)
                                          #:log-file
                                          #$(log-file "ssh-agent"))))
                       (lambda ( . args)
                         (when auth-sock
                           (let ((auth-sock-dir (dirname auth-sock)))
                             (unless (file-exists? auth-sock-dir)
                               (mkdir auth-sock-dir))))
                         (apply constructor args)))))
          (stop #~(make-kill-destructor))
          (actions
           (list
            (shepherd-action
             (name 'clear)
             (documentation "Clear ssh agent keys.")
             (procedure
              #~(lambda (running . args)
                  (let* ((port (open-pipe* OPEN_READ #$(file-append openssh "/bin/ssh-add") "-D"))
                         (output (read-string port)))
                    (close-pipe port)
                    (display output)))))
            (shepherd-action
             (name 'ls)
             (documentation "List ssh agent keys.")
             (procedure
              #~(lambda (running . args)
                  (let* ((port (open-pipe* OPEN_READ #$(file-append openssh "/bin/ssh-add") "-l"))
                         (output (read-string port)))
                    (close-pipe port)
                    (display output)))))
            (shepherd-action
             (name 'lock)
             (documentation "Lock ssh agent.")
             (procedure
              #~(lambda (running . args)
                  (system (string-append #$(file-append xterm "/bin/xterm") "-e '" #$(file-append openssh "/bin/ssh-add") " -x'")))))
            (shepherd-action
             (name 'unlock)
             (documentation "Unlock ssh agent.")
             (procedure
              #~(lambda (running . args)
                  (system (string-append #$(file-append xterm "/bin/xterm") "-e '" #$(file-append openssh "/bin/ssh-add") " -X'"))))))))
         (shepherd-service
          (provision '(gpg-agent))
          (respawn? #t)
          (start #~(lambda args
                     (let* ((uid (number->string (passwd:uid (getpwuid (getlogin)))))
                            (rundir (string-append "/run/user/" uid "/"))
                            (homedir (getenv "HOME"))
                            (gpg-homedir (string-append homedir "/.gnupg"))
                            (gpg-rundir (string-append rundir "gnupg/"))
                            (constructor (make-system-constructor (string-append #$(file-append gnupg "/bin/gpg-agent")
                                                                                 " --homedir "
                                                                                 gpg-homedir
                                                                                 " --use-standard-socket --daemon"
                                                                                 " >> "
                                                                                 #$(log-file "gpg-agent")
                                                                                 " 2>&1"))))
                       (unless (file-exists? rundir)
                         (mkdir rundir))
                       constructor)))
          (stop #~(make-system-destructor (string-append #$(file-append gnupg "gpgconf") " --kill all >> "
                                                         #$(log-file "gpg-agent")
                                                         " 2>&1 ")))
          (actions
           (list
            (shepherd-action
             (name 'clear)
             (documentation "Clear gpg agent cache.")
             (procedure
              #~(lambda (running . args)
                  "Clear gpg agent cache."
                  (format #t "Clearing gpg agent cache\n")
                  (fork+exec-command (list #$(file-append gnupg "gpg-connect-agent")
                                           "reloadagent"
                                           "/bye")
                                     #:log-file (log-file "gpg-agent")))))
            (shepherd-action
             (name 'lscomp)
             (documentation "List gpg components.")
             (procedure
              #~(lambda (running . args)
                  (let* ((port (open-pipe* OPEN_READ #$(file-append gnupg "gpgconf") "--list-components"))
                         (output (read-string port)))
                    (close-pipe port)
                    (display output)))))
            (shepherd-action
             (name 'config-agent)
             (documentation "Show gpg agent config.")
             (procedure
              #~(lambda (running . args)
                  (let* ((port (open-pipe* OPEN_READ #$(file-append gnupg "gpgconf") "--list-options" "gpg-agent"))
                         (output (read-string port)))
                    (close-pipe port)
                    (display output)))))
            (shepherd-action
             (name 'config-gpg)
             (documentation "Show gpg config.")
             (procedure
              #~(lambda (running . args)
                  (let* ((port (open-pipe* OPEN_READ #$(file-append gnupg "gpgconf") "--list-options" "gpg"))
                         (output (read-string port)))
                    (close-pipe port)
                    (display output)))))
            (shepherd-action
             (name 'ls)
             (documentation "List gpg keys.")
             (procedure
              #~(lambda (running . args)
                  (let* ((port (open-pipe* OPEN_READ #$(file-append gnupg "gpg-connect-agent") "keyinfo" "--list" "/bye"))
                         (output (read-string port)))
                    (close-pipe port)
                    (display output)))))
            (shepherd-action
             (name 'list)
             (documentation "List gpg secret keys with keygrip.")
             (procedure
              #~(lambda (running . args)
                  (let* ((port (open-pipe* OPEN_READ #$(file-append gnupg "gpg") "--list-secret-keys" "--with-keygrip"))
                         (output (read-string port)))
                    (close-pipe port)
                    (display output)))))
            (shepherd-action
             (name 'reload)
             (documentation "Reload gpg agent config.")
             (procedure
              #~(lambda (running . args)
                  "Reload gpg agent config."
                  (format #t "Reloading gpg agent\n")
                  (fork+exec-command (list #$(file-append gnupg "gpgconf") "--reload" "gpg-agent")
                                     #:log-file #$(log-file "gpg-agent"))))))))
         ;; pkttyagent
         (shepherd-service
          (provision '(pkttyagent))
          (documentation "Run pkttyagent")
          (auto-start? #f)
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
           (auto-start? #f)
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
          (auto-start? #f)
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
          (auto-start? #f)
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
          (auto-start? #f)
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
          (auto-start? #f)
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
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append elogind "/bin/elogind-inhibit")
                    "sleep"
                    "1h")
              #:log-file #$(log-file "keepawaken")))
          (stop #~(make-kill-destructor))
          (respawn? #t))))))
  (feature
   (values `(
             (shepherd-emacs-lotus emacs-lotus)
             (shepherd-ssh-agent ssh-agent)
             (shepherd-gpg-agent gpg-agent)
             (shepherd-pkttyagent pkttyagent)
             (shepherd-attnmgr attnmgr)
             (shepherd-mpd mpd)
             (shepherd-znc znc)
             (shepherd-jupyter jupyter)
             (shepherd-usrhttpd usrhttpd)
             (shepherd-keepawaken keepawaken)))
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

  (define (get-home-services config)
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
         keepassxc
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
         (shepherd-service
          (provision '(conky))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append conky "/bin/conky")
                    "-c"
                    (string-append (getenv "HOME")
                                   "/.conkyrc/main/conkyrc"))
              #:create-session? #f
              #:log-file #$(log-file
                            (symbol->string
                             (car provision)))))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 2 eww
         (shepherd-service
          (provision '(eww))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append eww "/bin/eww")
                    "daemon"
                    "--no-daemonize")
              #:create-session? #f
              #:log-file #$(log-file "eww")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 3 keynav
         (shepherd-service
          (provision '(keynav))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append keynav "/bin/keynav"))
              #:create-session? #f
              #:log-file #$(log-file "keynav")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))


         ;; 4 xautolock
         (shepherd-service
          (provision '(xautolock))
          (requirement '(xrdb))
          (auto-start? #f)
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
         (shepherd-service
          (provision '(autocutsel))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append autocutsel
                                   "/bin/autocutsel"))
              #:create-session? #f
              #:log-file #$(log-file "autocutsel")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 6 picom/compton
         (shepherd-service
          (provision '(picom))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append picom "/bin/picom"))
              #:create-session? #f
              #:log-file #$(log-file "picom")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 7 osdsh
         (shepherd-service
          (provision '(osdsh))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list "osdsh")
              #:create-session? #f
              #:log-file #$(log-file "osdsh")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 8 dunst
         (shepherd-service
          (provision '(dunst))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list
               #$(file-append dunst "/bin/dunst"))
              #:create-session? #f
              #:log-file #$(log-file "dunst")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 9 notification
         (shepherd-service
          (provision '(notification))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append notification-daemon "/libexec/notification-daemon"))
              #:create-session? #f
              #:log-file #$(log-file "notification")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 10 ibus-portal
         (shepherd-service
          (provision '(ibus-portal))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append ibus "/libexec/ibus-portal"))
              #:create-session? #f
              #:log-file #$(log-file "ibus-portal")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 11 ibus-daemon
         (shepherd-service
          (provision '(ibus-daemon))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append ibus "/bin/ibus-daemon"))
              #:create-session? #f
              #:log-file #$(log-file "ibus-daemon")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 12 ibus-x11
         (shepherd-service
          (provision '(ibus-x11))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append ibus "/libexec/ibus-x11")
                    "--kill-daemon")
              #:create-session? #f
              #:log-file #$(log-file "ibus-x11")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 13 gnome-keyring
         (shepherd-service
          (provision '(gnome-keyring))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append gnome-keyring
                                   "/bin/gnome-keyring-daemon")
                    "--start"
                    "--foreground"
                    "--components=secrets")
              #:create-session? #f
              #:log-file #$(log-file "gnome-keyring")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 14 keepassxc
         (shepherd-service
          (provision '(keepassxc))
          (documentation "")
          (requirement '(kpkey
                         secfs-orgp
                         ;; secfs-secure
                         ;; secfs
                         xawaken-session-down))
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list "/run/privileged/bin/firejail"
                    "--noprofile"
                    #$(file-append keepassxc "/bin/keepassxc")
                    "--minimized"
                    "--keyfile"
                    (string-append (getenv "HOME")
                                   "/.key.keyx")
                    (string-append (getenv "HOME")
                                   "/.db.kdbx"))
              #:create-session? #f
              #:log-file #$(log-file "keepassxc")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))
         ;; 15 blueman-applet
         (shepherd-service
          (provision '(blueman-applet))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append blueman
                                   "/bin/blueman-applet"))
              #:create-session? #f
              #:log-file #$(log-file "blueman-applet")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 16 keymap
         (shepherd-service
          (provision '(keymap))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append xmodmap "/bin/xmodmap")
                    (string-append (getenv "HOME")
                                   "/.xmodmaprc"))
              #:create-session? #f
              #:log-file #$(log-file "keymap")))
          (stop #~(make-kill-destructor))
          (respawn? #f)
          (one-shot? #t))

         ;; 17 xrdb
         (shepherd-service
          (provision '(xrdb))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list "sh" "-c" "m4 -I ~/.setup/m4 \
                 -I ~/.setup/osetup/lib/m4.d \
                 -I ~/.setup/osetup/info/common/m4.d \
                 -I ~/.setup/osetup/info/hosts/${HOST}/m4.d \
                 -I ~/.Xresources \
                 ~/.Xresources/init 2>/dev/null \
                 | xrdb -merge -")
              #:create-session? #f
              #:log-file #$(log-file "")))
          (stop #~(make-kill-destructor))
          (respawn? #f)
          (one-shot? #t))

         ;; 18 synclient
         (shepherd-service
          (provision '(synclient))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list "synclient"
                    "TapButton1=1")
              #:create-session? #f
              #:log-file #$(log-file "synclient")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 20 pwr-applet
         (shepherd-service
          (provision '(pwr-applet))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list (string-append (getenv "HOME")
                                   "/.bin/pwr-applet"))
              #:create-session? #f
              #:log-file #$(log-file "pwr-applet")))
          (stop #~(make-kill-destructor))
          (respawn? #f)
          (one-shot? #f))

         ;; 21 logind-applet
         (shepherd-service
          (provision '(logind-applet))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list (string-append
                     (getenv "HOME")
                     "/.bin/logind-applet"))
              #:create-session? #f
              #:log-file #$(log-file "logind-applet")))
          (stop #~(make-kill-destructor))
          (respawn? #f)
          (one-shot? #f))

         ;; 22 pasystray
         (shepherd-service
          (provision '(pasystray))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list #$(file-append pasystray
                                   "/bin/pasystray"))
              #:create-session? #f
              #:log-file #$(log-file "pasystray")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))

         ;; 23 deskflow-server
         (let ((cmd (file-append deskflow "/bin/deskflow-core"))
               (mode "server")
               (ip  "0.0.0.0")
               (port "24800"))
             (shepherd-service
              (provision '(deskflow-server))
              (auto-start? #f)
              (start    #~(make-forkexec-constructor (list #$cmd #$mode "--no-daemon"
                                                           ;; "--debug" "INFO"
                                                           "--debug" "DEBUG1"
                                                           "--name" (or (getenv "HOST") "host")
                                                           "--enable-crypto"
                                                           "--log" #$(log-file "deskflow-server")
                                                           "--address" (string-append #$ip ":" #$port)
                                                           "--config" (string-append (getenv "HOME") "/.config/Deskflow/deskflow-server.conf")
                                                           "--tls-cert" (string-append (getenv "HOME") "/.config/Deskflow/tls/deskflow-server.pem"))
                                                     #:create-session? #f
                                                     #:log-file #$(log-file "deskflow-server")))
              (stop     #~(make-kill-destructor))
              (respawn? #f)
              (respawn-delay 600)
              (respawn-limit 1)
              (requirement '(xawaken-session-down))))

         ;; 25 deskflow-client
         (let ((cmd (file-append deskflow "/bin/deskflow-core"))
               (mode "client")
               (server  "deskflow-server-host")
               (port "24800"))
             (shepherd-service
              (provision '(deskflow-client))
              (auto-start? #f)
              (start #~(lambda ( . args)
                            (let* ((server (if (pair? args)
                                               (car args)
                                               #$server))
                                   (log-file   #$log-file-gexp)
                                   (log-file-loc (string-append "desklow-client" "-" server))
                                   (constructor (make-forkexec-constructor (list cmd mode "-f"
                                                                                 ;; "--debug" "INFO"
                                                                                 "--debug" "DEBUG1"
                                                                                 "--sync-language"
                                                                                 "--name" (getenv "HOST")
                                                                                 "--enable-crypto"
                                                                                 "--log" (log-file log-file-loc)
                                                                                 ;; "--address" (string-append ip ":" port)
                                                                                 ;; "-c" (string-append (getenv "HOME") "/.config/Deskflow/deskflow-client.conf")
                                                                                 "--tls-cert" (string-append (getenv "HOME") "/.config/Deskflow/tls/deskflow-client.pem")
                                                                                 (string-append server ":" #$port))
                                                                           #:create-session? #f
                                                                           #:log-file (log-file log-file-loc))))
                              (apply constructor args))))
              (stop  #~(make-kill-destructor))
              (respawn? #f)
              (respawn-delay 600)
              (respawn-limit 1)
              (requirement '(xawaken-session-down))))

         ;; 28 proxy-fclient
         (let ((cmd (file-append autossh "/bin/autossh"))
               (server (car '("proxy-server-fclient"
                              "proxy-server-fclient-linux"
                              "proxy-server-fclient-window"))))
          (shepherd-service
           (provision '(proxy-fclient))
           (documentation "proxy-fclient")
           (requirement '(ssh-add
                          awaken-session-down))
           (auto-start? #f)
           (start
            #~(lambda ( . args)
                      (let* ((server (if (pair? args)
                                         (car args)
                                         #$server))
                             (log-file   #$log-file-gexp)
                             (log-file-loc (string-append "proxy-" server))
                             (constructor (make-forkexec-constructor (list #$cmd "-N"
                                                                           "-S" "none"
                                                                           "-M" "20000"
                                                                           "-o" "ControlMaster=no"
                                                                           "-o" "ControlPath=/dev/null"
                                                                           "-o" "ControlPersist=no"
                                                                           server)
                                                                     #:create-session? #f
                                                                     #:log-file (log-file log-file-loc))))
                        (apply constructor args))))
           (stop #~(make-kill-destructor))
           (respawn? #t)
           (one-shot? #f)
           ;; (transient? transient?)
           (actions '())))

         ;; 29 xdg-autostart
         (shepherd-service
          (provision '(xdg-autostart))
          (documentation "")
          (requirement '())
          (auto-start? #f)
          (start
           #~(make-forkexec-constructor
              (list "xdg-autostart")
              #:create-session? #t
              #:log-file #$(log-file "xdg-autostart")))
          (stop #~(make-kill-destructor))
          (respawn? #t)
          (one-shot? #f))))))

  (feature
   (name 'lotus-x-services)
   (values `((shepherd-conky conky)
             (shepherd-eww eww)
             (shepherd-keynav keynav)
             (shepherd-xautolock xautolock)
             (shepherd-autocutsel autocutsel)
             (shepherd-picom picom)
             (shepherd-dunst dunst)
             (shepherd-ibus ibus)
             (shepherd-blueman blueman)
             (shepherd-autossh autossh)
             (shepherd-osdsh osdsh)
             (shepherd-notification notification)
             (shepherd-ibus-portal ibus-portal)
             (shepherd-ibus-daemon ibus-daemon)
             (shepherd-ibus-x11 ibus-x11)
             (shepherd-gnome-keyring gnome-keyring)
             (shepherd-keepassxc keepassxc)
             (shepherd-keymap keymap)
             (shepherd-xrdb xrdb)
             (shepherd-synclient synclient)
             (shepherd-pwr-applet pwr-applet)
             (shepherd-logind-applet logind-applet)
             (shepherd-pasystray pasystray)
             (shepherd-deskflow-server deskflow-server)
             (shepherd-deskflow-client deskflow-client)
             (shepherd-proxy-fclient proxy-fclient)
             (shepherd-xdg-autostart xdg-autostart)))
   (home-services-getter get-home-services)))





(define (get-active-requirements config requirements)
  (filter (lambda (req)
            (let ((shepherd-req (string->symbol (string-append "shepherd-" (symbol->string req)))))
              (get-value shepherd-req config #f)))
          requirements))


(define* (feature-lotus-nox-group-services)

  (define (get-home-services config)
    (let ((awaken-requirements '(attnmgr
                                 secfs
                                 xawaken-session-down))
          (delayed-requirements '(awaken-session
                                  xdelayed-login-session-down))
          (login-requirements '(mcron
                                pkttyagent
                                ;; attnmgr
                                bluez-autoconnect
                                power-mon
                                udiskie
                                geoclue
                                mpd
                                ssh-agent
                                gpg-agent
                                ;; pulseaudio
                                pipewire
                                pipewire-pulse
                                wireplumber
                                znc
                                emacs-lotus
                                usrhttpd
                                ;; jupyter
                                ;; keepawaken
                                awaken-session
                                delayed-login-session)))
      (list
       ;; shepherd services
       (simple-service 'tty-service-groups
                       home-services-group-service-type
                       (list
                        (home-services-group-configuration
                         (name 'awaken-session)
                         (dependent '(xawaken-session-down
                                      delayed-login-session-down))
                         (requirement (get-active-requirements config awaken-requirements)))

                        (home-services-group-configuration
                         (name 'delayed-login-session)
                         (dependent '(xdelayed-login-session-down))
                         (requirement (get-active-requirements config delayed-requirements)))))
       (simple-service
        'login-services
        home-shepherd-service-type
        (list
         (shepherd-service
           (provision '(login))
           (start #~(make-system-constructor "echo started login-service"))
           ;; #:stop     (make-kill-destructor)
           (respawn? #f)
           (auto-start? #f)
           (one-shot? #t)
           (requirement (get-active-requirements config login-requirements))))))))

  (feature
   (values `((shepherd-awaken-session awaken-session)
             (shepherd-delayed-login-session delayed-login-session)
             (shepherd-login login)))
   (name 'lotus-nox-group-services)
   (home-services-getter get-home-services)))




(define* (feature-lotus-x-group-services)
  (define (get-home-services config)
    (let ((xawaken-requirements '(proxy-fclient
                                  deskflow-server ;; barrier
                                  annex
                                  kpkey
                                  ssh-add
                                  keepassxc
                                  awaken-session
                                  xdelayed-login-session-down))
          (xdelayed-requirements '(xawaken-session
                                   delayed-login-session))
          (xlogin-requirements '(attnmgr
                                 autocutsel
                                 dunst
                                 ;; emacs
                                 keymap
                                 keynav
                                 redshift
                                 synclient
                                 xrdb
                                 xautolock
                                 deskflow-server))
          (wmlogin-requirements '( ;; redshift
                                  ;; polkit-gnome-agent
                                  conky
                                  eww
                                  keynav
                                  xautolock
                                  autocutsel
                                  ;; compton
                                  ;; osdsh
                                  dunst
                                  notification
                                  ;; gnome-keyring
                                  nm-applet
                                  blueman-applet
                                  ibus-portal
                                  ibus-daemon
                                  ibus-x11
                                  keymap
                                  xrdb
                                  synclient
                                  ;; annex
                                  ;; keepassxc
                                  pwr-applet
                                  logind-applet
                                  pasystray
                                  ;; deskflow-server ;; barrier
                                  ;; deskflow-client
                                  ;; kpkey
                                  ;; ssh-add
                                  ;; proxy-fclient
                                  ;; logseq
                                  ;; msteam
                                  ;; obsidian
                                  ;; zoom
                                  xdg-autostart
                                  xawaken-session
                                  xdelayed-login-session
                                  login-service)))
      (list
       (simple-service 'x-service-groups
                       home-services-group-service-type
                       (list
                        (home-services-group-configuration
                         (name 'xawaken-session)
                         (dependent '(xdelayed-login-session-down))
                         (requirement (get-active-requirements config xawaken-requirements)))

                        (home-services-group-configuration
                         (name 'xdelayed-login-session)
                         (requirement xdelayed-requirements))))

       (simple-service
        'xlogin-services
        home-shepherd-service-type
        (list
         ;; shepherd services
         (shepherd-service
           (provision '(xlogin))
           (start #~(make-system-constructor "echo started xlogin-service"))
           ;; #:stop     (make-kill-destructor)
           (respawn? #f)
           (auto-start? #f)
           (one-shot? #t)
           (requirement (get-active-requirements config xlogin-requirements)))
         (shepherd-service
           (provision '(wmlogin))
           (start #~(make-system-constructor "echo started wmlogin-service"))
            ;; #:stop     (make-kill-destructor)
           (respawn? #f)
           (auto-start? #f)
           (one-shot? #t)
           (requirement (get-active-requirements config wmlogin-requirements))))))))

  (feature
   (values `((shepherd-xawaken-session awaken-session)
             (shepherd-xdelayed-login-session xdelayed-login-session)
             (shepherd-xlogin xlogin)
             (shepherd-wmlogin wmlogin)))
   (name 'lotus-x-group-services)
   (home-services-getter get-home-services)))



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
   (values `((shepherd-msteam msteam)))
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
   (values `((shepherd-zoom zoom)))
   (name 'zoom)
   (home-services-getter get-home-services)))


(define* (feature-doc-publishing #:key
                                 (pandoc #f)
                                 (logseq #t)
                                 (obsidian #t))
  (define* (get-home-services config)
    (list
     (simple-service 'my-flatpak-apps
                     home-flatpak-service-type
                     (filter home-flatpak-app-configuration?
                             (list
                              (when pandoc
                                (home-flatpak-app-configuration
                                 (name 'pandoc)
                                 (app  "io.github.jgm.pandoc")))

                              (when logseq
                                (home-flatpak-app-configuration
                                 (name 'logseq)
                                 (app  "com.logseq.Logseq.Locale")))

                              (when obsidian
                                (home-flatpak-app-configuration
                                 (name 'obsidian)
                                 (app  "md.obsidian.Obsidian"))))))))
  (feature
   (values `((shepherd-pandoc ,(when pandoc 'pandoc))
             (shepherd-logseq ,(when logseq 'logseq))
             (shepherd-obsidian ,(when obsidian 'obsidian))))
   (name 'doc-publishing)
   (home-services-getter get-home-services)))


(define (feature-bluetooth-autoconnect)

  (define (get-home-services config)
    home-bluetooth-autoconnect-service)

  (feature
   (values `((shepherd-bluez-autoconnect bluez-autoconnect)))
   (name 'bluetooth-autoconnect)
   (home-services-getter get-home-services)))





(define (feature-power-monitor)

  (define (get-home-services config)
    home-power-monitor-service)

  (feature
   (values `((shepherd-power-monitor power-monitor)))
   (name 'power-monitor)
   (home-services-getter get-home-services)))



(define (feature-git-annex-daemon)

  (define (get-home-services config)
    home-git-annex-daemon-service)

  (feature
   (values `((shepherd-git-annex git-annex)))
   (name 'annex)
   (home-services-getter get-home-services)))



(define* (feature-ssh-transient)
  (define (get-home-services config)
    (list
     (service home-ssh-tunnel-service-type)
     (service home-autossh-tunnel-service-type)
     (service home-ssh-gpg-tunnel-service-type)))
  (feature
   (values `((shepherd-ssh-tunnel ssh-tunnel)
             (shepherd-autossh-tunnel autossh-tunnel)
             (shepherd-ssh-gpg-tunnel ssh-gpg-tunnel)))
   (name 'ssh-transient)
   (home-services-getter get-home-services)))

