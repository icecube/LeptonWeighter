# BinaryBuilder recipe for LeptonWeighter Julia bindings
#
# This script builds cross-platform binaries for the LeptonWeighter Julia bindings.
# It can be used to generate a JLL package for distribution via Yggdrasil.
#
# Usage:
#   julia build_tarballs.jl --debug --verbose
#
# For full cross-platform builds:
#   julia build_tarballs.jl x86_64-linux-gnu,x86_64-apple-darwin14,aarch64-linux-gnu,aarch64-apple-darwin

using BinaryBuilder, Pkg

name = "LeptonWeighter"
version = v"1.10.0"

# Collection of sources required to build LeptonWeighter
sources = [
    GitSource("https://github.com/icecube/LeptonWeighter.git", "master"),
    # Note: You may need to pin to a specific commit/tag for reproducibility
    # GitSource("https://github.com/icecube/LeptonWeighter.git", "v1.10.0"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/LeptonWeighter

# Configure with Julia bindings
./configure \
    --prefix=${prefix} \
    --with-julia-bindings \
    --julia-bin=${JULIA_EXE:-julia}

# Build the core library
make -j${nproc}

# Build Julia bindings
make julia

# Install
make install
make julia-install

# Copy the Julia library to the expected location
install -Dm755 lib/libLeptonWeighterJL.${dlext} ${libdir}/libLeptonWeighterJL.${dlext}
"""

# These are the platforms we will build for
platforms = supported_platforms()

# Filter to platforms where we can build C++11 code with CxxWrap
platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = [
    LibraryProduct("libLeptonWeighter", :libLeptonWeighter),
    LibraryProduct("libLeptonWeighterJL", :libLeptonWeighterJL),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    # CxxWrap for Julia bindings
    BuildDependency(PackageSpec(name="libcxxwrap_julia_jll")),
    Dependency(PackageSpec(name="libcxxwrap_julia_jll")),

    # GSL for numerical computations
    Dependency(PackageSpec(name="GSL_jll")),

    # HDF5 for data I/O
    Dependency(PackageSpec(name="HDF5_jll")),

    # CFITSIO for FITS file support (used by photospline)
    Dependency(PackageSpec(name="CFITSIO_jll")),

    # Note: photospline is not yet available as a JLL package.
    # You may need to:
    # 1. Create a photospline_jll package first
    # 2. Or bundle photospline in the build script
    # 3. Or use a system-provided photospline

    # Julia itself (for CxxWrap headers)
    HostBuildDependency(PackageSpec(name="Julia_jll")),
]

# Build the tarballs, and possibly a `build.jl` as well
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.9",
               preferred_gcc_version=v"9")

#=
Notes for publishing to Yggdrasil:

1. photospline dependency:
   LeptonWeighter requires photospline v2. If photospline_jll doesn't exist,
   you'll need to create it first or modify the build script to compile
   photospline from source.

2. nuSQuIDS (optional):
   If you want nuSQuIDS support, you'll need nusquids_jll and squids_jll
   packages as well.

3. Testing locally:
   julia build_tarballs.jl --debug x86_64-linux-gnu

4. After successful build, submit to Yggdrasil:
   https://github.com/JuliaPackaging/Yggdrasil

5. The generated JLL package will be named LeptonWeighter_jll
=#
