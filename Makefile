include Makefile.versions.mk

export RELEASE_NAME ?= $(VERSION)~dev
export RELEASE ?= 1

BUILD_SYSTEMS := bookworm
BUILD_VARIANTS := minimal mate lxde i3 kde xfce4 kde gnome openmediavault containers
BUILD_ARCHS := arm64
BUILD_MODELS := rock64 rockpro64 quartz64a quartz64b rockpi4b rock5b

IMAGE_SUFFIX := $(RELEASE_NAME)-$(RELEASE)

all:

ifeq (,$(BOARD_TARGET))

all:
	@echo $(addsuffix -board,$(BUILD_MODELS))

%-board:
	make BOARD_TARGET=$(patsubst %-board,%,$@)

else ifeq (,$(filter $(BUILD_MODELS), $(BOARD_TARGET)))
$(error Unsupported BOARD_TARGET)
endif

ifneq (,$(CI))
include Makefile.latest.mk
endif

include Makefile.package.mk
include Makefile.system.mk
include Makefile.variants.mk
include Makefile.dev.mk
