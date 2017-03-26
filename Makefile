NAMESPACE:=fdclose
prefix = $(DESTDIR)/usr/local/bin

CC = gcc
CFLAGS = -std=gnu99 -Wextra -pedantic -O3

.PHONY: all libptrace_do.a fdclose
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

clean:
	cd $(CURDIR)/src/ptrace_do && $(MAKE) $@ clean
	rm $(CURDIR)/bin/$(NAMESPACE)
