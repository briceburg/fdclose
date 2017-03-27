NAMESPACE:=fdclose
prefix = $(DESTDIR)/usr/local/bin

CC = gcc
CFLAGS = -std=gnu99 -Wextra -pedantic -O3

.PHONY: all libptrace_do.a fdclose install uninstall clean
all: $(NAMESPACE)

$(NAMESPACE): libptrace_do.a
	$(CC) $(CFLAGS) -L./src/ptrace_do -o bin/$(NAMESPACE) src/fdclose.c -lptrace_do

libptrace_do.a:
	cd $(CURDIR)/src/ptrace_do && $(MAKE) $@

install: $(NAMESPACE)
	$(info * installing into $(prefix))
  # use mkdir vs. install -D/d (macos portability)
	@mkdir -p $(prefix)
	@install bin/$(NAMESPACE) $(prefix)/$(NAMESPACE)

uninstall:
	rm -rf $(prefix)/$(NAMESPACE)

clean:
	cd $(CURDIR)/src/ptrace_do && $(MAKE) $@ clean || true
	rm -f $(CURDIR)/bin/$(NAMESPACE)


#
# tests (in a container)
#
.PHONY: clean-tests clean-dockerbuilds dockerbuild-% tests

DOCKER_SOCKET ?= /var/run/docker.sock
DOCKER_GROUP_ID ?= $(shell ls -ln $(DOCKER_SOCKET) | awk '{print $$4}')

# for docker-for-mac, we also add group-id of 50 ("authedusers") as moby distro seems to auto bind-mount /var/run/docker.sock w/ this ownership
DOCKER_FOR_MAC_WORKAROUND := $(shell [[ "$$OSTYPE" == darwin* || "$$OSTYPE" == macos* ]] && echo "--group-add=50")

clean-tests: clean
	rm -rf $(CURDIR)/tests/bats/tmp

clean-dockerbuilds:
	for id in $$(docker images -q makefile-$(NAMESPACE)-*) ; do docker rmi  $$id ; done

dockerbuild-%:
	$(info ---  building Dockerfile in $*/ ---)
	docker build \
	  --build-arg NAMESPACE=$(NAMESPACE) \
		--tag makefile-$(NAMESPACE)-$* \
		  $*/

tests: dockerbuild-tests clean-tests
	docker run -it --rm -u $$(id -u):$$(id -g) $(DOCKER_FOR_MAC_WORKAROUND) \
    --group-add=$(DOCKER_GROUP_ID) \
    --device=/dev/tty0 --device=/dev/console \
		-v $(CURDIR):/$(CURDIR) \
    -e SKIP_NETWORK_TEST=$(SKIP_NETWORK_TEST) \
		--workdir $(CURDIR) \
	    makefile-$(NAMESPACE)-tests bats tests/bats/$(TEST)
