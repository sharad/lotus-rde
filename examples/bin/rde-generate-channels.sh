#!/bin/sh
set -eu

# rde-generate-channels.sh
#
# Replaces:
#   src/lotus-rde/tools/generate-channels.scm
#   bin/rde-generate-channels
#
# Usage:
#   ./rde-generate-channels.sh [output-file]
#
# Default:
#   stdout

OUTFILE="${1:-}"

git_commit() {
    git rev-list -1 HEAD -- ../src
}

generate_channels() {
    commit="$(git_commit)"

    cat <<EOF
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

(define core-channels
  (cons
   (channel
    (name 'lotus-rde)
    (url "https://github.com/sharad/lotus-rde.git")
    (branch "master")
    (commit "$commit"))
   rde:core-channels))

core-channels
EOF
}

if [ -n "$OUTFILE" ]; then
    mkdir -p "$(dirname "$OUTFILE")"

    tmp="$(mktemp "${TMPDIR:-/tmp}/channels.XXXXXX")"

    cleanup() {
        rm -f "$tmp"
    }
    trap cleanup EXIT INT TERM

    generate_channels > "$tmp"
    mv "$tmp" "$OUTFILE"

    if command -v guix >/dev/null 2>&1; then
        guix style --whole-file "$OUTFILE" || true
    fi

    printf '%s\n' "Generated $OUTFILE"
else
    generate_channels
fi


