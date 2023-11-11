VARIANTS := $(foreach system, $(BUILD_SYSTEMS), $(foreach variants, $(BUILD_VARIANTS), $(system)-$(variants)))

ifneq (,$(BOARD_TARGET))

variants:
	@echo $(VARIANTS)

$(addsuffix -armhf, $(VARIANTS)): %-armhf: %-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-armhf.img.xz
$(addsuffix -arm64, $(VARIANTS)): %-arm64: %-$(BOARD_TARGET)-$(IMAGE_SUFFIX)-arm64.img.xz

.PHONY: linux-variants		# build all linux variants
linux-variants: \
	bookworm-minimal-arm64 \
	linux-virtual

all: linux-variants

endif
