DOCKER_COMPOSE_DIR=./.docker
DOCKER_COMPOSE_FILE=$(DOCKER_COMPOSE_DIR)/docker-compose.yml
DEFAULT_CONTAINER=backend
DOCKER_COMPOSE=docker-compose -f $(DOCKER_COMPOSE_FILE) --project-directory $(DOCKER_COMPOSE_DIR)

DEFAULT_GOAL := help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<command>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Commands:

.PHONY: init
init: ## Make sure the .env file exists for docker
	cp $(DOCKER_COMPOSE_DIR)/.env.example $(DOCKER_COMPOSE_DIR)/.env

.PHONY: build-from-scratch
build-from-scratch: init ## Build all docker images from scratch, without cache etc. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
	$(DOCKER_COMPOSE) rm -fs $(CONTAINER) && \
	$(DOCKER_COMPOSE) build --pull --no-cache --parallel $(CONTAINER) && \
	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)

.PHONY: build
build: init ## Build all docker images. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
	$(DOCKER_COMPOSE) build --parallel $(CONTAINER) && \
	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)

.PHONY: prune
prune: ## Remove unused docker resources via 'docker system prune -a -f --volumes'
	docker system prune -a -f --volumes

.PHONY: up
up: init ## Start all docker containers. To only start one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) up -d $(CONTAINER)

.PHONY: down
down: init ## Stop all docker containers. To only stop one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) down $(CONTAINER)
