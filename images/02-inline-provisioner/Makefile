VALID_ENVS := dev staging production
ENV ?= $(if $(filter $(VALID_ENVS),$(word 2,$(MAKECMDGOALS))),$(word 2,$(MAKECMDGOALS)),dev)
SCRIPTS_DIR := ../00-scripts

.PHONY: init fmt validate build help $(VALID_ENVS)

help:
	@echo "Targets:"
	@echo "  make init"
	@echo "  make fmt"
	@echo "  make validate ENV=dev"
	@echo "  make build ENV=staging"

init:
	packer init .

fmt:
	packer fmt -check .

validate:
	PROJECT_DIR=$(CURDIR) $(SCRIPTS_DIR)/validate.sh $(ENV)

build:
	PROJECT_DIR=$(CURDIR) $(SCRIPTS_DIR)/build.sh $(ENV)

$(VALID_ENVS):
	@: