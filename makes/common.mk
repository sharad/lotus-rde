







GUIXTM_FLAGS      += --debug=3
GUIXTM_FLAGS      += $(if $(strip $(SUBSTITUTE_URLS)), --substitute-urls='$(SUBSTITUTE_URLS)')
GUIXTM_PREFIX_ENV +=

GUIXTM_COMMAND     = guix time-machine -C ${CHANNELS_FILE} $(GUIXTM_FLAGS) --

GUIX_COMMAND      ?= ${GUIXTM_COMMAND}

GUIX_FULL_COMMAND  = $(GUIXTM_PREFIX_ENV) $(GUIX_COMMAND)

GUIX_FLAGS        += --verbosity=3
GUIX_FLAGS        += $(if $(strip $(SUBSTITUTE_URLS)), --substitute-urls='$(SUBSTITUTE_URLS)')
GUIX_SYSTEM_FLAGS += $(GUIX_FLAGS) --debug=3
GUIX_HOME_FLAGS   += $(GUIX_FLAGS) --debug=3

GUIX = $(GUIX_FULL_COMMAND)




ROOT_MOUNT_POINT=/mnt


RDE_HOST ?= $(shell hostname)
export RDE_HOST
RDE_USER ?= $(USER)
export RDE_USER
RDE_TARGET ?= system
export RDE_TARGET



SUDO_PRESERVE_ENV_VARS = RDE_HOST,RDE_USER,RDE_TARGET,GUIX_COMMAND




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
	${GUIX} $* $(GUIX_FLAGS)
# Optional: Add a phony declaration if targets aren't actual files
.PHONY: $(CMD)/%
## -- guix subcmd targets














rde/home/build: guix-update-current-channels-force
	RDE_TARGET=home ${GUIX} home $(GUIX_HOME_FLAGS) \
	build ${CONFIGS}

rde/home/reconfigure: guix-update-current-channels-force
	RDE_TARGET=home ${GUIX} home $(GUIX_HOME_FLAGS) \
	reconfigure ${CONFIGS}


/tmp/.cow-store-start:
	herd start cow-store ${ROOT_MOUNT_POINT}
	touch /tmp/.cow-store-start

cow-store: /tmp/.cow-store-start


rde/system/init: guix /tmp/.cow-store-start guix-update-current-channels-force
	mount -o rw /boot
	mount -o rw /boot/efi
	RDE_SYSINIT=init RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
	init ${CONFIGS} ${ROOT_MOUNT_POINT}
	umount /boot/efi
	umount /boot

rde/system/build: guix-update-current-channels-force
	RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
	build ${CONFIGS}

rde/system/reconfigure: guix-update-current-channels-force
	mount -o rw /boot
	RDE_TARGET=system ${GUIX} system $(GUIX_SYSTEM_FLAGS) \
	reconfigure ${CONFIGS}
	umount /boot





# rde/profile/install:
# 	${GUIX} package $(GUIX_PROFILE_FLAGS) -m $(PROFILE_BASE_DIR)/manifest.scm -p $(PROFILE_BASE_DIR)/profile.d/$(PROFILE) || \
# 		${GUIX} package $(GUIX_PROFILE_FLAGS) -m $(PROFILE_BASE_DIR)/manifest-MOD.scm -p $(PROFILE_BASE_DIR)/profile.d/$(PROFILE)
# rde/profile/update:
# 	${GUIX} package $(GUIX_PROFILE_FLAGS) -u -p $(PROFILE_BASE_DIR)/profile.d/$(PROFILE)
# rde/profile/clear:




rde/profile/install:
	RDE_TARGET=manifest RDE_PROFILE_NAME=dev ${GUIX} package $(GUIX_HOME_FLAGS) \
	-m ${CONFIGS} -p /tmp/test-profile




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
