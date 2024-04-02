# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include .env

DOCKER_NAME="$(PROJECT_TITLE)"
DOCKER_ABBR=$(PROJECT_ABBR)
DOCKER_CAAS=$(PROJECT_DB_CAAS)
DOCKER_HOST=$(PROJECT_DB_HOST)
DOCKER_PORT=$(PROJECT_DB_PORT)

CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)

DOCKER_COMPOSE?=$(DOCKER_USER) docker compose
DOCKER_COMPOSE_RUN=$(DOCKER_COMPOSE) run --rm
DOCKER_EXEC_TOOLS_APP=$(DOCKER_USER) docker exec -it $(DOCKER_CAAS) sh

help: ## shows this Makefile help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: hostname fix-permission port-check

hostname: ## shows local machine hostname ip
	echo $(word 1,$(shell hostname -I))

fix-permission: ## sets project directory permission
	$(DOCKER_USER) chown -R ${USER}: $(ROOT_DIR)/

port-check: ## shows .env port set availability on local machine
	echo "Checking configuration for "${C_YEL}"$(DOCKER_NAME)"${C_END}" container:";
	if [ -z "$$($(DOCKER_USER) lsof -i :$(DOCKER_PORT))" ]; then \
		echo ${C_BLU}"$(DOCKER_NAME)"${C_END}" > port:"${C_GRN}"$(DOCKER_PORT) is free to use."${C_END}; \
    else \
		echo ${C_BLU}"$(DOCKER_NAME)"${C_END}" > port:"${C_RED}"$(DOCKER_PORT) is busy. Update ./.env file."${C_END}; \
	fi

# -------------------------------------------------------------------------------------------------
#  Enviroment
# -------------------------------------------------------------------------------------------------
.PHONY: env env-set

env: ## checks if docker .env file exists
	if [ -f ./docker/.env ]; then \
		echo ${C_BLU}$(DOCKER_NAME)${C_END}" docker-compose.yml .env file "${C_GRN}"is set."${C_END}; \
    else \
		echo ${C_BLU}$(DOCKER_NAME)${C_END}" docker-compose.yml .env file "${C_RED}"is not set."${C_END}" \
	Create it by executing "${C_YEL}"$$ make env-set"${C_END}; \
	fi

env-set: ## sets the database enviroment file to build the container
	echo "COMPOSE_PROJECT_ABBR=\"$(DOCKER_ABBR)\"\
	\nCOMPOSE_PROJECT_NAME=\"$(DOCKER_CAAS)\"\
	\nCOMPOSE_PROJECT_PORT=$(DOCKER_PORT)\
	\nMYSQL_ROOT_PASSWORD=\"$(PROJECT_DB_ROOT)\"\
	\nMYSQL_DATABASE=$(PROJECT_DB_NAME)\
	\nMYSQL_USER=$(PROJECT_DB_USER)\
	\nMYSQL_PASSWORD=\"$(PROJECT_DB_PASS)\""> ./docker/.env;
	echo ${C_BLU}"$(DOCKER_NAME)"${C_END}" docker-compose.yml .env file "${C_GRN}"has been set."${C_END};

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: ssh build dev up first start stop clear restart rebuild

ssh: ## enters the database container shell
	$(DOCKER_EXEC_TOOLS_APP)

build: ## builds the database container from Docker image
	cd docker && $(DOCKER_COMPOSE) up --build --no-recreate -d

dev: ## -- recipe has not usage in this project --
	echo ${C_YEL}"\"dev\" recipe has not usage in this project"${C_END};

up: ## starts the containers in the background and leaves them running
	cd docker && $(DOCKER_COMPOSE) up -d

start: ## starts existing containers for a service
	cd docker && $(DOCKER_COMPOSE) start

stop: ## stops running container without removing it
	cd docker && $(DOCKER_COMPOSE) stop

clear: ## stops and removes the database container from Docker network destroying its data
	cd docker && $(DOCKER_COMPOSE) kill || true
	cd docker && $(DOCKER_COMPOSE) rm --force || true
	cd docker && $(DOCKER_COMPOSE) down -v --remove-orphans || true

destroy: ## removes the database image from Docker - docker system and volume prune still required to be manually
	cd docker && $(DOCKER_USER) docker rmi $(DOCKER_CAAS):$(DOCKER_ABBR)-mariadb

first:
	$(MAKE) build up

restart:
	$(MAKE) stop start

rebuild:
	$(MAKE) stop clear start

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: sql-install sql-replace sql-backup

sql-install: ## installs into container database the init sql file from resources/database
	sudo docker exec -i $(PROJECT_DB_CAAS) sh -c 'exec mysql $(PROJECT_DB_NAME) -uroot -p"$(PROJECT_DB_ROOT)"' < $(PROJECT_DB_PATH)/$(PROJECT_DB_NAME)-init.sql

sql-replace: ## replaces container database with the latest sql backup file from resources/database
	sudo docker exec -i $(PROJECT_DB_CAAS) sh -c 'exec mysql $(PROJECT_DB_NAME) -uroot -p"$(PROJECT_DB_ROOT)"' < $(PROJECT_DB_PATH)/$(PROJECT_DB_NAME)-backup.sql

sql-backup: ## creates / replace a sql backup file from container database in resources/database
	sudo docker exec $(PROJECT_DB_CAAS) sh -c 'exec mysqldump $(PROJECT_DB_NAME) -uroot -p"$(PROJECT_DB_ROOT)"' > $(PROJECT_DB_PATH)/$(PROJECT_DB_NAME)-backup.sql

# -------------------------------------------------------------------------------------------------
#  Repository Helper
# -------------------------------------------------------------------------------------------------
repo-flush: ## clears local git repository cache specially to update .gitignore
	git rm -rf --cached .
	git add .
	git commit -m "fix: cache cleared for untracked files"