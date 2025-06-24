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

.PHONY: roles
roles:
	rm --recursive --force roles/
	until ansible-galaxy role install \
		--roles-path="roles/" \
		--role-file="requirements.yml"; \
	do \
		echo "Download of Ansible roles failed. Try again"; \
	done

.PHONY: collections
collections:
	rm --recursive --force collections/
	until ansible-galaxy collection install \
		--collections-path="collections/" \
		--requirements-file="requirements.yml"; \
	do \
		echo "Download of Ansible collections failed. Try again"; \
	done

.PHONY: requirements
requirements: roles collections

.PHONY: bootstrap
bootstrap:
	ansible-playbook \
		$(ANSIBLE_ARGS) \
		--inventory="hosts.yml" \
		--limit="$(ANSIBLE_LIMIT)" \
		bootstrap.yml

.PHONY: deploy
deploy:
	ansible-playbook \
		$(ANSIBLE_ARGS) \
		--inventory="hosts.yml" \
		--limit="$(ANSIBLE_LIMIT)" \
		$(ANSIBLE_PLAYBOOK)
