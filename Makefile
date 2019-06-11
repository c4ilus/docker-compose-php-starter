ROOT_DIR := $(shell pwd)

.PHONY: config install start stop restart

config:
	test -f "$(ROOT_DIR)/.env" || cp "$(ROOT_DIR)/.env.dist" "$(ROOT_DIR)/.env"

install: config
	docker-compose build

start: install
	docker-compose up

stop:
	docker-compose stop
	docker-compose down

restart: stop start