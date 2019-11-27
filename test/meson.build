core_test = executable(
    meson.project_name() + '-test',
    'CoreTest.vala',
    meson.source_root() + '/src/Core/Token.vala',
    meson.source_root() + '/src/Core/Scanner.vala',
    meson.source_root() + '/src/Core/Evaluation.vala',
    dependencies: core_deps
)

test('Calculator core test', core_test)
