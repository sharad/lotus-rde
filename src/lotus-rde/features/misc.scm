(define-module (lotus-rde features misc)
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
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde predicates)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features guile)
  #:use-module (rde features networking)
  #:use-module (rde features system)
  #:use-module (lotus-rde features mfs)
  #:export ())



(use-modules (gnu home services)
             (gnu home services shepherd)
             (shepherd service)
             (guix gexp))

(define (feature-my-user-services)

  (feature
   (name 'my-user-services)

   (home-services-getter
    (lambda (_)

      (list

       ;; =========================================================
       ;; Shepherd user services
       ;; =========================================================

       (simple-service
        'my-user-shepherd-services
        home-shepherd-service-type

        (list

         ;; -----------------------------------------------------
         ;; pipewire
         ;; -----------------------------------------------------

         (shepherd-service
          (provision '(pipewire))

          (documentation "PipeWire daemon.")

          (start
           #~(make-forkexec-constructor
              (list "pipewire")
              #:log-file
              (string-append
               (or (getenv "XDG_STATE_HOME")
                   (string-append (getenv "HOME")
                                  "/.local/state"))
               "/log/pipewire.log")))

          (stop
           #~(make-kill-destructor))

          (respawn? #t))


         ;; -----------------------------------------------------
         ;; wireplumber
         ;; -----------------------------------------------------

         (shepherd-service
          (provision '(wireplumber))

          (requirement '(pipewire))

          (documentation "WirePlumber session manager.")

          (start
           #~(make-forkexec-constructor
              (list "wireplumber")
              #:log-file
              (string-append
               (or (getenv "XDG_STATE_HOME")
                   (string-append (getenv "HOME")
                                  "/.local/state"))
               "/log/wireplumber.log")))

          (stop
           #~(make-kill-destructor))

          (respawn? #t))


         ;; -----------------------------------------------------
         ;; ssh-agent
         ;; -----------------------------------------------------

         (shepherd-service
          (provision '(ssh-agent))

          (documentation "SSH agent.")

          (start
           #~(make-forkexec-constructor
              (list "ssh-agent"
                    "-D"
                    "-a"
                    (string-append
                     (getenv "XDG_RUNTIME_DIR")
                     "/ssh-agent.socket"))

              #:log-file
              (string-append
               (or (getenv "XDG_STATE_HOME")
                   (string-append (getenv "HOME")
                                  "/.local/state"))
               "/log/ssh-agent.log")))

          (stop
           #~(make-kill-destructor))

          (respawn? #f))


         ;; -----------------------------------------------------
         ;; emacs daemon
         ;; -----------------------------------------------------

         (shepherd-service
          (provision '(emacs))

          (requirement '(dbus))

          (documentation "Emacs daemon.")

          (start
           #~(make-forkexec-constructor
              (list "emacs"
                    "--fg-daemon=main")

              #:log-file
              (string-append
               (or (getenv "XDG_STATE_HOME")
                   (string-append (getenv "HOME")
                                  "/.local/state"))
               "/log/emacs.log")))

          (stop
           #~(make-forkexec-destructor
              (list "emacsclient"
                    "--eval"
                    "(kill-emacs)")))

          (respawn? #f))


         ;; -----------------------------------------------------
         ;; udiskie
         ;; -----------------------------------------------------

         (shepherd-service
          (provision '(udiskie))

          (requirement '(dbus))

          (documentation "Tray automounter.")

          (start
           #~(make-forkexec-constructor
              (list "udiskie" "--tray")
              #:log-file
              (string-append
               (or (getenv "XDG_STATE_HOME")
                   (string-append (getenv "HOME")
                                  "/.local/state"))
               "/log/udiskie.log")))

          (stop
           #~(make-kill-destructor))

          (respawn? #t)))))))))
