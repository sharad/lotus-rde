# pipefail is not POSIX complaint


CHANNELS_ENV=./env/guix/rde/env/guix/channels.scm
CHANNEL_THIS_ENV=./examples/env/guix/rde-configs/env/guix/channels.scm

GUIXTM=guix time-machine -C ./env/guix/rde/env/guix/channels.scm
GUIX=$(GUIXTM) --
EMACS=$(GUIX) shell emacs emacs-ox-html-stable-ids -- emacs
HUT=$(GUIX) shell hut -- hut

EXAMPLES_SRC_DIR=./examples/src
CONFIGS=${EXAMPLES_SRC_DIR}/rde-configs/configs.scm

DEV_ENV_LOAD_PATH=-L ./env/guix -L ./env/dev -L ./src
RDE_SRC_LOAD_PATH=-L ./env/guix -L ./env/dev -L ./src
EXAMPLES_LOAD_PATH=-L ${EXAMPLES_SRC_DIR}

DEV_SRC_LOAD_PATH=${RDE_SRC_LOAD_PATH} \
${EXAMPLES_LOAD_PATH} \
-L ./tests \
-L ./files/emacs/gider/src \

QEMU_BASE_ARGS= \
-m 8192 -smp 1 -enable-kvm \
-display gtk,zoom-to-fit=on \
-vga qxl
# -vga none -device virtio-gpu-pci
# -vga vmware
# -vga none -device qxl-vga,vgamem_mb=32


all: ares
	@echo default target

check:
	guile -L ./src -L ./tests -L ./files/emacs/gider/src -c \
	'((@ (rde test-runners) run-project-tests-cli))'

guix-pull:
	make -C examples guix-pull

guix-update-pull:
	guix pull
	guix pull --news;
	guix pull --news --details

guix-update-channels: guix-update-pull
	echo ';; -*- mode: scheme; -*-' > $(CHANNELS_ENV)
	echo ';;; rde --- Reproducible development environment.' >> $(CHANNELS_ENV)
	echo ';;;' >> $(CHANNELS_ENV)
	echo ';;; SPDX-FileCopyrightText: 2024, 2025 Andrew Tropin <andrew@trop.in>' >> $(CHANNELS_ENV)
	echo ';;;' >> $(CHANNELS_ENV)
	echo ';;; SPDX-License-Identifier: GPL-3.0-or-later' >> $(CHANNELS_ENV)
	echo >> $(CHANNELS_ENV)
	echo '(define-module (rde env guix channels)' >> $(CHANNELS_ENV)
	echo '  #:use-module (guix channels)' >> $(CHANNELS_ENV)
	echo '  #:export (core-channels))' >> $(CHANNELS_ENV)
	echo >> $(CHANNELS_ENV)
	echo '(define core-channels' >> $(CHANNELS_ENV)
	guix describe --format=channels >> $(CHANNELS_ENV)
	echo ')' >> $(CHANNELS_ENV)
	echo >> $(CHANNELS_ENV)
	echo core-channels >> $(CHANNELS_ENV)
	guix style --whole-file $(CHANNELS_ENV)


guix-update-this-channel:
	echo ';; -*- mode: scheme; -*-' > $(CHANNEL_THIS_ENV)
	echo ';;; rde --- Reproducible development environment.' >> $(CHANNEL_THIS_ENV)
	echo ';;;' >> $(CHANNEL_THIS_ENV)
	echo ';;; SPDX-FileCopyrightText: 2024, 2025 Andrew Tropin <andrew@trop.in>' >> $(CHANNEL_THIS_ENV)
	echo ';;;' >> $(CHANNEL_THIS_ENV)
	echo ';;; SPDX-License-Identifier: GPL-3.0-or-later' >> $(CHANNEL_THIS_ENV)
	echo >> $(CHANNEL_THIS_ENV)
	echo '(define-module (rde-configs env guix channels)' >> $(CHANNEL_THIS_ENV)
	echo '#:use-module ((rde env guix channels) #:prefix rde:)' >> $(CHANNEL_THIS_ENV)
	echo '#:use-module (guix channels)' >> $(CHANNEL_THIS_ENV)
	echo '#:export (core-channels))' >> $(CHANNEL_THIS_ENV)
	echo >> $(CHANNEL_THIS_ENV)
	echo -n "(define core-channels (cons (channel (name 'lotus-rde) (url \"https://github.com/sharad/lotus-rde.git\") (branch \"master\") (commit \"" >> $(CHANNEL_THIS_ENV)
	git rev-parse --default HEAD | tr -d '\n' >> $(CHANNEL_THIS_ENV)
	echo '"))' >> $(CHANNEL_THIS_ENV)
	echo ' ;; (introduction'  >> $(CHANNEL_THIS_ENV)
	echo ' ;; (make-channel-introduction'  >> $(CHANNEL_THIS_ENV)
	echo ' ;; "257cebd587b66e4d865b3537a9a88cccd7107c95"'  >> $(CHANNEL_THIS_ENV)
	echo ' ;;  (openpgp-fingerprint'  >> $(CHANNEL_THIS_ENV)
	echo ' ;;  "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0")))'  >> $(CHANNEL_THIS_ENV)
	echo 'rde:core-channels)) core-channels' >> $(CHANNEL_THIS_ENV)
	guix style --whole-file $(CHANNEL_THIS_ENV)


ares:
	${GUIX} shell ${DEV_ENV_LOAD_PATH} \
	guile-next guile-ares-rs \
	-e '(@ (rde env dev packages) guix-package)' \
	-- guile \
	${DEV_SRC_LOAD_PATH} \
	-c \
"(begin (use-modules (guix gexp)) #;(load gexp reader macro globally) \
((@ (ares server) run-nrepl-server)))"

repl: ares

examples/ixy/home/reconfigure:
	RDE_TARGET=ixy-home ${GUIX} home \
	${RDE_SRC_LOAD_PATH} ${EXAMPLES_LOAD_PATH} \
	reconfigure ${CONFIGS}

examples/ixy/home/build:
	RDE_TARGET=ixy-home ${GUIX} home \
	${RDE_SRC_LOAD_PATH} ${EXAMPLES_LOAD_PATH} \
	build ${CONFIGS}

examples/target/rde-live.iso:
	make -C examples target/rde-live.iso

qemu/1/run:
	qemu-system-x86_64 \
	${QEMU_BASE_ARGS} \
	-net user,hostfwd=tcp::10021-:22 -net nic -boot menu=on,order=d \
	-drive file=tmp/system.img

qemu/1/deploy:
	guix deploy tmp/config.scm --no-grafts

qemu/live/run-from-rde-iso: examples/target/rde-live.iso
	qemu-system-x86_64 \
	${QEMU_BASE_ARGS} \
	-net user,hostfwd=tcp::10022-:22 -net nic -boot menu=on,order=d \
	-drive media=cdrom,file=examples/target/rde-live.iso

doc/rde-tool-list.texi: doc/rde-tool-list.org
	pandoc doc/rde-tool-list.org -f org -t texinfo \
	-o doc/rde-tool-list.texi
	sed -i '1,3d' doc/rde-tool-list.texi

doc/rde.texi: doc/rde-tool-list.texi doc/getting-started.texi

doc/rde.info: doc/rde.texi
	makeinfo -o doc/rde.info doc/rde.texi

doc/rde.html: doc/rde.texi
	${GUIX} shell texinfo -- \
	makeinfo --html --no-split \
	--css-ref=/assets/manual.css \
	-c "EXTRA_HEAD=<meta name=\"viewport\" \
content=\"width=device-width, initial-scale=1\" />" \
	-o doc/rde.html doc/rde.texi

doc/rde.pdf: doc/rde.texi
	makeinfo --pdf -o doc/rde.pdf doc/rde.texi

README.html: README
	${EMACS} -Q --batch -l doc/html-export-config.el README \
	--funcall org-html-export-to-html

deploy-README.html: README.html
	${HUT} git update --readme README.html \
	--repo https://git.sr.ht/~abcdw/rde

clean:
	rm -rf target
	rm -f doc/rde.html
	rm -f doc/rde.pdf
	rm -f doc/rde.info
	rm -f doc/rde-tool-list.texi
