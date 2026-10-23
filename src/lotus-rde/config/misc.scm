(define-module (lotus-rde config misc)
  #:use-module (guix gexp)
  #:use-module (guix channels)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (rde system services admin)
  #:export (%lotus-locale-names
            %lotus-rde-substitute-urls
            %lotus-rde-authorized-guix-keys
            %lotus-rde-channels))


(define %lotus-locale-names '("en_US"
                              "hi_IN"
                              "ur_PK"
                              "fa_IR"
                              "ar_SA"))

(define %lotus-rde-substitute-urls '("https://cache-cdn.guix.moe"
                                     "https://ci.guix.info/"
                                     "https://substitutes.nonguix.org"
                                     "https://nonguix-proxy.ditigal.xyz"
                                     "https://bordeaux.guix.gnu.org"
                                     "https://berlin.guix.gnu.org"
                                     "https://guix.tobias.gr"
                                     "https://mirror.brielmaier.net"
                                     "https://cuirass.genenetwork.org"
                                     "https://substitutes.guix.gofranz.com"))

(define %lotus-rde-authorized-guix-keys (list (plain-file "cache-cdn.guix.moe-old.pub"
                                                      "(public-key (ecc (curve Ed25519) (q #374EC58F5F2EC0412431723AF2D527AD626B049D657B5633AAAEBC694F3E33F9#)))")
                                          ;; New key since 2025-10-29.
                                          (plain-file "cache-cdn.guix.moe.pub"
                                                      "(public-key (ecc (curve Ed25519) (q #552F670D5005D7EB6ACF05284A1066E52156B51D75DE3EBD3030CD046675D543#)))")
                                          (plain-file "ci.guix.info"
                                                      "(public-key (ecc (curve Ed25519) (q #8D156F295D24B0D9A86FA5741A840FF2D24F60F7B6C4134814AD55625971B394#)))")
                                          (plain-file "substitutes.nonguix.org.pub"
                                                      "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
                                          (plain-file "nonguix-proxy.ditigal.xyz.pub"
                                                      "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
                                          (plain-file "bordeaux.guix.gnu.org"
                                                      "(public-key (ecc (curve Ed25519) (q #7D602902D3A2DBB83F8A0FB98602A754C5493B0B778C8D1DD4E0F41DE14DE34F#)))")
                                          (plain-file "berlin.guix.gnu.org"
                                                      "(public-key (ecc (curve Ed25519) (q #8D156F295D24B0D9A86FA5741A840FF2D24F60F7B6C4134814AD55625971B394#)))")
                                          (plain-file "guix.tobias.gr"
                                                      "(public-key (ecc (curve Ed25519) (q #628CD75C05C78223317092AFDCBE7130D363ACA938114A067F4F9DCF346B59DB#)))")
                                          (plain-file "mirror.brielmaier.net"
                                                      "(public-key (ecc (curve Ed25519) (q #34C318D602FCF6198C5A9F5290A8DB2382D2D0C5478441F8308D24E31BA61633#)))")
                                          (plain-file "cuirass-genenetwork-org.pub"
                                                      "(public-key (ecc (curve Ed25519) (q #11217788B41ADC8D5B8E71BD87EF699C65312EC387752899FE9C888856F5C769#)))")
                                          (plain-file "guix.gofranz.com.pub"
                                                      "(public-key (ecc (curve Ed25519) (q #0096373009D945F86C75DFE96FC2D21E2F82BA8264CB69180AA4F9D3C45BAA47#)))")))

(define %lotus-rde-channels
  (list (channel
                 (name 'guix-more-lotus)
                 (url "https://github.com/sharad/guix-more.git")
                 (branch "master")
                 (commit "1371da910bb235178af53c20a5704a22d75c41d4"))
        (channel
         (name 'nonguix)
         (url "https://gitlab.com/nonguix/nonguix")
         (branch "master")
         (commit "47c20df59dd9f27c9154ef20a81d383a19d4ad7f")
         (introduction
          (make-channel-introduction
           "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
           (openpgp-fingerprint
            "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
        (channel
         (name 'rde)
         (url "https://git.sr.ht/~abcdw/rde")
         (branch "master")
         (commit "6821d6f604caf3e2bb8ddd38ca55c0aa5756b0e1")
         (introduction
          (make-channel-introduction
           "257cebd587b66e4d865b3537a9a88cccd7107c95"
           (openpgp-fingerprint
            "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0"))))))

