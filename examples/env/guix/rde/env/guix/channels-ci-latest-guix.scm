;; -*- mode: scheme; -*-
(define-module (rde env guix channels-ci-latest-guix)
  #:use-module (guix channels)
  #:export (core-channels-with-local-rde-and-latest-guix))



(define %local-use-guix-official-mirror #t)


(define %backup-default-channels (list (channel (name 'guix)
                                                ;; (name 'guix-github)
                                                (branch "master")
                                                (url "https://github.com/guix-mirror/guix.git"))))

;; Default list of channels.
(define %guix-official-channels %default-channels)

(define %local-default-channels
  (if %local-use-guix-official-mirror
      %guix-official-channels
      %backup-default-channels))


(define %guix-lotus-channels (list (channel (name 'lotus)
                                            (url "https://github.com/sharad/guix"))))

(define %nonguix-channels (list (channel (name 'nonguix)
                                         (url "https://gitlab.com/nonguix/nonguix")
                                         ;; Enable signature verification:
                                         (introduction
                                          (make-channel-introduction
                                           "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
                                           (openpgp-fingerprint
                                            "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))))

(define %wigust-channels (list (channel (name 'wigust)
                                        (url "https://notabug.org/wigust/guix-wigust.git"))))

(define %guix-more-main-channels (list (channel (name 'guix-more)
                                                ;; (url "https://framagit.org/tyreunom/guix-more.git")
                                                ;; (url "git@github.com:sharad/guix-more.git")
                                                ;; (url "https://framagit.org/tyreunom/guix-more.git")
                                                (url "https://git.lepiller.eu/git/guix-more"))))

(define %guix-more-ff-channels (list (channel (name 'guix-more-ff)
                                              (branch "few-fixes")
                                              (url "https://framagit.org/gu1/guix-more.git"))))


(define %guix-more-lotus-channels (list (channel (name 'guix-more-lotus)
                                                 (url "https://github.com/sharad/guix-more.git"))))

(define %guix-android-channels    (list (channel (name 'guix-android)
                                                 (url "https://framagit.org/tyreunom/guix-android.git"))))

(define %guix-notabug-channels (list (channel (name 'guix-notabug)
                                              (url "https://notabug.org/jlicht/guix-pkgs.git"))))

(define %guix-more-channels %guix-more-lotus-channels)
;; (define %guix-more-channels %guix-more-main-channels)
;;(define %guix-more-channels %guix-more-ff-channels)


(define %rde-channels (list (channel (name 'rde)
                                     (url "https://git.sr.ht/~abcdw/rde")
                                     (introduction
                                      (make-channel-introduction
                                       "257cebd587b66e4d865b3537a9a88cccd7107c95"
                                       (openpgp-fingerprint
                                        "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0"))))))


(define %rde-lotus-channels (list (channel (name 'lotus-rde)
                                           (url "https://github.com/sharad/lotus-rde.git"))))


(define core-channels-with-local-rde-and-latest-guix (append %guix-more-channels
                                                      %nonguix-channels
                                                      %rde-channels
                                                      ;; %rde-lotus-channels -- not required
                                                      %guix-lotus-channels
                                                      %guix-android-channels
                                                      %local-default-channels))


