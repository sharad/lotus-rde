
(define-module (lotus-rde home package-manager)

  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)

  #:use-module (gnu services)
  #:use-module (guix records)
  #:use-module (guix profiles)

  #:export
  (pkg-col
   pkg-col?
   pkg-col-description
   pkg-col-packages
   pkg-col-tags

   pkg-col-type

   pkg-constraint
   pkg-constraint?
   pkg-constraint-include
   pkg-constraint-exclude

   pkg-col-filter

   scoped-profile
   scoped-profile?
   scoped-profile-name
   scoped-profile-constraint

   scoped-profile-packages
   scoped-profile->manifest

   make-home-profile-service-type))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package collection entry
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type* <pkg-col>
  pkg-col
  make-pkg-col
  pkg-col?
  (description
   pkg-col-description)
  (packages
   pkg-col-packages)
  (tags
   pkg-col-tags))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package collection service type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Every pkg-col-type service instance contributes one <pkg-col>.
;;
;; The value of the service after folding is therefore:
;;
;;   (<pkg-col> <pkg-col> <pkg-col> ...)

(define pkg-col-type
  (service-type
   (name 'pkg-col)
   ;; Values contributed by different instances are combined.
   (compose append)
   ;; Each instance contributes one pkg-col.
   (extend append)
   (default-value '())
   (extensions '())
   (description
    "Collect package collections together with their
description and hierarchical tags.")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constraint
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; First version:
;;
;;   include
;;   exclude
;;
;; A tag is represented as a hierarchy:
;;
;;   '(gui tool)
;;
;; corresponds to:
;;
;;   gui/tool
;;
;; A constraint can therefore say:
;;
;;   include: '(gui)
;;   exclude: '((gui game))
;;
;; etc.

(define-record-type* <pkg-constraint>
  pkg-constraint
  make-pkg-constraint
  pkg-constraint?
  (include
   pkg-constraint-include
   (default '()))
  (exclude
   pkg-constraint-exclude
   (default '())))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hierarchical tag utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Convert:
;;
;;   '(gui tool text)
;;
;; into a path.
;;
;; We initially compare paths structurally rather than converting
;; everything to strings containing "/".

(define (tag-path-prefix? prefix path)
  "Return #t if PREFIX is a prefix of PATH."
  (and (<= (length prefix)
           (length path))
       (equal? prefix
               (take path
                     (length prefix)))))

;; Does ENTRY have a tag matching TAG?
;;
;; ENTRY:
;;
;;   '((gui tool)
;;     (text publishing))
;;
;; TAG:
;;
;;   '(gui)
;;
;; matches:
;;
;;   gui
;;   gui/tool
;;   gui/tool/...
;;
;; because hierarchy is prefix based.

(define (pkg-col-has-tag? entry tag)
  (any (lambda (path)
         (tag-path-prefix? tag path))
       (pkg-col-tags entry)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constraint matching
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (pkg-col-matches-constraint? entry constraint)
  (let ((include (pkg-constraint-include constraint))
        (exclude (pkg-constraint-exclude constraint)))
    ;; Every include constraint must match.
    ;;
    ;; If include is empty, everything is eligible.
    (and
     (or (null? include)
         (every (lambda (tag)
                 (pkg-col-has-tag? entry tag))
                include))
     ;; No excluded constraint may match.
     (not
      (any (lambda (tag)
             (pkg-col-has-tag? entry tag))
           exclude)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filter package collection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (pkg-col-filter collection constraint)
  (append-map
   pkg-col-packages
   (filter
    (lambda (entry)
      (pkg-col-matches-constraint?
       entry
       constraint))
    collection)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Scoped profile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Notice:
;;
;; There is NO packages field here.
;;
;; Packages are calculated from:
;;
;;   pkg-col collection
;;          +
;;   constraint

(define-record-type* <scoped-profile>
  scoped-profile
  make-scoped-profile
  scoped-profile?
  (name
   scoped-profile-name)
  (level
   scoped-profile-level)
  (constraint
   scoped-profile-constraint))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculate packages for a scoped profile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (scoped-profile-packages profile collection)
  (pkg-col-filter
   collection
   (scoped-profile-constraint profile)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculate manifest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (scoped-profile->manifest profile collection)
  (packages->manifest
   (scoped-profile-packages
    profile
    collection)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Home scoped-profile service type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This is deliberately separate from pkg-col-type.
;;
;; pkg-col-type:
;;
;;   describes/collects packages.
;;
;; scoped-profile:
;;
;;   selects packages from that collection.

(define home-scoped-profile-service-type
  (service-type
   (name 'home-scoped-profile)
   (compose append)
   (extend append)
   (default-value '())
   (extensions '())
   (description
    "Scoped profiles selected from package collections.")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constructor for scoped profile service types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-home-profile-service-type profile-name
                                        profile-level
                                        constraint)
  (service-type
   (name profile-name)
   (compose append)
   (extend append)
   (default-value '())
   (extensions
    (list
     (service-extension
      home-scoped-profile-service-type
      (lambda (value)
        (list
         (scoped-profile
          (name profile-name)
          (level profile-level)
          (constraint constraint)))))))
   (description
    "A home scoped profile selected by package constraints.")))

(define (home-environment-pkg-col-collection env)
  (let ((folded
         (fold-services
          (home-environment-services env)
          #:target-type pkg-col-type)))

    ;; service-value of pkg-col-type is the collection
    (service-value folded)))

(define (profile->manifest env profile)
  (let ((collection
         (home-environment-pkg-col-collection env)))
    (scoped-profile->manifest
     profile
     collection)))


