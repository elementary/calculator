core_test = executable(
    meson.project_name() + '-test',
    'CoreTest.vala',
    meson.source_root() + '/src/Core/Stack.vala',
    meson.source_root() + '/src/Core/Token.vala',
    meson.source_root() + '/src/Core/Scanner.vala',
    meson.source_root() + '/src/Core/Evaluation.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        meson.get_compiler('vala').find_library('posix'),
        meson.get_compiler('c').find_library('m', required : false)
    ]
)

test('calculator core test', core_test)
