.PHONY: help
help:
	@echo Available targets:
	@grep -h '^.PHONY: .*#' Makefile* | cut -d: -f2- | expand -t20 | sort
	@echo
	@echo Extra targets:
	@echo " " $$(grep -h '^.PHONY: [^#]*$$' Makefile* | cut -d: -f2- | sort)
