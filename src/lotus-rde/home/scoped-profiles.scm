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
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (guix profiles)
  #:use-module (guix packages)
  #:use-module (srfi srfi-1)
  #:export (scoped-profile-config
            make-home-profile-service-type
            home-dev-profile-service-type
            home-tools-profile-service-type
            profile->manifest
            profile-mod->manifest))


(define-record-type* <scoped-profile>
  scoped-profile
  make-scoped-profile
  scoped-profile?
  (name
   scoped-profile-name)
  (level
   scoped-profile-level)
  (packages
   scoped-profile-packages)
  (exclude
   scoped-profile-exclude
   (default '())))

(define-record-type* <scoped-profile-config>
  scoped-profile-config
  make-scoped-profile-config
  scoped-profile-config?
  (packages scoped-profile-config-packages)
  (exclude scoped-profile-config-exclude
           (default '())))

(define home-scoped-profile-service-type
  (service-type
   (name 'home-scoped-profile)
   (compose append)
   (extend append)
   (default-value
     '())
   ;; root collector
   (extensions
    '())
   (description
    "service.")))

(define (make-home-profile-service-type profile-name
                                        profile-level)
  (service-type
   (name profile-name)
   (compose concatenate)
   (extend append)
   (default-value
     '())
   (extensions
    (list
     (service-extension
      home-scoped-profile-service-type
      (lambda (entry)
        (list
         (scoped-profile
          (name profile-name)
          (level profile-level)
          (packages (scoped-profile-config-packages entry))
          (exclude  (scoped-profile-config-exclude entry))))))))
   (description
    "service.")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Examples
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (define home-dev-profile-service-type
;;   (make-home-profile-service-type 'dev 1))
;; (define home-tools-profile-service-type
;;   (make-home-profile-service-type 'tools 1))


;; (simple-service
;;  'gcc
;;  home-dev-profile-service-type
;;  (list
;;   gcc-toolchain))

;; (simple-service
;;  'gdb
;;  home-dev-profile-service-type
;;  (list
;;   gdb))


;; (simple-service
;;  'tools
;;  home-tools-profile-service-type
;;  (list
;;   strace))


(define (profile->manifest env
                           profile-name
                           profile-level)
  (let* ((folded (fold-services (home-environment-services env)
                                #:target-type
                                home-scoped-profile-service-type))
         (profiles (filter (lambda (service)
                             (and (eq? (scoped-profile-name service)
                                       profile-name)
                                  (eq? (scoped-profile-level service)
                                       profile-level)))
                           (apply append
                                  (service-value folded)))))
    (packages->manifest (append-map scoped-profile-packages
                                    profiles))))


(define (profile-mod-over->manifest env
                                    profile-name
                                    profile-level)
  (let* ((folded (fold-services (home-environment-services env)
                                #:target-type
                                home-scoped-profile-service-type))
         (profiles (filter (lambda (service)
                             (and (eq? (scoped-profile-name service)
                                       profile-name)
                                  (eq? (scoped-profile-level service)
                                       profile-level)))
                           (apply append
                                  (service-value folded))))
         ;; Collect all packages
         (packages (append-map scoped-profile-packages
                               profiles))
         ;; Collect all exclusions
         (excluded (append-map scoped-profile-exclude
                               profiles))
         ;; Remove excluded packages
         (result (filter (lambda (pkg)
                           (not (member pkg excluded)))
                         packages)))
    (packages->manifest result)))

(define (profile-mod->manifest env
                               profile-name
                               profile-level)
  (let* ((folded (fold-services (home-environment-services env)
                                #:target-type
                                home-scoped-profile-service-type))
         (profiles (filter (lambda (service)
                             (and (eq? (scoped-profile-name service)
                                       profile-name)
                                  (eq? (scoped-profile-level service)
                                       profile-level)))
                           (apply append
                                  (service-value folded)))))

    (packages->manifest
     (append-map
      (lambda (profile)
        (filter
         (lambda (pkg)
           (not (member pkg
                        (scoped-profile-exclude profile))))
         (scoped-profile-packages profile)))
      profiles))))

