require "./htsgrid/native_dependencies"
require "gtk4"
require "./htsgrid/core"
require "./htsgrid/action/about"
require "./htsgrid/view/table_model"
require "./htsgrid/view/document_table"
require "./htsgrid/view/header_window"
require "./htsgrid/view/main_window"

{% if flag?(:darwin) %}
  HTSGrid::NativeDependencies.ensure_gtk_linked
{% end %}
Gio.register_resource("data/dev.bio-cr.htsgrid.gresource.xml", "data")
exit(HTSGrid::View::MainWindow.new.run)
