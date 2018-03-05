executable(
    meson.project_name(),
    'PantheonCalculator.vala',
    'Button.vala',
    'MainWindow.vala',
    'HistoryDialog.vala',
    'Core/Stack.vala',
    'Core/Token.vala',
    'Core/Scanner.vala',
    'Core/Evaluation.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('granite'),
        meson.get_compiler('vala').find_library('posix'),
        meson.get_compiler('c').find_library('m', required : false)
    ],
    install : true
)
