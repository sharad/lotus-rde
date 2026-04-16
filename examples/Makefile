

CHANNELS_FILE = ./env/guix/rde-configs/env/guix/channels.scm
CHANNELS_FILE_LOCAL_RDE = ./env/guix/rde-configs/env/guix/channels-ci.scm
CHANNELS_FILE_LATEST_GUIX = ./env/guix/rde-configs/env/guix/channels-ci-latest-guix.scm

GUIXTM_FLAGS = $(if $(strip $(SUBSTITUTE_URLS)), --substitute-urls='$(SUBSTITUTE_URLS)')


GUIXTM = GUILE_LOAD_PATH="../src:../tests:./src" guix time-machine -L ./env/guix -C ${CHANNELS_FILE}$(GUIXTM_FLAGS)
GUIXTM_LOCAL_RDE = guix time-machine -L ./env/guix -C ${CHANNELS_FILE_LOCAL_RDE}$(GUIXTM_FLAGS)
GUIXTM_LATEST_GUIX = guix time-machine -L ./env/guix -C ${CHANNELS_FILE_LATEST_GUIX}$(GUIXTM_FLAGS)

GUIX = $(GUIXTM) --

SRC_DIR = ./src
CONFIGS = ${SRC_DIR}/rde-configs/configs.scm
PULL_EXTRA_OPTIONS=
# --allow-downgrades

ROOT_MOUNT_POINT=/mnt

VERSION=latest

repl: ares

ares: env/sync
	${GUIX} shell -L ./env/guix -L ./env/dev guile guile-ares-rs \
	-e '(@ (rde-configs env dev packages) guix-package)' \
	-e '(@ (rde-configs env dev packages) channels-package)' \
	-- guile \
	-L ./env/guix \
	-L ./env/dev \
	-c \
"(begin (use-modules (guix gexp)) #;(load gexp reader macro globally) \
((@ (ares server) run-nrepl-server)))"

env/guix/rde/env/guix/channels.scm: ../env/guix/rde/env/guix/channels.scm
	mkdir -p $(@D)
	cat $< > $@
	echo -e "\n;;; This is an automatic copy of RDE's channels.scm" >> $@
	echo -e ";;; Do not edit it manually" >> $@

env/sync: env/guix/rde/env/guix/channels.scm
guix: env/sync

guix-pull:
	guix pull -L ./env/guix -C ${CHANNELS_FILE}

guix-update-channel:
	echo ';; -*- mode: scheme; -*-' > $(CHANNELS_FILE)
	echo ';;; rde --- Reproducible development environment.' >> $(CHANNELS_FILE)
	echo ';;;' >> $(CHANNELS_FILE)
	echo ';;; SPDX-FileCopyrightText: 2024, 2025 Andrew Tropin <andrew@trop.in>' >> $(CHANNELS_FILE)
	echo ';;;' >> $(CHANNELS_FILE)
	echo ';;; SPDX-License-Identifier: GPL-3.0-or-later' >> $(CHANNELS_FILE)
	echo >> $(CHANNELS_FILE)
	echo '(define-module (rde-configs env guix channels)' >> $(CHANNELS_FILE)
	echo '#:use-module ((rde env guix channels) #:prefix rde:)' >> $(CHANNELS_FILE)
	echo '#:use-module (guix channels)' >> $(CHANNELS_FILE)
	echo '#:export (core-channels))' >> $(CHANNELS_FILE)
	echo >> $(CHANNELS_FILE)
	echo -n "(define core-channels (cons (channel (name 'lotus-rde) (url \"https://github.com/sharad/lotus-rde.git\") (branch \"master\") (commit \"" >> $(CHANNELS_FILE)
	git rev-parse --default HEAD | tr -d '\n' >> $(CHANNELS_FILE)
	echo '"))' >> $(CHANNELS_FILE)
	echo ' ;; (introduction'  >> $(CHANNELS_FILE)
	echo ' ;; (make-channel-introduction'  >> $(CHANNELS_FILE)
	echo ' ;; "257cebd587b66e4d865b3537a9a88cccd7107c95"'  >> $(CHANNELS_FILE)
	echo ' ;;  (openpgp-fingerprint'  >> $(CHANNELS_FILE)
	echo ' ;;  "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0")))'  >> $(CHANNELS_FILE)
	echo 'rde:core-channels)) core-channels' >> $(CHANNELS_FILE)
	guix style --whole-file $(CHANNELS_FILE)


ifneq ($(strip $(RDE_TARGET)),)

rde/home/build: guix
	${GUIX} home \
	build ${CONFIGS}

rde/home/reconfigure: guix
	${GUIX} home \
	reconfigure ${CONFIGS}

rde/system/build: guix
	${GUIX} system \
	build ${CONFIGS}

rde/system/reconfigure: guix
	${GUIX} system \
	reconfigure ${CONFIGS}

endif



ixy/home/build: guix
	RDE_TARGET=ixy-home ${GUIX} home \
	build ${CONFIGS}

ixy/home/reconfigure: guix
	RDE_TARGET=ixy-home ${GUIX} home \
	reconfigure ${CONFIGS}

ixy/system/build: guix
	RDE_TARGET=ixy-system ${GUIX} system \
	build ${CONFIGS}

ixy/system/reconfigure: guix
	RDE_TARGET=ixy-system ${GUIX} system \
	reconfigure ${CONFIGS}

cow-store:
	sudo herd start cow-store ${ROOT_MOUNT_POINT}

ixy/system/init: guix
	RDE_TARGET=ixy-system ${GUIX} system \
	init ${CONFIGS} ${ROOT_MOUNT_POINT}

target:
	mkdir -p target

live/image/build: guix
	RDE_TARGET=live-system ${GUIX} system image --image-type=iso9660 \
	${CONFIGS}

target/rde-live.iso: guix target
	RDE_TARGET=live-system ${GUIX} system image --image-type=iso9660 \
	${CONFIGS} -r target/rde-live-tmp.iso
	mv -f target/rde-live-tmp.iso target/rde-live.iso

target/release:
	mkdir -p target/release

# TODO: Prevent is rebuilds.
release/rde-live-x86_64: target/rde-live.iso target/release
	cp -df $< target/release/rde-live-${VERSION}-x86_64.iso
	gpg -ab target/release/rde-live-${VERSION}-x86_64.iso

minimal-emacs: guix
	${GUIX} shell --pure -Df ./src/rde-configs/minimal-emacs.scm \
	-E '.*GTK.*|.*XDG.*|.*DISPLAY.*' \
	--rebuild-cache -- emacs -q \
	--eval "(load \"~/.config/emacs/early-init.el\")"
	#--eval "(require 'feature-loader-portable)"

minimal/home/build: guix
	${GUIX} home build ./src/rde-configs/minimal.scm

minimal/home/build/ci:
	${GUIXTM_LOCAL_RDE} -- \
	home build ./src/rde-configs/minimal.scm

minimal/home/build/ci-no-auth:
	${GUIXTM_LOCAL_RDE} \
	--disable-authentication -- \
	home build ./src/rde-configs/minimal.scm

minimal/home/build/ci-latest-guix:
	${GUIXTM_LATEST_GUIX} -- \
	home build ./src/rde-configs/minimal.scm

minimal/home/build/ci-latest-guix-no-auth:
	${GUIXTM_LATEST_GUIX} \
	--disable-authentication -- \
	home build ./src/rde-configs/minimal.scm

cloud-rde: guix
	${GUIX} system image -e '(@ (rde-configs hosts cloud) cloud-image)'

clean-target:
	rm -rf ./target

clean: clean-target
