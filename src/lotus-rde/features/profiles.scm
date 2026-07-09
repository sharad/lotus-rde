

(define-module (lotus-rde features profiles)
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
  #:use-module (lotus-rde home scoped-profiles)
  #:use-module (lotus-rde home services builder)
  #:use-module (lotus-rde home services transients)
  #:use-module (lotus-rde home services utils)
  #:use-module (lotus-rde lib utils)
  #:export (feature-extra-profile))




;; 01-crypto
(define home-crypto-profile-service-type
  (make-home-profile-service-type 'crypto 1))
;; 01-x
(define home-x-profile-service-type
  (make-home-profile-service-type 'x 1))
;; 71-sysdev
(define home-sysdev-profile-service-type
  (make-home-profile-service-type 'sysdev 71))
;; 60-lengthy
(define home-lengthy-profile-service-type
  (make-home-profile-service-type 'lengthy 60))
;; 01-simple
(define home-simple-profile-service-type
  (make-home-profile-service-type 'simple 1))
;; 90-heavy
(define home-heavy-profile-service-type
  (make-home-profile-service-type 'heavy 90))
;; 01-games
(define home-games-profile-service-type
  (make-home-profile-service-type 'games 1))
;; 02-java
(define home-java-profile-service-type
  (make-home-profile-service-type 'java 2))
;; 01-otools
(define home-otools-profile-service-type
  (make-home-profile-service-type 'otools 1))
;; 99-tmp
(define home-tmp-profile-service-type
  (make-home-profile-service-type 'tmp 99))
;; 01-console
(define home-console-profile-service-type
  (make-home-profile-service-type 'console 1))
;; 40-servers
(define home-servers-profile-service-type
  (make-home-profile-service-type 'servers 40))
;; 01-doc
(define home-doc-profile-service-type
  (make-home-profile-service-type 'doc 1))
;; 01-tools
(define home-tools-profile-service-type
  (make-home-profile-service-type 'tools 1))
;; 02-test
(define home-test-profile-service-type
  (make-home-profile-service-type 'test 2))
;; 99-failed
(define home-failed-profile-service-type
  (make-home-profile-service-type 'failed 99))
;; 01-dev
(define home-dev-profile-service-type
  (make-home-profile-service-type 'dev 1))
;; 01-text
(define home-text-profile-service-type
  (make-home-profile-service-type 'text 1))
;; 01-dynamic-hash
(define home-dynamic-hash-profile-service-type
  (make-home-profile-service-type 'dynamic-hash 1))
;; 01-net
(define home-net-profile-service-type
  (make-home-profile-service-type 'net 1))
;; 91-build-heavy
(define home-build-heavy-profile-service-type
  (make-home-profile-service-type 'build-heavy 91))
;; 01-essential
(define home-essential-profile-service-type
  (make-home-profile-service-type 'essential 1))
;; 01-emacs
(define home-emacs-profile-service-type
  (make-home-profile-service-type 'emacs 1))


(define* (feature-metal-common-profile)

  (define* (get-home-services config)
    (list

     (simple-service
      'metal-common-tmp
      home-tmp-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))

     (simple-service
      'metal-common-tools
      home-tools-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list "zk"
                                                 "dstask"
                                                 "rust-usrhttpd"
                                                 "xdg-desktop-portal-gtk"
                                                 "xdg-dbus-proxy"
                                                 "docker-cli"
                                                 "docker-compose"
                                                 "node-tiddlywiki"
                                                 "deskflow" ;; "barrier"
                                                 "refind"
                                                 "slscroll"
                                                 "tabbed"
                                                 "boxes"
                                                 "bool"
                                                 "beancount"
                                                 "ghq"
                                                 "gita"
                                                 "fzf"
                                                 "bc"
                                                 "gnome-calculator"
                                                 "nushell"
                                                 "rlwrap"
                                                 "parted"
                                                 "gparted"
                                                 "netcat-openbsd"

                                                 "xvkbd"
                                                 "svkbd"

                                                 "lsix"
                                                 "mazo"
                                                 "meld"

                                                 "nerd-dictation"
                                                 "recoll"
                                                 "recoll-cli"
                                                 "showmethekey"

                                                 "xhost"
                                                 "xauth"
                                                 "xkill"
                                                 "mosh"
                                                 "autossh"
                                                 "flatpak"
                                                 "jq"
                                                 ;; "conda" ;; break
                                                 ;; "weasyprint"
                                                 "python-pyflakes"
                                                 "python-flake8"
                                                 "python-fire"
                                                 "python-pikepdf" ;; break
                                                 "python-wrapper"
                                                 "python-xq"
                                                 "python-yq"
                                                 "python-importmagic"
                                                 "python-epc"
                                                 "python-sexpdata"
                                                 ;; "python-tinydb"
                                                 "python-dbus"
                                                 "python-pikepdf"
                                                 "python-gitlab"
                                                 "python-gtts"
                                                 ;; these below two are not command, but library use them in some separate profile like 01-python/profile.d/profile
                                                 ;; "python-pygobject"
                                                 ;; "python-gst"
                                                 "python-pyaudio"
                                                 ;; "python-playsound"
                                                 "python-pyttsx3"
                                                 "python-speechrecognition"

                                                 "rofi"
                                                 "python-rofi"
                                                 "python-rofi-menu"
                                                 "python-paramiko"
                                                 "python-scp"
                                                 ;; "rofi-master"
                                                 "python-attnmgr"
                                                 "python-secretstorage"

                                                 "enscript"

                                                 ;; "jupyter"
                                                 "python-git-review"

                                                 "wget"
                                                 "xmlstarlet"
                                                 "libxml2"
                                                 "libxslt"
                                                 "qtxmlpatterns"                 ;xquery

                                                 "atool"
                                                 "sshpass"

                                                 "shellcheck"

                                                 "cups-minimal" ;; for lp lpr command

                                                 "python-rofi-tmux"

                                                 "lsof"

                                                 "unzip"
                                                 "zip"
                                                 "cpio"

                                                 "poppler"
                                                 "whois"
                                                 "pwgen"
                                                 ;; "gettext"

                                                 ;; "visidata"

                                                 "baobab"
                                                 "ncdu"
                                                 "catdoc"
                                                 "pinfo"



                                                 "vmware-open-vm-tools"

                                                 "h2c"
                                                 ;; "h-client"
                                                 "electron-cash"
                                                 "date2name"
                                                 ;; xdiskusage
                                                 "ncftp"
                                                 "lftp"
                                                 "bitwise"
                                                 "nss"
                                                 "nss:bin"
                                                 "gnutls"
                                                 "p11-kit"
                                                 "beep"
                                                 "nxbelld"
                                                 "chrpath"
                                                 "dtach"

                                                 "imagemagick"
                                                 "recordmydesktop"
                                                 "gifsicle"
                                                 "scrot"
                                                 "espeak"
                                                 "espeak-ng"

                                                 "ffmpeg-normalize"
                                                 "rsync"
                                                 "v4l-utils"
                                                 "guvcview"
                                                 "photoflare"
                                                 "kmonad"
                                                 "usb-modeswitch")))))

     (simple-service
      'metal-common-dev
      home-dev-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))

     (simple-service
      'metal-common-net
      home-net-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))

     (simple-service
      'metal-common-x
      home-x-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))))

  (feature
   (name 'metal-common-profile)
   (home-services-getter get-home-services)))

