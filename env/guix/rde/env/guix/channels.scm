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
          (commit "59fc6bec7fb4b1d246704cb57ab96f9fffe96c85"))
        (channel
          (name 'nonguix)
          (url "https://gitlab.com/nonguix/nonguix")
          (branch "master")
          (commit "82be0b7adaaaa7a98d47382d7f72dd2e31d8e6d8")
          (introduction
           (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
             "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
        (channel
          (name 'rde)
          (url "https://git.sr.ht/~abcdw/rde")
          (branch "master")
          (commit "c5aea8d9c81db29f3e4d9ea5a6a152ece11c26cc")
          (introduction
           (make-channel-introduction
            "257cebd587b66e4d865b3537a9a88cccd7107c95"
            (openpgp-fingerprint
             "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0"))))
        (channel
          (name 'lotus)
          (url "https://github.com/sharad/guix")
          (branch "master")
          (commit "c4b8b95d4d113d552682d22c35438edcde994fa8"))
        (channel
          (name 'guix-android)
          (url "https://framagit.org/tyreunom/guix-android.git")
          (branch "master")
          (commit "e5f52bd57275e404db74bf03b541bb62f7d73d58"))
        (channel
          (name 'guix)
          (url "https://git.guix.gnu.org/guix.git")
          (branch "master")
          (commit "9f5840e8950d34b0ddbda678122891ad80bc3af3")
          (introduction
           (make-channel-introduction
            "9edb3f66fd807b096b48283debdcddccfea34bad"
            (openpgp-fingerprint
             "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))))

core-channels
