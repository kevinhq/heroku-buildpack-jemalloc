default: heroku-16 heroku-18 heroku-20

VERSION := 5.2.0
ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

clean:
	rm -rf src/ dist/

console:
	@echo "Console Help"
	@echo
	@echo "Specify a verion to install:"
	@echo "    echo 5.2.1 > /env/JEMALLOC_VERSION"
	@echo
	@echo "To vendor jemalloc:"
	@echo "    bin/compile /app/ /cache/ /env/"
	@echo

	@docker run --rm -ti -v $(shell pwd):/buildpack -e "STACK=heroku-18" -w /buildpack heroku/heroku:18-build \
		bash -c 'mkdir /app /cache /env; exec bash'

# Download missing source archives to ./src/
src/jemalloc-%.tar.bz2:
	mkdir -p $$(dirname $@)
	curl -fsL https://github.com/jemalloc/jemalloc/releases/download/$*/jemalloc-$*.tar.bz2 -o $@

.PHONY: heroku-16 heroku-18 heroku-20 docker\:pull

# Updates the docker image to ensure we're building with the latest
# environment.
docker\:pull:
	docker pull heroku/heroku:16-build
	docker pull heroku/heroku:18-build
	docker pull heroku/heroku:20-build

# Build for heroku-16 stack
heroku-16: src/jemalloc-$(VERSION).tar.bz2 docker\:pull
	docker run --rm -it --volume="$(ROOT_DIR):/wrk" \
		heroku/heroku:16-build /wrk/build.sh $(VERSION) heroku-16

# Build for heroku-18 stack
heroku-18: src/jemalloc-$(VERSION).tar.bz2 docker\:pull
	docker run --rm -it --volume="$(ROOT_DIR):/wrk" \
		heroku/heroku:18-build /wrk/build.sh $(VERSION) heroku-18

# Build for heroku-20 stack
heroku-20: src/jemalloc-$(VERSION).tar.bz2 docker\:pull
	docker run --rm -it --volume="$(ROOT_DIR):/wrk" \
		heroku/heroku:20-build /wrk/build.sh $(VERSION) heroku-20

# Build recent releases for all supported stacks
all:
	$(MAKE) heroku-16 heroku-18 heroku-20 VERSION=5.1.0
	$(MAKE) heroku-16 heroku-18 heroku-20 VERSION=5.2.0
	$(MAKE) heroku-16 heroku-18 heroku-20 VERSION=5.2.1
