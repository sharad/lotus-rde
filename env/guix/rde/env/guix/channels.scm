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
          (commit "6243b2009efb7f1da6690d3df4bdf1bc500b7219"))
        (channel
          (name 'nonguix)
          (url "https://gitlab.com/nonguix/nonguix")
          (branch "master")
          (commit "5d8b56d6a07cdc1aa3022737c32ccb95f08aef08")
          (introduction
           (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
             "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
        (channel
          (name 'rde)
          (url "https://git.sr.ht/~abcdw/rde")
          (branch "master")
          (commit "4ea3b80d46ae795c86bddcf3e213a249b75afde5")
          (introduction
           (make-channel-introduction
            "257cebd587b66e4d865b3537a9a88cccd7107c95"
            (openpgp-fingerprint
             "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0"))))
        (channel
          (name 'lotus-rde)
          (url "https://github.com/sharad/lotus-rde.git")
          (branch "master")
          (commit "7d380eb884fdf6ae5fad73af7e33c9acbbde7119"))
        (channel
          (name 'lotus)
          (url "https://github.com/sharad/guix")
          (branch "master")
          (commit "5398848b4f5a84b2742bcf6461aba15c96108396"))
        (channel
          (name 'guix-android)
          (url "https://framagit.org/tyreunom/guix-android.git")
          (branch "master")
          (commit "e5f52bd57275e404db74bf03b541bb62f7d73d58"))
        (channel
          (name 'guix)
          (url "https://git.guix.gnu.org/guix.git")
          (branch "master")
          (commit "0999b3268ce66586b98f99e392d0da4c21816525")
          (introduction
           (make-channel-introduction
            "9edb3f66fd807b096b48283debdcddccfea34bad"
            (openpgp-fingerprint
             "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))))

core-channels
