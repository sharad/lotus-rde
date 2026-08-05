

(define-module (lotus-rde features profiles desktop)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (rde system services admin)
  #:use-module (lotus-rde features profiles)
  #:export (feature-desktop-profile))


(define* (feature-desktop-profile)

  (define* (get-home-services config)
    (list
     ;; 01-doc
     (simple-service
      'desktop-doc
      home-doc-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(okular
                      qpdfview
                      mupdf

                      zathura
                      zathura-pdf-poppler
                      zathura-pdf-mupdf
                      zathura-ps
                      zathura-cb
                      zathura-djvu

                      xournalpp

                      ;; texlive-*
                      asciidoc))))))
     ;; 01-tool
     (simple-service
      'desktop-tool
      home-tool-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(rofi
                      python-rofi
                      python-rofi-menu

                      boxes

                      gnome-calculator
                      gnome-tweaks
                      discover
                      bluedevil

                      viewnior
                      photoflare

                      kmonad
                      acpilight

                      obs
                      flatpak

                      nautilus
                      tracker
                      menumaker
                      keynav
                      conky

                      hiawatha
                      uwsgi
                      udiskie
                      libappindicator
                      geoclue

                      feh
                      eog
                      imagemagick

                      ))))))
     ;; 01-otools
     (simple-service
      'desktop-otools
      home-otools-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-security
     (simple-service
      'desktop-security
      home-security-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(qrencode
                      zbar
                      gnome-keyring
                      python-keyring
                      seahorse
                      libsecret))))))
     ;; 01-x
     (simple-service
      'desktop-x
      home-x-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(vmware-open-vm-tools
                      xpra
                      xssstate
                      xscreensaver
                      xrandr-invert-colors
                      guvcview
                      v4l-utils
                      beep
                      nxbelld
                      wireplumber
                      easyeffects
                      calf
                      swh-plugins

                      xinit
                      i3status
                      libwm
                      wmutils-core
                      wmutils-opt
                      xautomation
                      dmenu
                      st
                      xrdb
                      xterm
                      xdotool
                      xrandr
                      arandr
                      autorandr
                      xrandr-invert-colors
                      rxvt-unicode
                      alacritty
                      sakura
                      xprop
                      xwininfo
                      xautolock
                      slock
                      xtrlock
                      xset
                      xsetroot

                      stumpish
                      sbcl-stumpwm-wifi
                      sbcl-stumpwm-ttf-fonts
                      sbcl-stumpwm-swm-gaps
                      sbcl-stumpwm-stumptray
                      sbcl-stumpwm-pass
                      sbcl-stumpwm-net
                      sbcl-stumpwm-kbd-layouts
                      sbcl-stumpwm-globalwindows
                      sbcl-dbus

                      compton
                      xcompmgr
                      xdpyinfo
                      xlsfonts
                      xclip
                      xsel
                      xmodmap
                      autocutsel
                      xfd
                      xwininfo
                      setxkbmap
                      wmctrl))))))
     ;; 01-dev
     (simple-service
      'desktop-dev
      home-dev-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list
                "python-dbus")))))
     ;; 01-text
     (simple-service
      'desktop-text
      home-text-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-dynamic-hash
     (simple-service
      'desktop-dynamic-hash
      home-dynamic-hash-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-net
     (simple-service
      'desktop-net
      home-net-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 91-build-heavy
     (simple-service
      'desktop-build-heavy
      home-build-heavy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-essential
     (simple-service
      'desktop-essential
      home-essential-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(gparted

                      alsa-lib
                      alsa-utils
                      bluez
                      bluez-alsa
                      blueman
                      ddcutil
                      udevil

                      mpd-mpc
                      cava
                      aumix
                      pavucontrol
                      pulsemixer))))))
     ;; 01-emacs
     (simple-service
      'desktop-emacs
      home-emacs-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-editor
     (simple-service
      'common-editor
      home-editor-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list "vscodium"))))))))
     ;; 71-sysdev
     (simple-service
      'desktop-sysdev
      home-sysdev-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 60-lengthy
     (simple-service
      'desktop-lengthy
      home-lengthy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-simple
     (simple-service
      'desktop-simple
      home-simple-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-console
     (simple-service
      'desktop-console
      home-console-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(quassel
                      irssi
                      weechat
                      weechat-wee-slack
                      poezio
                      quaternion
                      nheko
                      aerc
                      mumble))))))
     ;; 90-heavy
     (simple-service
      'desktop-heavy
      home-heavy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 40-servers
     (simple-service
      'desktop-servers
      home-servers-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list
                "deskflow"
                "kodi"
                "kodi-cli"
                "syncplay"
                "jupyter"
                "udiskie")))))
     ;; 01-games
     (simple-service
      'desktop-games
      home-games-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 02-java
     (simple-service
      'desktop-java
      home-java-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 99-tmp
     (simple-service
      'desktop-tmp
      home-tmp-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 02-test
     (simple-service
      'desktop-test
      home-test-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 99-failed
     (simple-service
      'desktop-failed
      home-failed-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))))

  (feature
   (name 'desktop-profile)
   (home-services-getter get-home-services)))

