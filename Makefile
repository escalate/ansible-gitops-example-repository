SHELL = /bin/bash
.SHELLFLAGS = -e -o pipefail -c
ANSIBLE_ARGS ?= $(ANSIBLE_OPTIONS)
ANSIBLE_PLAYBOOK ?= site.yml

ifdef ANSIBLE_GROUP
ANSIBLE_LIMIT := $(ANSIBLE_GROUP)
endif

ifdef ANSIBLE_HOST
ANSIBLE_LIMIT := $(ANSIBLE_HOST)
endif

ifdef ANSIBLE_TAGS
ANSIBLE_ARGS := $(ANSIBLE_ARGS) --tags='$(ANSIBLE_TAGS)'
endif

.PHONY: version
version:
	ansible --version
	ansible-lint --version
	ec --version
	yamllint --version

.PHONY: roles
roles:
	rm --recursive --force ./roles/
	ansible-galaxy role install \
		--role-file="requirements.yml"

.PHONY: collections
collections:
	rm --recursive --force ./collections/
	ansible-galaxy collection install \
		--requirements-file="requirements.yml"

.PHONY: requirements
requirements: roles collections

.PHONY: lint
lint:
	ec
	yamllint --strict --config-file .yamllint .
	ansible-lint .
	find . -maxdepth 1 -name "*.yml" -not -name "requirements.yml" | xargs -n1 ansible-playbook --inventory="hosts" --syntax-check

.PHONY: bootstrap
bootstrap:
	ansible-playbook \
		$(ANSIBLE_ARGS) \
		--inventory="hosts" \
		--vault-password-file="./.vault_pass.txt" \
		--limit="$(ANSIBLE_LIMIT)" \
		bootstrap.yml

.PHONY: deploy
deploy:
	ansible-playbook \
		$(ANSIBLE_ARGS) \
		--inventory="hosts" \
		--vault-password-file="./.vault_pass.txt" \
		--limit="$(ANSIBLE_LIMIT)" \
		$(ANSIBLE_PLAYBOOK)
