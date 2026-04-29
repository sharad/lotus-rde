;;; rde --- Reproducible development environment.
;;;
;;; Copyright © 2021, 2022, 2023 Andrew Tropin <andrew@trop.in>
;;; Copyright © 2025 Nicolas Graves <ngraves@ngraves.fr>
;;;
;;; This file is part of rde.
;;;
;;; rde is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; rde is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with rde.  If not, see <http://www.gnu.org/licenses/>.

(define-module (lotus-rde packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages xdisorg)

  #:use-module (srfi srfi-1)

  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system guile)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (rde packages)
  #:export (%rde-patch-path))

;; Utils



(define %channel-root
  (find (lambda (path)
          (file-exists? (string-append path "/lotus-rde/packages.scm")))
        %load-path))

(define %rde-patch-path
  (list (string-append %channel-root "/lotus-rde/packages/patches")))

(define-public lotus-rde
  (package
    (name "lotus-rde")
    (version "0.0.1")
    (home-page "https://github.com/sharad/lotus-rde")
    (source
     (origin
      (method git-fetch)
      (uri (git-reference (url "https://github.com/sharad/lotus-rde.git")
                          (commit "86cb4e608014fa43e54995bd5e40b6ca105793c8")))
      (sha256
       (base32
        "1ynlq6sn18pnf0dmv21g2c0jh4qcnrilpb5198j37l2v5jx0faz9"))
      (file-name (string-append "lotus-rde-" version "-checkout"))))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"))
    (native-inputs (list guile-3.0))
    ;; FIXME: Guix should probably be pinned here.
    (inputs (list guix))
    (synopsis "Developers and power user friendly GNU/Linux distribution")
    (description "The GNU/Linux distribution, a set of tools for managing
development environments, home environments, and operating systems, a set of
predefined configurations, practices and workflows.")
    (license license:gpl3+)))

(define-public lotus-rde-doc
  (package/inherit lotus-rde
    (name "lotus-rde-doc")
    (build-system gnu-build-system)
    (native-inputs (list gnu-make texinfo))
    (inputs '())
    (arguments
     (list
      #:make-flags ''("doc/rde.info")
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'check)
          (add-after 'install 'install-info
            (lambda _
              (install-file "doc/rde.info"
                            (string-append #$output "/share/info")))))))))

;; (define-public rde-latest
;;   (package
;;     (inherit rde)
;;     (source
;;      (local-file (dirname (dirname (current-filename))) #:recursive? #t))))

