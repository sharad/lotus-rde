

(define-module (lotus-rde features profiles metal-common)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (rde system services admin)
  #:use-module (lotus-rde features profiles)
  #:export (feature-metal-common-profile))



(define* (feature-metal-common-profile)

  (define* (get-home-services config)
    (list
     ;; 01-doc
     (simple-service
      'metal-common-doc
      home-doc-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-tools
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
     ;; 01-crypto
     (simple-service
      'metal-common-crypto
      home-crypto-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-x
     (simple-service
      'metal-common-x
      home-x-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-dev
     (simple-service
      'metal-common-dev
      home-dev-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-text
     (simple-service
      'metal-common-text
      home-text-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-dynamic-hash
     (simple-service
      'metal-common-dynamic-hash
      home-dynamic-hash-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-net
     (simple-service
      'metal-common-net
      home-net-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 91-build-heavy
     (simple-service
      'metal-common-build-heavy
      home-build-heavy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-essential
     (simple-service
      'metal-common-essential
      home-essential-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-emacs
     (simple-service
      'metal-common-emacs
      home-emacs-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 71-sysdev
     (simple-service
      'metal-common-sysdev
      home-sysdev-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 60-lengthy
     (simple-service
      'metal-common-lengthy
      home-lengthy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-simple
     (simple-service
      'metal-common-simple
      home-simple-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-console
     (simple-service
      'metal-common-console
      home-console-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 90-heavy
     (simple-service
      'metal-common-heavy
      home-heavy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 40-servers
     (simple-service
      'metal-common-servers
      home-servers-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-games
     (simple-service
      'metal-common-games
      home-games-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 02-java
     (simple-service
      'metal-common-java
      home-java-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-otools
     (simple-service
      'metal-common-otools
      home-otools-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 99-tmp
     (simple-service
      'metal-common-tmp
      home-tmp-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 02-test
     (simple-service
      'metal-common-test
      home-test-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 99-failed
     (simple-service
      'metal-common-failed
      home-failed-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))))

  (feature
   (name 'metal-common-profile)
   (home-services-getter get-home-services)))

