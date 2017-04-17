# Calculator
[![Translation status](https://l10n.elementary.io/widgets/calculator/-/svg-badge.svg)](https://l10n.elementary.io/projects/calculator/?utm_source=widget)

## Building, Testing, and Installation

It's recommended to create a clean build environment

    mkdir build
    cd build/
    
Run `cmake` to configure the build environment and then `make` to build

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make
    
To install, use `make install`, then execute with `pantheon-calculator`

    sudo make install
    pantheon-calculator
