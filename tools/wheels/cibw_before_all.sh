#!/bin/bash
# Install dependencies before building wheels
# This runs once per platform, not per Python version

set -ex

PROJECT_DIR="$1"

if [ "$RUNNER_OS" = "Linux" ]; then
    # On manylinux, install build dependencies
    # manylinux_2_28 is based on AlmaLinux 8

    # Install basic build tools
    yum install -y gcc gcc-c++ make cmake wget tar bzip2 zlib-devel

    # Install GSL
    yum install -y gsl-devel

    # Install HDF5
    yum install -y hdf5-devel

    # Install Boost headers (needed for nuflux interface, optional)
    yum install -y boost-devel || true

    # Install CFITSIO (needed by photospline)
    yum install -y cfitsio-devel || yum install -y cfitsio || true

    # Install SuiteSparse (needed by photospline)
    yum install -y suitesparse-devel || true

    # Build and install photospline from source
    PHOTOSPLINE_VERSION="2.3.1"
    cd /tmp
    wget https://github.com/icecube/photospline/archive/refs/tags/v${PHOTOSPLINE_VERSION}.tar.gz
    tar xzf v${PHOTOSPLINE_VERSION}.tar.gz
    cd photospline-${PHOTOSPLINE_VERSION}
    mkdir build && cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release
    make -j$(nproc)
    make install
    ldconfig

    # Verify photospline installation
    echo "Photospline installed:"
    photospline-config --version || echo "photospline-config not in PATH"
    ls -la /usr/local/bin/photospline-config || true

    # Add to PATH
    export PATH="/usr/local/bin:$PATH"

elif [ "$RUNNER_OS" = "macOS" ]; then
    # On macOS, use Homebrew
    brew install gsl hdf5 cfitsio suite-sparse boost

    # Install photospline via homebrew tap or build from source
    # First try the tap
    brew tap icecube/icecube || true
    brew install photospline || {
        # Build from source if tap fails
        PHOTOSPLINE_VERSION="2.3.1"
        cd /tmp
        curl -L -o photospline.tar.gz https://github.com/icecube/photospline/archive/refs/tags/v${PHOTOSPLINE_VERSION}.tar.gz
        tar xzf photospline.tar.gz
        cd photospline-${PHOTOSPLINE_VERSION}
        mkdir build && cd build
        cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release
        make -j$(sysctl -n hw.ncpu)
        sudo make install
    }
fi

echo "Dependencies installed successfully"
