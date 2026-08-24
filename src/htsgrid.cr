require "./htsgrid/native_dependencies"
require "gtk4"
require "hts"
require "./htsgrid/version"
require "./htsgrid/document"
require "./htsgrid/alignment_row"
require "./htsgrid/variant_row"
require "./htsgrid/document_loader"
require "./htsgrid/action/about"
require "./htsgrid/view/table_model"
require "./htsgrid/view/main_window"
require "./htsgrid/view/header_window"

{% if flag?(:darwin) %}
  HTSGrid::NativeDependencies.ensure_gtk_linked
{% end %}
Gio.register_resource("data/dev.bio-cr.htsgrid.gresource.xml", "data")
exit(HTSGrid::View::MainWindow.new.run)
