ACBUILD=acbuild
PROJECT_NAME=django_appc
PROJECT_VERSION=0.0.1
PROJECT_AUTHORS=Simple Life Engineering <engr@simplelife.com>
PROJECT_DIR=$(realpath .)
PROJECT_SRC=$(PROJECT_DIR)/server
PROJECT_ANSIBLE_DIR=${PROJECT_DIR}/ansible
CONTAINER_NAME=$(PROJECT_NAME)
CONTAINER_IMAGE=$(PROJECT_NAME)-$(PROJECT_VERSION)-linux-amd64.aci
CONTAINER_USER=`id -u`
CONTAINER_GROUP=`id -g`
CONTAINER_ANSIBLE_DIR=/srv/${PROJECT_NAME}/ansible
CONTAINER_SERVER_DIR=/srv/${PROJECT_NAME}/server
CONTAINER_BIN_DIR=/srv/${PROJECT_NAME}/bin

.PHONY: build build-base build-shell clean

all: build

build-base: clean
	$(ACBUILD) begin
	$(ACBUILD) set-name $(CONTAINER_NAME)
	$(ACBUILD) set-user $(CONTAINER_USER)
	$(ACBUILD) set-group $(CONTAINER_GROUP)
	$(ACBUILD) dep add quay.io/coreos/alpine-sh
	$(ACBUILD) copy $(PROJECT_DIR)/ansible ${CONTAINER_ANSIBLE_DIR}
	$(ACBUILD) copy $(PROJECT_DIR)/server ${CONTAINER_SERVER_DIR}
	$(ACBUILD) copy $(PROJECT_DIR)/bin/dumb-init ${CONTAINER_BIN_DIR}/dumb-init
	$(ACBUILD) annotation add authors "$(PROJECT_AUTHORS)"
	$(ACBUILD) port add http tcp 8000
	$(ACBUILD) label add version $(PROJECT_VERSION)
	$(ACBUILD) label add os linux
	$(ACBUILD) label add arch amd64
	$(ACBUILD) run -- apk update
	$(ACBUILD) run -- apk add build-base python-dev libffi-dev openssl-dev py-pip
	$(ACBUILD) run -- pip install ansible setuptools --upgrade
	$(ACBUILD) run --working-dir=${CONTAINER_ANSIBLE_DIR} -- ansible-playbook django-container.yml -i "localhost," -c local

build-shell: build-base
	$(ACBUILD) set-exec /bin/sh
	$(ACBUILD) write shell-$(CONTAINER_IMAGE)
	$(ACBUILD) end

build: build-base
	$(ACBUILD) set-exec /srv/${PROJECT_NAME}/bin/dumb-init /srv/$(PROJECT_NAME)/bin/gunicorn_start
	$(ACBUILD) write $(CONTAINER_IMAGE)
	$(ACBUILD) end

clean:
	rm -rf $(realpath .)/.acbuild *.aci

