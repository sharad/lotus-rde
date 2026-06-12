(define-module (guix scripts scoped-profile)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (gnu home)
  #:use-module (gnu services)
  #:use-module (guix ui)
  #:use-module (guix profiles)
  #:use-module (guix packages)
  #:use-module (guix scripts package)
  #:autoload
  (guix scripts package)
  (build-and-use-profile)
  #:export (guix-scoped-profile))

(define (show-help)
  (display
   "Usage: guix hello\n"))



;; (define (profile-path name)
;;   (string-append (getenv "HOME")
;;    "/.guix-profiles/"
;;    name))

;; (define (packages->manifest packages)
;;   (packages->manifest
;;    packages))


;; (define (install-profile
;;          profile-name
;;          packages)
;;   (let* ((path (profile-path
;;                 profile-name))
;;          (manifest (packages->manifest
;;                     packages))
;;          (manifest-file (string-append "/tmp/"
;;                          profile-name
;;                          ".scm")))
;;     (call-with-output-file
;;         manifest-file
;;       (lambda (port)
;;         (write
;;          manifest
;;          port)))
;;     (apply
;;      guix-package
;;      (list
;;       "--profile"
;;       path
;;       "--manifest"
;;       manifest-file))))

;; (define (guix-scoped-profile . args)
;;   (match args
;;     (("--help")
;;      (show-help))
;;     (("list-generations" name)
;;      (apply guix-package
;;             (list "--profile"
;;                   (profile-path name)
;;                   "--list-generations")))
;;     (("roll-back" name)
;;      (apply guix-package
;;       (list
;;        "--profile" (profile-path name)
;;        "--roll-back")))
;;     (("switch-generation"
;;       name
;;       generation)
;;      (apply guix-package
;;       (list "--profile"
;;             (profile-path name)
;;        "--switch-generation"
;;        generation)))
;;     ;; (_
;;     ;;  (error
;;     ;;   "bad command"))
;;     (_
;;      (begin
;;        (display
;;         "Hello from custom Guix command!\n")
;;        0))))


(define (load-home file)
  (primitive-load file))

(define (extract-profiles file)
  (let*
      ((env (load-home file))
       (services (home-environment-services env))
       (result (fold-services services)))
    (service-value
     (lookup-service
      result
      home-scoped-profile-service-type))))

(define (install-profile profile)
  (let ((manifest (packages->manifest
                   (scoped-profile-packages
                    profile))))
    (build-and-use-profile
     (profile-path
      (scoped-profile-name
       profile))
     manifest)))

(define (reconfigure file)
  (for-each install-profile
            (extract-profiles file)))


(define (guix-scoped-profile . args)
  (match args
    (("reconfigure" file)
     (reconfigure file))
    (("roll-back" profile)
     (roll-back
      (profile-path profile)))
    (("list-generations"
      profile)
     (profile-generations
      (profile-path profile)))
    (_
     (leave
      "bad command\n"))))


;; guix scoped-profile reconfigure home.scm
;; guix scoped-profile list-generations PROFILE
;; guix scoped-profile roll-back PROFILE
;; guix scoped-profile switch-generation PROFILE N
;; guix scoped-profile delete-generations PROFILE SPEC


;; https://chatgpt.com/g/g-p-6a0c475ce26481918489971e3be6f66d/c/6a0c32ea-4624-8322-9640-dace11322bcd

