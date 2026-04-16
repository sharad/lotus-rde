;; -*- mode: scheme; -*-
;;; rde --- Reproducible development environment.
;;;
;;; SPDX-FileCopyrightText: 2024, 2025 Andrew Tropin <andrew@trop.in>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (rde-configs env guix channels)
  #:use-module ((rde env guix channels)
                #:prefix rde:)
  #:use-module (guix channels)
  #:export (core-channels))

(define core-channels
  (cons (channel
          (name 'lotus-rde)
          (url "https://github.com/sharad/lotus-rde.git")
          (branch "master")
          (commit "a07d9bd4698df8b4fa886d8e65e94fe2540dd307"))
        ;; (introduction
        ;; (make-channel-introduction
        ;; "257cebd587b66e4d865b3537a9a88cccd7107c95"
        ;; (openpgp-fingerprint
        ;; "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0")))
        rde:core-channels))
core-channels
