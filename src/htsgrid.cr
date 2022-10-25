require "gtk4"
require "hts"
require "./htsgrid/version"
require "./htsgrid/action/about"
require "./htsgrid/view/main_window"
require "./htsgrid/view/header_window"

Gio.register_resource("data/dev.bio-cr.htsgrid.gresource.xml", "data")
exit(HTSGrid::View::MainWindow.new.run)
