# Calculator
[![Translation status](https://l10n.elementary.io/widgets/calculator/-/svg-badge.svg)](https://l10n.elementary.io/projects/calculator/?utm_source=widget)

![Screenshot](data/screenshot.png?raw=true)

## Building, Testing, and Installation

You'll need the following dependencies:
* libgranite-dev
* meson
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja test` to build and run automated tests

    meson build --prefix=/usr
    cd build
    ninja test

To install, use `ninja install`, then execute with `io.elementary.calculator`

    sudo ninja install
    io.elementary.calculator
