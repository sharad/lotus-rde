


(define-module (lotus-rde features audio)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (guix gexp)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages mpd)
  #:use-module (lotus-rde lib utils)
  #:use-module (lotus-rde packages utils)
  #:export (feature-lotus-music))





(define* (feature-lotus-music #:key
                              (mpd mpd))
  (define (get-home-services config)
    (list
     (simple-service
      'lotus-audo-service-packages
      home-profile-service-type
      (list mpd
            gmpc
            ;; flatpak run com.yktoo.ymuse
            rust-euphonica))
     (simple-service
      'audio-services
      home-shepherd-service-type
      (list
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
        (respawn? #t))))))

  (feature
   (values `((shepherd-mpd (login))))
   (name 'lotus-music)
   (home-services-getter get-home-services)))



