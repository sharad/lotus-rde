;; -*- mode: scheme; -*-
;;; rde --- Reproducible development environment.
;;;
;;; SPDX-FileCopyrightText: 2024, 2025 Andrew Tropin <andrew@trop.in>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (rde-configs env guix channels)
#:use-module ((rde env guix channels) #:prefix rde:)
#:use-module (guix channels)
#:export (core-channels))

(define core-channels (cons (channel (name 'lotus-rde) (url "https://github.com/sharad/lotus-rde.git") (branch "master") (commit "