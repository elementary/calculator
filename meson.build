project('com.github.elementary.calculator', 'vala', 'c')

i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="com.github.elementary.calculator"', language:'c')

executable(
    meson.project_name(),
    'src/PantheonCalculator.vala',
    'src/Button.vala',
    'src/MainWindow.vala',
    'src/HistoryDialog.vala',
    'src/Core/Stack.vala',
    'src/Core/Token.vala',
    'src/Core/Scanner.vala',
    'src/Core/Evaluation.vala',
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

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('po')
