







GUIXTM_FLAGS       += --debug=3
GUIXTM_FLAGS       += $(if $(strip $(SUBSTITUTE_URLS)), --substitute-urls='$(SUBSTITUTE_URLS)')
GUIXTM_PREFIX_ENV  +=

GUIXTM_COMMAND     = guix time-machine -C ${CHANNELS_FILE} $(GUIXTM_FLAGS) --




GUIX_COMMAND       ?= ${GUIXTM_COMMAND}

GUIX_FULL_COMMAND  = $(GUIXTM_PREFIX_ENV) $(GUIX_COMMAND)

GUIX_FLAGS         += $(if $(strip $(SUBSTITUTE_URLS)), --substitute-urls='$(SUBSTITUTE_URLS)')

GUIX_DEBUG_FLAG    =  --debug=3
GUIX_VERBOSE_FLAG  =  --verbosity=3


GUIX_CMD_FLAGS     += $(GUIX_FLAGS) # $(GUIX_DEBUG_FLAG)


GUIX_SYSTEM_FLAGS  += $(GUIX_FLAGS) # $(GUIX_DEBUG_FLAG)
# $(GUIX_DEBUG_FLAG):: --debug=1
# causing
# guix/ui.scm:1033:18: In procedure struct-vtable: Wrong type argument in position 1 (expecting struct): #f


GUIX_HOME_FLAGS    += $(GUIX_FLAGS) $(GUIX_DEBUG_FLAG)

GUIX_PROFILE_FLAGS += $(GUIX_FLAGS) $(GUIX_DEBUG_FLAG)

GUIX_PROFILE_INSTALL_FLAGS += $(GUIX_PROFILE_FLAGS)
GUIX_PROFILE_UPGRADE_FLAGS += $(GUIX_PROFILE_FLAGS)
GUIX_PROFILE_CLEAR_FLAGS   += $(GUIX_PROFILE_FLAGS)


GUIX_PKG_BUILD_FLAGS   += $(GUIX_FLAGS) $(GUIX_DEBUG_FLAG)
GUIX_PKG_INSTALL_FLAGS += $(GUIX_FLAGS) $(GUIX_DEBUG_FLAG)
GUIX_PKG_SEARCH_FLAGS  += $(GUIX_FLAGS) $(GUIX_DEBUG_FLAG)

GUIX_REPL_FLAGS          += $(GUIX_FLAGS) # $(GUIX_DEBUG_FLAG)

GUIX = $(GUIX_FULL_COMMAND)



FIRST_GOAL := $(firstword $(MAKECMDGOALS))
ifneq ($(filter rde/profile/pkg/install/% rde/profile/pkg/remove/%,$(FIRST_GOAL)),)
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(ARGS):
	@:
endif

ifneq ($(filter rde/pkg/build rde/pkg/install rde/pkg/search,$(FIRST_GOAL)),)
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(ARGS):
	@:
endif


ifeq ($(PROFILE_BASE_DIR),)
PROFILE_BASE_DIR := $(shell readlink $(PROFILE_BASE_DIR_LINK) 2>/dev/null)
ifeq ($(PROFILE_BASE_DIR),)
$(error $(CURDIR)/$(PROFILE_BASE_DIR_LINK) does not exist. Run 'make init' first.)
endif
endif

ROOT_MOUNT_POINT=/mnt


RDE_HOST ?= $(shell hostname)
export RDE_HOST
RDE_USER ?= $(USER)
export RDE_USER
RDE_TARGET ?= system
export RDE_TARGET






SUDO_PRESERVE_ENV_VARS = RDE_HOST,RDE_USER,RDE_TARGET,GUIX_COMMAND





# # calculate
# GNU_STORE_MINIMUM_AVAIL_MEGABYTES=300
# # make 21% of available space of /gnu/store
# GUIX_CLEANUP_MIN_SPACE_PERCENTAGE=21
# GNU_STORE_AVAIL_MEGABYTES="$(df -BM --output=avail  /gnu/store | sed -n -e 's/[^[:digit:]]//g' -e 2p)" # not used
# GNU_STORE_SIZE_GIGABYTES="$(df -BG --output=size  /gnu/store | sed -n -e 's/[^[:digit:]]//g' -e 2p)"
# GUIX_CLEANUP_MIN_SPACE="$(expr $GNU_STORE_SIZE_GIGABYTES '*' $GUIX_CLEANUP_MIN_SPACE_PERCENTAGE / 100)"
# # calculate

# DEFAULT_SYSTEM_ABONDONED_PKG_CLEANUP_MIN_SPACE=${GUIX_CLEANUP_MIN_SPACE}G
# DEFAULT_SYSTEM_ABONDONED_PKG_CLEANUP_MIN_TIME=30d
# DEFAULT_SYSTEM_GENERATION_CLEANUP_TIME=10m
# DEFAULT_USER_GENERATION_CLEANUP_TIME=96h

SYSTEM_GENERATION_CLEANUP_TIME         ?= 10m
USER_GENERATION_CLEANUP_TIME           ?= 96h
SYSTEM_ABONDONED_PKG_CLEANUP_MIN_TIME  ?= 30d
SYSTEM_ABONDONED_PKG_CLEANUP_MIN_SPACE ?= 10G



$(TARGET_DIR):
	mkdir -p $(TARGET_DIR)

$(PROFILE_BASE_DIR_LINK): $(TARGET_DIR)
	echo Create $(PROFILE_BASE_DIR_LINK) link



## -- pkg-exec targets
PKGEXEC = pkg-exec
# Pattern rule: any target that looks like subdir/something
$(PKGEXEC)/%:
	mkdir -p /tmp/guix-build-workspace/build/tmp
	chmod +rx /var/log
	mount -o remount,rw /gnu
	$(MAKE) $*
	mount -o remount,ro /gnu
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(PKGEXEC)/%
## -- pkg-exec targets

## -- sudo targets
SUDO = sudo
# Pattern rule: any target that looks like subdir/something
SUDO_CMD = sudo --preserve-env=$(SUDO_PRESERVE_ENV_VARS)
ifdef SUDOPASSPASS
SUDO_CMD = printf '%s\n' "$(SUDOPASSPASS)" | \
	sudo -S --preserve-env=$(SUDO_PRESERVE_ENV_VARS)
endif

$(SUDO)/%:
	@$(SUDO_CMD) $(MAKE) $*

# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(SUDO)/%
## -- sudo targets


## -- git precommand
GIT_PULL = git
# Pattern rule: any target that looks like subdir/something
$(GIT_PULL)/%:
	$(MAKE) git-pull
	$(MAKE) $*
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(GIT_PULL)/%
## -- git precommand


## -- guix precommand
GUIX_PULL = pull
# Pattern rule: any target that looks like subdir/something
$(GUIX_PULL)/%:
	$(MAKE) guix-pull-nochannel
	$(MAKE) $*
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(GUIX_PULL)/%
## -- guix precommand


## -- examples dir targets
SUBDIR = examples
# Pattern rule: any target that looks like subdir/something
$(SUBDIR)/%:
	$(MAKE) -C $(SUBDIR) $*
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(SUBDIR)/%
## -- examples dir targets

## -- guix subcmd targets
CMD = cmd
# Pattern rule: any target that looks like subdir/something
$(CMD)/%:
	${GUIX} $* $(GUIX_CMD_FLAGS)
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(CMD)/%
## -- guix subcmd targets














rde/home/build:
	RDE_TARGET=home ${GUIX} home $(GUIX_HOME_FLAGS) \
	build ${CONFIGS} && \
	make guix-update-current-channels-force

rde/home/reconfigure:
	RDE_TARGET=home ${GUIX} home $(GUIX_HOME_FLAGS) \
	reconfigure ${CONFIGS} && \
	make guix-update-current-channels-force


/tmp/.cow-store-start:
	herd start cow-store ${ROOT_MOUNT_POINT}
	touch /tmp/.cow-store-start

cow-store: /tmp/.cow-store-start


rde/system/init: guix /tmp/.cow-store-start
	mount -o rw /boot
	mount -o rw /boot/efi
	RDE_SYSINIT=init RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
	init ${CONFIGS} ${ROOT_MOUNT_POINT} && \
	make guix-update-current-channels-force
	umount /boot/efi
	umount /boot

rde/system/build:
	RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
	build ${CONFIGS} && \
	make guix-update-current-channels-force

rde/system/reconfigure:
	mount -o rw /boot
	RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
	reconfigure ${CONFIGS} && \
	make guix-update-current-channels-force
	umount /boot


rde/gc/clean:
	$(GUIX) gc -d ${SYSTEM_ABONDONED_PKG_CLEANUP_MIN_TIME} -C ${SYSTEM_ABONDONED_PKG_CLEANUP_MIN_SPACE}






rde/profile/install/%: $(TARGET_DIR)
	RDE_TARGET=manifest RDE_PROFILE_NAME=$* RDE_PROFILE_MODE=install ${GUIX} package $(GUIX_PROFILE_INSTALL_FLAGS) \
	-m ${CONFIGS} -p $(PROFILE_BASE_DIR)/$*/profile.d/profile || \
	RDE_TARGET=manifest RDE_PROFILE_NAME=$* RDE_PROFILE_MODE=mod ${GUIX} package $(GUIX_PROFILE_INSTALL_FLAGS) \
	-m ${CONFIGS} -p $(PROFILE_BASE_DIR)/$*/profiles.d/profile

rde/profile/upgrade/%: $(TARGET_DIR)
	RDE_TARGET=manifest RDE_PROFILE_NAME=$* RDE_PROFILE_MODE=upgrade ${GUIX} upgrade $(GUIX_PROFILE_UPGRADE_FLAGS) \
	-p $(PROFILE_BASE_DIR)/$*/profiles.d/profile

rde/profile/clear/%: $(TARGET_DIR)
	RDE_TARGET=manifest RDE_PROFILE_NAME=$* RDE_PROFILE_MODE=clear ${GUIX} package $(GUIX_PROFILE_CLEAR_FLAGS) \
	-p $(PROFILE_BASE_DIR)/$*/profiles.d/profile --delete-generations=$(USER_GENERATION_CLEANUP_TIME)








rde/profile/pkg/install/%: $(TARGET_DIR)
ifeq ($*,)
	RDE_PROFILE_MODE=install ${GUIX} install $(GUIX_PROFILE_INSTALL_FLAGS) \
	$(ARGS)
else
	RDE_PROFILE_MODE=install ${GUIX} install $(GUIX_PROFILE_INSTALL_FLAGS) \
	-p $(PROFILE_BASE_DIR)/$*/profiles.d/profile $(ARGS)
endif

rde/profile/pkg/remove/%: $(TARGET_DIR)
ifeq ($*,)
	RDE_PROFILE_MODE=remove ${GUIX} remove $(GUIX_PROFILE_REMOVE_FLAGS) \
	$(ARGS)
else
	RDE_PROFILE_MODE=remove ${GUIX} remove $(GUIX_PROFILE_REMOVE_FLAGS) \
	-p $(PROFILE_BASE_DIR)/$*/profiles.d/profile $(ARGS)
endif

rde/pkg/build:
	RDE_PROFILE_MODE=build ${GUIX} build $(GUIX_PKG_BUILD_FLAGS) $(ARGS)

rde/pkg/install:
	RDE_PROFILE_MODE=install ${GUIX} install $(GUIX_PKG_INSTALL_FLAGS) $(ARGS)

rde/pkg/search:
	RDE_PROFILE_MODE=search ${GUIX} search $(GUIX_PKG_SEARCH_FLAGS) $(ARGS)

rde/repl:
	RDE_PROFILE_MODE=repl ${GUIX} repl $(GUIX_REPL_FLAGS) $(ARGS)


.PHONY: rde/profile/install/% rde/profile/upgrade/% rde/profile/clear/%
.PHONY: rde/profile/pkg/install/% rde/profile/pkg/remove/%
.PHONY: rde/pkg/build rde/pkg/install rde/pkg/search
.PHONY: rde/pkg/repl



rde/system/clear:
	$(GUIX) system delete-generations ${SYSTEM_GENERATION_CLEANUP_TIME}


# function pkgmgr_get_available_pcent_free_in_part()
# {
#     PART=$1
#     if [ ! "$PART" ] || [ ! -e "$PART" ]
#     then
#         warn No partition provided, PART=$PART not exists
#         return 1
#     fi
#     \df -BM   --output=pcent "${PART}" | tail -1 | sed 2d | tr -d % | xargs expr 100 -
# }

# function pkgmgr_has_enough_MB_in_part()
# {
#     PART=$1
#     if [ ! "$PART" ] || [ ! -e "$PART" ]
#     then
#         warn No partition provided, PART=$PART not exists
#         return 1
#     fi
#     MIN_SPACE_MB=${2:-2048}     # 2 GB
#     CURR_SPACE_MB=$(pkgmgr_get_available_MB_in_part "${PART}")

#     info test $CURR_SPACE_MB -gt $MIN_SPACE_MB
#     test $CURR_SPACE_MB -gt $MIN_SPACE_MB
# }


# function pkgmgr_has_enough_pcent_in_part()
# {
#     PART=$1
#     if [ ! "$PART" ] || [ ! -e "$PART" ]
#     then
#         warn No partition provided, PART=$PART not exists
#         return 1
#     fi
#     MIN_SPACE_PCENT=${2:-5}
#     CURR_SPACE_PCENT=$(pkgmgr_get_available_pcent_free_in_part "${PART}")

#     info test $CURR_SPACE_PCENT -gt $MIN_SPACE_PCENT
#     test $CURR_SPACE_PCENT -gt $MIN_SPACE_PCENT
# }


# function pkgmgr_has_enough_space_in_part()
# {
#     PART="$1"
#     if [ ! "$PART" ] || [ ! -e "$PART" ]
#     then
#         warn No partition provided, PART=$PART not exists
#         return 1
#     fi
#     pkgmgr_has_enough_MB_in_part "${PART}" && pkgmgr_has_enough_pcent_in_part "${PART}"
# }








    # # calculate
    # GNU_STORE_MINIMUM_AVAIL_MEGABYTES=300
    # # make 21% of available space of /gnu/store
    # GUIX_CLEANUP_MIN_SPACE_PERCENTAGE=21
    # GNU_STORE_AVAIL_MEGABYTES="$(df -BM --output=avail  /gnu/store | sed -n -e 's/[^[:digit:]]//g' -e 2p)" # not used
    # GNU_STORE_SIZE_GIGABYTES="$(df -BG --output=size  /gnu/store | sed -n -e 's/[^[:digit:]]//g' -e 2p)"
    # GUIX_CLEANUP_MIN_SPACE="$(expr $GNU_STORE_SIZE_GIGABYTES '*' $GUIX_CLEANUP_MIN_SPACE_PERCENTAGE / 100)"
    # # calculate


		# DEFAULT_SYSTEM_ABONDONED_PKG_CLEANUP_MIN_SPACE=${GUIX_CLEANUP_MIN_SPACE}G
		# DEFAULT_SYSTEM_ABONDONED_PKG_CLEANUP_MIN_TIME=30d
		# DEFAULT_SYSTEM_GENERATION_CLEANUP_TIME=10m
		# DEFAULT_USER_GENERATION_CLEANUP_TIME=96h




    #     sudo_run truncate -s 1k -c /var/log/messages
    #     sudo_run chmod og+rx  /var/log



		#             ignore-error running info guix package --delete-generations=${USER_GENERATION_CLEANUP_TIME} # for "01-guixprofile"

		#             for profile in "${LOCAL_GUIX_EXTRA_PROFILES[@]}"
		#             do
		#                 profile_container_path="${LOCAL_GUIX_EXTRA_PROFILE_CONTAINER_DIR}/${profile}"
		#                 manifest_path="${profile_container_path}/manifest.scm"
		#                 profile_path="${profile_container_path}/profiles.d/profile"
		#                 broken_path="${profile_container_path}/broken"

		#                 mkdir -p "${broken_path}"
		#                 find "${profile_container_path}/profiles.d" -xtype l -exec mv {} "${broken_path}" \;

		#                 if [ -f "${manifest_path}" -a -f "${profile_path}/etc/profile" ]
		#                 then
		#                     ignore-error running info guix package -p "${profile_path}" --delete-generations=${USER_GENERATION_CLEANUP_TIME}
		#                     # pkgmgr_sync_sleep_sync 5s
		#                 else
		#                     warn file "${profile_path}"/etc/profile not exist, for "${profile_path}"
		#                 fi
		#                 unset profile_path
		#                 unset profile
		#             done


		#             ignore-error running info sudo_run -E guix system delete-generations ${SYSTEM_GENERATION_CLEANUP_TIME}
		#             pkgmgr_sync_sleep_sync 5s
		#             ignore-error running info guix gc -d ${SYSTEM_ABONDONED_PKG_CLEANUP_MIN_TIME} -C  ${SYSTEM_ABONDONED_PKG_CLEANUP_MIN_SPACE}
