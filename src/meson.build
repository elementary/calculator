executable(
    meson.project_name(),
    config_file,
    'PantheonCalculator.vala',
    'Button.vala',
    'MainWindow.vala',
    'HistoryDialog.vala',
    'Core/Token.vala',
    'Core/Scanner.vala',
    'Core/Evaluation.vala',
    dependencies: [
        core_deps,
        dependency('gtk+-3.0'),
        dependency('granite', version: '>=6.0.0')
    ],
    install : true
)
