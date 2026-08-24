PREFIX ?= /usr
DESTDIR ?=

BINDIR = $(DESTDIR)$(PREFIX)/bin
APPLICATIONSDIR = $(DESTDIR)$(PREFIX)/share/applications
ICONDIR = $(DESTDIR)$(PREFIX)/share/icons/hicolor

all: build

bindings:
	./bin/gi-crystal

build: bindings
	shards build --release --no-debug

clean:
	rm -f bin/htsgrid

install: build
	install -d $(BINDIR) $(APPLICATIONSDIR) $(ICONDIR)/scalable/apps
	install -m 0755 bin/htsgrid $(BINDIR)/htsgrid
	install -m 0644 data/dev.bio-cr.htsgrid.desktop $(APPLICATIONSDIR)/dev.bio-cr.htsgrid.desktop
	install -m 0644 data/icons/dev.bio-cr.htsgrid.svg $(ICONDIR)/scalable/apps/dev.bio-cr.htsgrid.svg
	@if command -v gtk4-update-icon-cache >/dev/null 2>&1; then gtk4-update-icon-cache $(ICONDIR); fi

uninstall:
	rm -f $(BINDIR)/htsgrid
	rm -f $(APPLICATIONSDIR)/dev.bio-cr.htsgrid.desktop
	rm -f $(ICONDIR)/scalable/apps/dev.bio-cr.htsgrid.svg
	@if command -v gtk4-update-icon-cache >/dev/null 2>&1; then gtk4-update-icon-cache $(ICONDIR); fi

.PHONY: all bindings build clean install uninstall
