#!/bin/sh
set -eu

# Usage:
#   ./guix-update-current-channels.sh
#


cat <<'EOF'
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
EOF

guix describe --format=channels

cat <<'EOF'
)

core-channels
EOF


