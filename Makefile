.DEFAULT_GOAL:=help
.PHONY: config install start stop restart
.SILENT:

SUCCESS_COLOR = \033[0;32m
END_COLOR = \033[m
ROOT_DIR = $(shell pwd)

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Configure & Install
config: ## Create the .env file from .env.dist model file
	test -f "$(ROOT_DIR)/.env" || cp "$(ROOT_DIR)/.env.dist" "$(ROOT_DIR)/.env"
	echo "$(SUCCESS_COLOR)Configuration Ok !$(END_COLOR)"

install: config ## Build the docker images
	docker-compose build
	echo "$(SUCCESS_COLOR)Images builded !$(END_COLOR)"

##@ Daily use
start: install ## Lauch the docker containers
	docker-compose up
	echo "$(SUCCESS_COLOR)Containers launched !$(END_COLOR)"

stop: ## Stop and destroy the docker containers
	docker-compose stop
	docker-compose down
	echo "$(SUCCESS_COLOR)Containers destroyed !(END_COLOR)"

restart: stop start ## Restart the containers
	echo "$(SUCCESS_COLOR)Containers restarted !(END_COLOR)"