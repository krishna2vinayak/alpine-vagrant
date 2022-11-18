SHELL := /bin/bash
VERSION=$(shell jq -r .variables.version alpine.json)

help:
	@echo type build-alpine

build-alpine: alpine-${VERSION}-virtualbox.box

alpine-${VERSION}-virtualbox.box: provision.sh alpine.json vagrant.tpl
	rm -f $@ output-$@
	bash update-iso-checksum-url.sh
	packer build -only=alpine-${VERSION}-virtualbox -on-error=abort -force alpine.json
	@echo BOX successfully built!
	vagrant box add -f alpine-${VERSION} $@
	rm -f $@

.PHONY: build-alpine