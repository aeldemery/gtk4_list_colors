sources = files(
    'Main.vala',
    'MainWindow.vala',
    'ColorWidget.vala',
    'ColorListModel.vala',
    'ColorGridWidget.vala',
    'ColorSelectionWidget.vala',
)

dependencies = [
    dependency ('gtk4'),
    dependency ('gobject-2.0'),
    dependency ('glib-2.0'),
    meson.get_compiler('c').find_library('m', required: false),
]

executable (
    meson.project_name(),
    resources,
    sources: sources,
    dependencies: dependencies,
    install: true,
)
