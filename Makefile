########################################################################################
# Globals
########################################################################################

# Use a standard bash shell, avoid zsh or fish
SHELL:=/bin/bash

# Configure the Docker commands
DOCKER_EXEC:=docker

# Select the default target, when you are simply running "make"
.DEFAULT_GOAL:=help

# Misc.
VENV:=source venv/bin/activate
PIP_COMPILE_EXEC:=pip-compile --quiet --generate-hashes --max-rounds=20 --upgrade

########################################################################################
# Basic targets
########################################################################################

.PHONY: help

help:  ## Print this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

########################################################################################
# Development
########################################################################################

.PHONY: init sync empty_venv upgrade_requirements_base upgrade_requirements_dev venv

init: sync dbt_deps ## Install pre-commit hooks
	$(VENV) && pre-commit install  # installs pre-commit hooks
	$(VENV) && pre-commit install --hook-type commit-msg  # installs commit-msg hooks

sync: venv ## Update virtual env based on new requirements
	$(VENV) && pip-sync requirements/dev.txt

empty_venv:
	rm -rf venv
	python3 -m venv venv

dbt_deps:  ## Dbt deps
	$(VENV) && dbt deps

venv: empty_venv
	$(VENV) && pip install --quiet --upgrade pip
	$(VENV) && pip install --quiet pip-tools

upgrade_requirements_base: venv
	$(VENV) && $(PIP_COMPILE_EXEC) \
		--output-file requirements/base.txt \
		requirements/base.in

upgrade_requirements_dev: venv
	$(VENV) && $(PIP_COMPILE_EXEC) \
		--output-file requirements/dev.txt \
		requirements/base.in \
		requirements/dev.in
