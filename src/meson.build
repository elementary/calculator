executable(
    meson.project_name(),
    config_file,
    'Application.vala',
    'Button.vala',
    'MainWindow.vala',
    'HistoryDialog.vala',
    'Core/Token.vala',
    'Core/Scanner.vala',
    'Core/Evaluation.vala',
    dependencies: [
        core_deps,
        dependency('gtk4'),
        dependency('granite-7', version: '>=7.0.0')
    ],
    install : true
)
