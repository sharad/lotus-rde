
BUILD_TYPE ?= default


MAKE_TMPL_PATH = makes
MAKE_SRC_FILES := $(wildcard ../$(MAKE_TMPL_PATH)/*.mk)
MAKE_DST_FILES := $(patsubst ../%,./%,$(MAKE_FILES))


RDE_GUIX_ENV_DIR_TMPL_PATH = env/guix/rde/env/guix
CHANNEL_ENV_SRC_FILES := $(wildcard ../$(RDE_GUIX_ENV_DIR_TMPL_PATH)/*.scm)
CHANNEL_ENV_DST_FILES := $(patsubst ../%,./%,$(CHANNEL_ENV_SRC_FILES))

RDE_CONFIG_GUIX_ENV_DIR_PATH = ./env/guix/rde-configs/env/guix


CHANNELS_RDE_CONFIGS_FILE        = $(RDE_CONFIG_GUIX_ENV_DIR_PATH)/channels.scm
CHANNELS_RDE_CONFIGS_LOCAL_FILE  = $(RDE_CONFIG_GUIX_ENV_DIR_PATH)/channels-ci.scm
CHANNELS_RDE_CONFIGS_LATEST_FILE = $(RDE_CONFIG_GUIX_ENV_DIR_PATH)/channels-ci-latest-guix.scm

CHANNEL_FILE_default = $(CHANNELS_RDE_CONFIGS_FILE)
CHANNEL_FILE_local   = $(CHANNELS_RDE_CONFIGS_LOCAL_FILE)
CHANNEL_FILE_latest  = $(CHANNELS_RDE_CONFIGS_LATEST_FILE)

CHANNELS_FILE = $(CHANNEL_FILE_$(BUILD_TYPE))


GUIXTM_FLAGS =  --debug=3
GUIXTM_FLAGS += $(if $(strip $(SUBSTITUTE_URLS)), --substitute-urls='$(SUBSTITUTE_URLS)')
GUIXTM_PREFIX_ENV = GUILE_LOAD_PATH="../src:../tests:./src"
GUIXTM_COMMAND = guix time-machine -L ./env/guix

GUIXTM = $(GUIXTM_PREFIX_ENV) $(GUIXTM_COMMAND) -C ${CHANNELS_FILE} $(GUIXTM_FLAGS)

GUIX = $(GUIXTM) --



SRC_DIR = ./src
CONFIGS ?= ${SRC_DIR}/rde-configs/configs.scm
PULL_EXTRA_OPTIONS=
# --allow-downgrades



include makes/common.mk

VERSION=latest


$(MAKE_TMPL_PATH)/%.mk: ../$(MAKE_TMPL_PATH)/%.mk
	  cp $< $@

$(RDE_GUIX_ENV_DIR_TMPL_PATH)/%.scm: ../$(RDE_GUIX_ENV_DIR_TMPL_PATH)/%.scm
	mkdir -p $(@D)
	{ \
	  cat $<; \
	  printf '\n;;; This is an automatic copy of RDE'\''s $(notdir $<)\n'; \
	  printf ';;; Do not edit it manually\n'; \
	} > $@






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






.PHONY: env/sync guix guix-update-channels
.PHONY: rde/build/guix rde/repl rde/describe

# env/sync: env/guix/rde/env/guix/channels.scm
env/sync: $(CHANNEL_ENV_DST_FILES) $(MAKE_DST_FILES)

guix: env/sync

guix-pull:
	guix pull -L ./env/guix -C ${CHANNELS_FILE}


SRC_COMMIT := $(shell git rev-list -1 HEAD -- ../src)

$(CHANNELS_RDE_CONFIGS_FILE): .channels-src-$(SRC_COMMIT)
.channels-src-%:
	./bin/rde-generate-channels.sh > $@
	guix style --whole-file $@
	rm -f .channels-src-*
	touch $@

guix-update-channels: $(CHANNELS_RDE_CONFIGS_FILE)


rde/build/guix: guix
	${GUIX} home $(GUIX_HOME_FLAGS) \
	build guix

rde/repl: guix
	${GUIX} home $(GUIX_HOME_FLAGS) \
	repl

rde/describe: guix
	${GUIX} home $(GUIX_HOME_FLAGS) \
	describe


# ixy/home/build: guix
# 	RDE_TARGET=ixy-home ${GUIX} home $(GUIX_HOME_FLAGS) \
# 	build ${CONFIGS}

# ixy/home/reconfigure: guix
# 	RDE_TARGET=ixy-home ${GUIX} home $(GUIX_HOME_FLAGS) \
# 	reconfigure ${CONFIGS}

# ixy/system/build: guix
# 	RDE_TARGET=ixy-system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
# 	build ${CONFIGS}

# ixy/system/reconfigure: guix
# 	RDE_TARGET=ixy-system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
# 	reconfigure ${CONFIGS}

target:
	mkdir -p target

live/image/build: guix
	RDE_HOST=live RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) image --image-type=iso9660 \
	${CONFIGS}

target/rde-live.iso: guix target
	RDE_HOST=live RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) image --image-type=iso9660 \
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
	${GUIX} home $(GUIX_HOME_FLAGS) build ./src/rde-configs/minimal.scm

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
	${GUIX} system $(GUIX_SYSTEM_FLAGS) image -e '(@ (rde-configs hosts cloud) cloud-image)'

clean-target:
	rm -rf ./target

clean: clean-target
