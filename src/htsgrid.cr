require "gtk4"
require "hts"
require "./htsgrid/version"
require "./htsgrid/action/about"
require "./htsgrid/view/main_window"

Gio.register_resource("data/dev.kojix2.htsgrid.gresource.xml", "data")
exit(HTSGrid::View::MainWindow.new.run)
