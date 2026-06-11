;; home-scoped-profiles.scm
;;
;; A reusable framework for creating independently extensible
;; Guix Home subprofiles.
;;
;; Example result:
;;
;;   ~/.guix-extra-profiles/dev
;;   ~/.guix-extra-profiles/ml
;;   ~/.guix-extra-profiles/tools
;;
;; Each profile is independently extensible through:
;;
;;   (simple-service
;;    'dev-tools
;;    home-dev-profile-service-type
;;    (list gcc-toolchain gdb))
;;
;; Similar to how profile-service-type works internally.

;; https://chatgpt.com/g/g-p-6a0c475ce26481918489971e3be6f66d-guix/c/6a0c32ea-4624-8322-9640-dace11322bcd

(define-module (lotus-rde home scoped-profiles)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (guix profiles)
  #:use-module (guix packages)

  #:use-module (srfi srfi-1)

  #:export (make-home-scoped-profile-service-type
            home-dev-profile-service-type
            home-ml-profile-service-type
            home-tools-profile-service-type))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (packages->profile packages)

  (profile
   (content
    (map package->manifest-entry
         packages))))


(define (profile-activation-gexp profile-name packages)

  (let ((profile
         (packages->profile packages)))

    #~(begin

        (use-modules (guix build utils))

        (let* ((home
                (getenv "HOME"))

               (profiles-dir
                (string-append
                 home
                 "/.guix-extra-profiles"))

               (profile-link
                (string-append
                 profiles-dir
                 "/"
                 #$profile-name)))

          (mkdir-p profiles-dir)

          ;; Remove existing symlink if present
          (false-if-exception
           (delete-file profile-link))

          ;; Create new symlink
          (symlink #$profile
                   profile-link)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Service Type Factory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-home-scoped-profile-service-type profile-name)

  (service-type

   (name
    (string->symbol
     (string-append
      "home-"
      profile-name
      "-profile")))

   ;; Extensions collected from simple-service/service-extension
   ;;
   ;; Each extension contributes:
   ;;
   ;;   (list package1 package2 ...)
   ;;
   ;; They all get concatenated together.
   ;;
   (compose concatenate)

   (extend append)

   (default-value '())

   (extensions

    (list

     (service-extension
      home-activation-service-type

      (lambda (packages)

        (profile-activation-gexp
         profile-name
         packages)))))

   (description

    (string-append
     "Scoped home profile: "
     profile-name))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Concrete Profile Service Types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define home-dev-profile-service-type
  (make-home-scoped-profile-service-type "dev"))


(define home-ml-profile-service-type
  (make-home-scoped-profile-service-type "ml"))


(define home-tools-profile-service-type
  (make-home-scoped-profile-service-type "tools"))





