







GUIXTM_FLAGS      += --debug=3
GUIXTM_FLAGS      += $(if $(strip $(SUBSTITUTE_URLS)), --substitute-urls='$(SUBSTITUTE_URLS)')
GUIXTM_PREFIX_ENV +=
GUIXTM_COMMAND     = guix time-machine

GUIXTM             = $(GUIXTM_PREFIX_ENV) $(GUIXTM_COMMAND) -C ${CHANNELS_FILE} $(GUIXTM_FLAGS)

GUIX_FLAGS        += --debug=3 --verbosity=3
GUIX_SYSTEM_FLAGS += $(GUIX_FLAGS)
GUIX_HOME_FLAGS   += $(GUIX_FLAGS)

GUIX = $(GUIXTM) --



ROOT_MOUNT_POINT=/mnt




## -- pkg-exec targets
PKGEXEC = pkg-exec
# Pattern rule: any target that looks like subdir/something
$(PKGEXEC)/%:
	mkdir -p /tmp/guix-build-workspace/build/tmp
	sudo-run chmod +rx /var/log
	sudo mount -o remount,rw /gnu
	$(MAKE) $*
	sudo mount -o remount,ro /gnu
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(PKGEXEC)/%
## -- pkg-exec targets

## -- sudo targets
SUDO = sudo
# Pattern rule: any target that looks like subdir/something
$(SUDO)/%:
	sudo $(MAKE) $*
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(SUDO)/%
## -- sudo targets

## -- examples dir targets
SUBDIR = examples
# Pattern rule: any target that looks like subdir/something
$(SUBDIR)/%:
	$(MAKE) -C $(SUBDIR) $*
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(SUBDIR)/%
## -- examples dir targets

## -- sudo targets
CMD = cmd
# Pattern rule: any target that looks like subdir/something
$(CMD)/%:
	${GUIX} $* $(GUIX_FLAGS)
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(CMD)/%
## -- sudo targets


RDE_HOST ?= $(HOST)
export RDE_HOST
RDE_USER ?= $(USER)
export RDE_USER
RDE_TARGET ?= system
export RDE_TARGET


rde/home/build:
	RDE_TARGET=home ${GUIX} home $(GUIX_HOME_FLAGS) \
	build ${CONFIGS}

rde/home/reconfigure:
	RDE_TARGET=home ${GUIX} home $(GUIX_HOME_FLAGS) \
	reconfigure ${CONFIGS}


/tmp/.cow-store-start:
	sudo herd start cow-store ${ROOT_MOUNT_POINT}
	touch /tmp/.cow-store-start

cow-store: /tmp/.cow-store-start


rde/system/init: guix /tmp/.cow-store-start
	RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
	init ${CONFIGS} ${ROOT_MOUNT_POINT}

rde/system/build:
	RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
	build ${CONFIGS}

rde/system/reconfigure:
	RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
	reconfigure ${CONFIGS}



