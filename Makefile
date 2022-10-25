PREFIX ?= /usr

all: build

build:
	shards build --release --no-debug

clean:
	rm -f bin/htsgrid

install:
	install -D -m 0755 bin/htsgrid $(PREFIX)/bin/htsgrid
	install -D -m 0644 data/dev.bio-cr.htsgrid.desktop $(PREFIX)/share/applications/dev.bio-cr.htsgrid.desktop
	install -D -m 0644 data/icons/dev.bio-cr.htsgrid.svg $(PREFIX)/share/icons/hicolor/scalable/apps/dev.bio-cr.htsgrid.svg
	gtk-update-icon-cache /usr/share/icons/hicolor

uninstall:
	rm -f $(PREFIX)/bin/htsgrid
	rm -f $(PREFIX)/share/applications/dev.bio-cr.htsgrid.desktop
	rm -f $(PREFIX)/share/icons/hicolor/scalable/apps/dev.bio-cr.htsgrid.svg
	gtk-update-icon-cache /usr/share/icons/hicolor
