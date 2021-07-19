project(
    'io.elementary.calculator', 'vala', 'c',
    meson_version : '>= 0.43',
    version: '1.6.2'
)

i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="io.elementary.calculator"', language:'c')

core_deps = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    meson.get_compiler('vala').find_library('posix'),
    meson.get_compiler('c').find_library('m', required : false)
]

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('po')
subdir('src')
subdir('test')
