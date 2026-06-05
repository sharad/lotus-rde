(define-module (lotus-rde lib utils)
  #:use-module (ice-9 match)
  #:use-module (ice-9 hash-table)
  #:use-module (ice-9 format)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 threads)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (srfi srfi-13)
  #:use-module (system foreign)
  #:use-module (guix gexp)
  #:use-module (guix modules)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  ;; #:use-module (gnu packages)
  ;; #:use-module (gnu packages base)
  #:use-module (guix build utils)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system uuid)
  #:use-module (gnu packages linux)
  #:export (log-file
            log-file-gexp
            make-cmd-destructor
            make-cmd-destructor-gexp
            file->package
            ;; lotus-assert
            ensure-rw-mount
            ensure-umount))


(define (lotus-assert condition . msg)
  (throw-message
   condition
   (if (null? msg)
       (list "Assertion failed")
       msg)))



;; (define (shepherd-service-log-file name)
;;   "Return log file path for shepherd service NAME.
;; Usage: #:log-file #$(shepherd-service-log-file name)"
;;   (string-append (getenv "HOME") "/.logs/shepherd/" name ".log"))

;; (define shepherd-service-log-file-gexp
;;   ;; Usage: #:log-file (#$shepherd-service-log-file-gexp #$(service-name-fn))
;;   #~(lambda (name)
;;       (string-append (getenv "HOME") "/.logs/shepherd/" name ".log")))



;; (define (shepherd-service-log-file name)
;;   "Return log file path for shepherd service NAME.
;; Usage: #:log-file #$(shepherd-service-log-file name)"
;;   (string-append (getenv "HOME") "/.logs/shepherd/" name ".log"))

;; (define shepherd-service-log-file-gexp
;;   ;; Usage: #:log-file (#$shepherd-service-log-file-gexp #$(service-name-fn))
;;   #~(lambda (name)
;;       (string-append (getenv "HOME") "/.logs/shepherd/" name ".log")))


(define (log-file name)
  #~(string-append
     (or (getenv "XDG_STATE_HOME")
         (string-append (getenv "HOME")
                        "/.local/state"))
     "/log/"
     #$name
     ".log"))

(define log-file-gexp
  #~(lambda (name)
      (string-append
       (or (getenv "XDG_STATE_HOME")
           (string-append (getenv "HOME")
                          "/.local/state"))
       "/log/"
       name
       ".log")))

(define (make-cmd-destructor . command)
  (let ((system-destructor (apply make-system-destructor command))
        (kill-destructor   (make-kill-destructor)))
    (lambda (running . args)
      (apply kill-destructor running args)
      (apply system-destructor running args))))


(define make-cmd-destructor-gexp
  #~(lambda command
      (let ((system-destructor
             (apply make-system-destructor
                    command))
            (kill-destructor
             (make-kill-destructor)))
        (lambda (running . args)
          (apply kill-destructor
                 running
                 args)
          (apply system-destructor
                 running
                 args)))))


(define (file->package name prog)
  (package
    (name name)
    (version "0")
    (source #f)

    (build-system trivial-build-system)

    (arguments
     (list
      #:modules
      '((guix build utils))
      ;; #:imported-modules
      ;; %gnu-build-system-modules
      #:builder
      #~(begin
          (use-modules
           (guix build utils))
          (let ((out
                 (assoc-ref %outputs "out")))

            ;; mkdir -p equivalent
            (mkdir-p
             (string-append out "/bin"))

            ;; install wrapper
            (symlink
             #$prog
             (string-append
              out
              "/bin/"
              #$name))))))

    (synopsis name)
    (description name)
    (home-page "")

    ;; choose real license later
    (license #f)))



;; (define (script-file name path)

;;   (let ((content
;;          (call-with-input-file
;;              path
;;            get-string-all)))

;;     (computed-file
;;      name

;;      #~(begin

;;          (call-with-output-file
;;              #$output

;;            (lambda (p)
;;              (display #$content p)))

;;          (chmod #$output #o555)))))



(define %shepherd-utils
  (scheme-file "shepherd-utils.scm"
    #~(begin
        (use-modules (ice-9 popen)
                     (ice-9 rdelim)
                     (shepherd service))  ; ← make-system-destructor, make-kill-destructor

        (define (log-file name)
          (let* ((home   (getenv "HOME"))
                 (logdir (string-append home "/.logs/shepherd/")))
            (unless (file-exists? logdir)
              (mkdir logdir))
            (string-append logdir name ".log")))

        (define (pipe-read cmd)
          (let* ((p (open-input-pipe cmd))
                 (s (read-line p)))
            (close-pipe p)
            (and (not (eof-object? s))
                 (not (string-null? (string-trim-right s)))
                 (string-trim-right s))))

        (define (make-cmd-destructor . command)
          (let ((system-destructor (apply make-system-destructor command))
                (kill-destructor   (make-kill-destructor)))
            (lambda (running . args)
              (apply kill-destructor running args)
              (apply system-destructor running args)))))))

;;;; Usage
;; (stop #~(begin
;;           (load #$%shepherd-utils)
;;           (make-cmd-destructor
;;            (string-append #$flatpak-bin " kill " #$app
;;                           " >> " (log-file #$name-str) " 2>&1"))))


;; Check if mounted
(define (mounted? mount-point)
  (call-with-input-file "/proc/mounts"
    (lambda (port)
      (let loop ()
        (let ((line (read-line port 'concat)))
          (if (eof-object? line)
              #f
              (let* ((fields (string-split line #\space))
                     (target (list-ref fields 1)))
                (if (string=? target mount-point)
                    #t
                    (loop)))))))))


;; Ensure mount is rw
(define (ensure-rw-mount mount-point)

  (define MS_REMOUNT 32)

  ;; Find device from /etc/fstab
  (define (find-device-for mount-point)
    (call-with-input-file "/etc/fstab"
      (lambda (port)
        (let loop ()
          (let ((line (read-line port 'concat)))
            (cond
             ((eof-object? line)
              #f)

             ;; skip comments/empty
             ((or (string-prefix? "#" line)
                  (string-null? (string-trim line)))
              (loop))

             (else
              (let ((fields
                     (filter
                      (lambda (x)
                        (not (string-null? x)))
                      (string-split line #\space))))

                (if (and (>= (length fields) 2)
                         (string=? (list-ref fields 1)
                                   mount-point))
                    (list-ref fields 0)
                    (loop))))))))))

  ;; Check if mounted read-only
  (define (mount-read-only? mount-point)
    (call-with-input-file "/proc/mounts"
      (lambda (port)
        (let loop ()
          (let ((line (read-line port 'concat)))
            (if (eof-object? line)
                #f
                (let* ((fields (string-split line #\space))
                       (target (list-ref fields 1))
                       (opts   (list-ref fields 3)))
                  (if (string=? target mount-point)
                      (member "ro"
                              (string-split opts #\,))
                      (loop)))))))))

  ;; Find filesystem type using blkid
  (define (filesystem-type device)
    (let* ((pipe (open-pipe* OPEN_READ
                             "blkid"
                             "-o"
                             "value"
                             "-s"
                             "TYPE"
                             device))
           (result (string-trim-right (read-string pipe))))
      (close-pipe pipe)
      result))




  (let ((device (find-device-for mount-point)))
    (if (not device)
        (error "No device found for mount-point"
               mount-point)

        (let ((fs-type (filesystem-type device)))
          (cond

           ;; not mounted
           ((not (mounted? mount-point))
            (format #t "Mounting ~a on ~a\n"
                    device mount-point)
            (mount device mount-point fs-type 0 "rw"))

           ;; mounted ro
           ((mount-read-only? mount-point)
            (format #t "Remounting ~a rw\n"
                    mount-point)
            (mount device
                   mount-point
                   fs-type
                   MS_REMOUNT
                   "rw"))

           ;; already rw
           (else
            (format #t "~a already rw\n"
                   mount-point)))))))


;; Ensure unmounted
(define (ensure-umount mount-point)
  (if (mounted? mount-point)

      (begin
        (format #t
                "Unmounting ~a\n"
                mount-point)

        (umount mount-point))

      (format #t
              "~a already unmounted\n"
              mount-point)))

;; Example:
;; (ensure-rw "/boot/efi")


