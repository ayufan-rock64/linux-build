.PHONY: info
info:
	@echo version: $$(KERNEL_VERSION)
	@echo release: $$(KERNEL_RELEASE)

.PHONY: help
help:
	@echo Available targets:
	@grep -h '^.PHONY: .*#' Makefile* | cut -d: -f2- | expand -t20 | sort
	@echo
	@echo Extra targets:
	@echo " " $$(grep -h '^.PHONY: [^#]*$$' Makefile* | cut -d: -f2- | sort)

arm-trusted-firmware kernel kernel-mainline u-boot:
	@echo Run `make sync`
	@exit 1

.PHONY: sync		# download all subtrees
sync:
	repo init -u https://github.com/ayufan-rock64/linux-manifests -b default --depth=1 --no-clone-bundle
	repo sync -j 20 -c --force-sync

.PHONY: pull-trees		# merge all subtree into current tree
pull-trees:
	git subtree pull --prefix build https://github.com/rockchip-linux/build debian
	git subtree pull --prefix build https://github.com/rock64-linux/build debian

.PHONY: shell		# run docker shell to build image
shell:
	@echo Building environment...
	@docker build -q -t rock64-linux:build-environment environment/
	@echo Entering shell...
	@docker run --rm \
		-it \
		-e HOME -v $(HOME):$(HOME) \
		-e USER \
		-u $$(id -u):$$(id -g) \
		$$(id -Gz | xargs -0 -n1 -I{} echo "--group-add={}") \
		-v /etc/passwd:/etc/passwd:ro \
		-v /dev/bus/usb:/dev/bus/usb \
		--privileged \
		-h rock64-build-env \
		-v $(CURDIR):$(CURDIR) \
		-w $(CURDIR) \
		rock64-linux:build-environment
