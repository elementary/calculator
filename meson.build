project(
    'io.elementary.calculator', 'vala', 'c',
    meson_version : '>= 0.43'
)

i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="io.elementary.calculator"', language:'c')

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('po')
subdir('src')
