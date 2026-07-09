

(define-module (lotus-rde features profiles common)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (rde system services admin)
  #:use-module (lotus-rde features profiles)
  #:export (feature-common-profile))


(define* (feature-common-profile)

  (define* (get-home-services config)
    (list
     ;; 01-doc
     (simple-service
      'common-doc
      home-doc-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-tools
     (simple-service
      'common-tools
      home-tools-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-otools
     (simple-service
      'common-otools
      home-otools-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-crypto
     (simple-service
      'common-crypto
      home-crypto-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-x
     (simple-service
      'common-x
      home-x-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-dev
     (simple-service
      'common-dev
      home-dev-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-text
     (simple-service
      'common-text
      home-text-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-dynamic-hash
     (simple-service
      'common-dynamic-hash
      home-dynamic-hash-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-net
     (simple-service
      'common-net
      home-net-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 91-build-heavy
     (simple-service
      'common-build-heavy
      home-build-heavy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-essential
     (simple-service
      'common-essential
      home-essential-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-emacs
     (simple-service
      'common-emacs
      home-emacs-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 71-sysdev
     (simple-service
      'common-sysdev
      home-sysdev-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 60-lengthy
     (simple-service
      'common-lengthy
      home-lengthy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-simple
     (simple-service
      'common-simple
      home-simple-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-console
     (simple-service
      'common-console
      home-console-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 90-heavy
     (simple-service
      'common-heavy
      home-heavy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 40-servers
     (simple-service
      'common-servers
      home-servers-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-games
     (simple-service
      'common-games
      home-games-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 02-java
     (simple-service
      'common-java
      home-java-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 99-tmp
     (simple-service
      'common-tmp
      home-tmp-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 02-test
     (simple-service
      'common-test
      home-test-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 99-failed
     (simple-service
      'common-failed
      home-failed-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))))

  (feature
   (name 'common-profile)
   (home-services-getter get-home-services)))

