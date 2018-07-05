.PHONY: help
help:
	@echo Available targets:
	@grep -h '^.PHONY: .*#' Makefile* | cut -d: -f2- | expand -t20 | sort
	@echo
	@echo Extra targets:
	@echo " " $$(grep -h '^.PHONY: [^#]*$$' Makefile* | cut -d: -f2- | sort)

.PHONY: shell		# run docker shell to build image
shell:
	@echo Entering shell...
	@docker run --rm \
		-it \
		-e HOME -v $(HOME):$(HOME) \
		-e USER \
		-u $$(id -u):$$(id -g) \
		$$(id -Gz | xargs -0 -n1 -I{} echo "--group-add={}") \
		-v /etc/passwd:/etc/passwd:ro \
		-v /dev/bus/usb:/dev/bus/usb \
		-v $(SSH_AUTH_SOCK):$(SSH_AUTH_SOCK) \
		-e SSH_AUTH_SOCK \
		--privileged \
		-h rock64-build-env \
		-v $(CURDIR):$(CURDIR) \
		-w $(CURDIR) \
		ayufan/rock64-dockerfiles:x86_64
