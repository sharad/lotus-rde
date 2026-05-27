(define-module (lotus-rde features security)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (rde system services admin)

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
  #:use-module (gnu packages bash)
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
  #:use-module (gnu services ssh)
  #:use-module (gnu packages admin)
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
  #:use-module (gnu packages ssh)

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
  #:export (feature-lotus-security))


(define* (feature-lotus-security)
  "Configure a simple service that mounts secure filesystems in the home directory."
  ;; (define (get-system-services cfg))
  (define (get-home-services cfg)
    (append
     (list
      (simple-service 'my-secfs-volumes
                      home-secfs-service-type
                      (list
                       (home-secfs-volume-configuration
                        (volname "orgp"))
                       (home-secfs-volume-configuration
                        (volname "secure"))
                       (home-secfs-volume-configuration
                        (volname "volatile")
                        (mode "rw"))))

      (simple-service 'secfs-service-groups
                      home-services-group-service-type
                      (list
                       (home-services-group-configuration
                        (name 'secfs)
                        (dependent '(awaken-session-down))
                        (requirement '(secfs-orgp secfs-secure))))))
     home-ssh-add-key-service
     home-kpkey-service))
  (feature
   (name 'secfs)
   (home-services-getter get-home-services)))






