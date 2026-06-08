;; -*- mode: scheme; -*-
;;; rde --- Reproducible development environment.
;;;
;;; SPDX-FileCopyrightText: 2024, 2025 Andrew Tropin <andrew@trop.in>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (rde env guix channels)
  #:use-module (guix channels)
  #:export (core-channels))

(define core-channels
  (list (channel
          (name 'guix-more-lotus)
          (url "https://github.com/sharad/guix-more.git")
          (branch "master")
          (commit "8fddd0df7ae4a297cb2b3db36952cbf44f23ff0e"))
        (channel
          (name 'nonguix)
          (url "https://gitlab.com/nonguix/nonguix")
          (branch "master")
          (commit "3ed7c207c59dde11a97db483cad4c96eae1a10c4")
          (introduction
           (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
             "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
        (channel
          (name 'rde)
          (url "https://git.sr.ht/~abcdw/rde")
          (branch "master")
          (commit "740d510ecd697a966be1d10da2a18162a4234cb3")
          (introduction
           (make-channel-introduction
            "257cebd587b66e4d865b3537a9a88cccd7107c95"
            (openpgp-fingerprint
             "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0"))))
        (channel
          (name 'guix-android)
          (url "https://framagit.org/tyreunom/guix-android.git")
          (branch "master")
          (commit "e5f52bd57275e404db74bf03b541bb62f7d73d58"))
        (channel
          (name 'guix)
          (url "https://git.guix.gnu.org/guix.git")
          (branch "master")
          (commit "d2dc70871313c795d27b9abeb448ce7ff750fb33")
          (introduction
           (make-channel-introduction
            "9edb3f66fd807b096b48283debdcddccfea34bad"
            (openpgp-fingerprint
             "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))))

core-channels
