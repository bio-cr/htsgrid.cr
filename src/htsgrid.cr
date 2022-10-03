require "gtk4"
require "hts"
require "./views/main_window"

Gio.register_resource("data/dev.kojix2.htsgrid.gresource.xml", "data")
exit(HTSGrid::MainWindow.new.run)
