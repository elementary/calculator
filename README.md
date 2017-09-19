# Calculator
[![Translation status](https://l10n.elementary.io/widgets/calculator/-/svg-badge.svg)](https://l10n.elementary.io/projects/calculator/?utm_source=widget)

![Screenshot](data/screenshot.png?raw=true)

## Building, Testing, and Installation

You'll need the following dependencies:
* libgranite-dev
* meson
* valac
    
Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja
    
To install, use `ninja install`, then execute with `io.elementary.calculator`

    sudo ninja install
    io.elementary.calculator
