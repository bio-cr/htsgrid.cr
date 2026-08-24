{% if flag?(:darwin) %}
  # Crystal 1.21 can discard gtk4's pkg-config library search paths when
  # several generated GI libraries link the same native library.
  @[Link(ldflags: "`pkg-config --libs-only-L gtk4`")]
  lib LibGtk4LibraryPath
    fun gtk_get_major_version : UInt32
  end

  module HTSGrid::NativeDependencies
    def self.ensure_gtk_linked : Nil
      LibGtk4LibraryPath.gtk_get_major_version
      nil
    end
  end
{% end %}
