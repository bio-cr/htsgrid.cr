PREFIX ?= /usr

all: build

build:
	shards build --release --no-debug

install:
	install -D -m 0755 bin/htsgrid $(PREFIX)/bin/htsgrid
	install -D -m 0644 data/dev.kojix2.htsgrid.desktop $(PREFIX)/share/applications/dev.kojix2.htsgrid.desktop
	install -D -m 0644 data/icons/dev.kojix2.htsgrid.svg $(PREFIX)/share/icons/hicolor/scalable/apps/dev.kojix2.htsgrid.svg
	gtk-update-icon-cache /usr/share/icons/hicolor

uninstall:
	rm -f $(PREFIX)/bin/htsgrid
	rm -f $(PREFIX)/share/applications/dev.kojix2.htsgrid.desktop
	rm -f $(PREFIX)/share/icons/hicolor/scalable/apps/dev.kojix2.htsgrid.svg
	gtk-update-icon-cache /usr/share/icons/hicolor
