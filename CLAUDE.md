# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LeptonWeighter is a C++11 library with Python and Julia bindings that weights simulated neutrino events from LeptonInjector simulations to physical neutrino fluxes. It's used by the IceCube neutrino observatory to convert Monte Carlo simulation weights based on flux models and cross sections.

## Build Commands

### Configuration
```bash
./configure --help                    # See all options
./configure                           # Basic configuration (auto-detects deps via pkg-config)
./configure --with-python-bindings    # Enable pybind11 Python bindings
./configure --with-julia-bindings     # Enable CxxWrap.jl Julia bindings
./configure --with-nusquids=/path     # Enable nuSQuIDS support
./configure --prefix=$HOME/local      # Custom install prefix
```

### Building
```bash
make                    # Build static and dynamic libraries
make python             # Build Python bindings (requires --with-python-bindings)
make julia              # Build Julia bindings (requires --with-julia-bindings)
make examples           # Build C++ example programs
make docs               # Generate Doxygen documentation
make clean              # Remove build artifacts
```

### Installation
```bash
make install            # Install C++ library to PREFIX (default: /usr/local)
make python-install     # Install Python module to site-packages
make julia-install      # Install Julia library
make julia-test         # Run Julia test suite
pip install .           # Modern wheel-based installation
```

### Running Examples
```bash
# Python (from resources/example/)
python weigh_events.py                              # Basic power-law flux
python weigh_events.py --lic config.lic --events data_output.h5

# C++ (after make examples)
./resources/example/weigh_events.exe config.lic ...
./resources/example/read_lic.exe config.lic
```

## Architecture

### Core Classes (namespace `LeptonWeighter`)

- **Weighter**: Main class that combines flux, cross-section, and generator to compute event weights. Call `weighter.weight(event)` or use as callable `weighter(event)`.

- **Event**: Data structure holding neutrino event properties (energy, zenith, azimuth, Bjorken x/y, particle types, geometry).

- **Flux** (abstract): Neutrino flux models
  - `PowerLawFlux`: E^-index power law
  - `ConstantFlux`: Unity/constant flux
  - `nuSQUIDSAtmFlux`, `nuSQUIDSFlux`: (requires nuSQuIDS)

- **CrossSection** (abstract): Neutrino cross sections
  - `CrossSectionFromSpline`: DIS cross sections from photospline FITS files
  - `GlashowResonanceCrossSection`: (requires nuSQuIDS)

- **Generator** (abstract): Simulation probability calculation
  - `RangeGenerator`: Point injection geometry
  - `VolumeGenerator`: Volume injection geometry
  - `MakeGeneratorsFromLICFile()`: Load from LeptonInjector config file

### Python Usage
```python
import LeptonWeighter as LW

flux = LW.PowerLawFlux(1e-18, -2.0, 1e5)
xs = LW.CrossSectionFromSpline(cc_nu, cc_nubar, nc_nu, nc_nubar)
generators = LW.MakeGeneratorsFromLICFile("config.lic")
weighter = LW.Weighter(flux, xs, generators)
weight = weighter(event)  # Returns Hz; multiply by livetime for counts
```

### Julia Usage
```julia
using LeptonWeighter

flux = PowerLawFlux(1e-18, -2.0; pivot=1e5)
xs = CrossSectionFromSpline(cc_nu, cc_nubar, nc_nu, nc_nubar)
generators = make_generators_from_lic_file("config.lic")
weighter = create_weighter(flux, xs, generators)
weight = weighter(event)  # Returns Hz; multiply by livetime for counts

# Event creation with keyword arguments
event = Event(
    primary_type=NuMu,
    final_state_particle_0=MuMinus,
    final_state_particle_1=Hadrons,
    energy=1e6,
    zenith=1.57
)
```

### Directory Structure
- `public/LeptonWeighter/`: Public C++ headers (API)
- `private/LeptonWeighter/`: C++ implementation files
- `private/pybindings/`: Python binding code (pybind11)
- `private/jlbindings/`: Julia binding code (CxxWrap.jl)
- `julia/LeptonWeighter/`: Julia package source
- `tools/binarybuilder/`: BinaryBuilder recipe for JLL package
- `resources/data/`: Cross-section spline FITS files
- `resources/example/`: Working examples (C++ and Python)

## Key Dependencies

**Required:** C++11 compiler, GSL (>=1.15), HDF5, Photospline v2

**Python bindings:** numpy, pybind11

**Julia bindings:** Julia (>=1.9), CxxWrap.jl (>=0.15)

**Optional:** nuSQuIDS (>=1.0, enables tau decay corrections and atmospheric flux), SQuIDS (>=1.2), nuflux

## Optional Feature Guards

nuSQuIDS features are compile-time guarded with `#ifdef NUS_FOUND`. When nuSQuIDS is available:
- `GlashowResonanceCrossSection` class
- `Weighter::get_effective_tau_weight()` and `get_effective_tau_oneweight()`
- `nuSQUIDSAtmFlux` and `nuSQUIDSFlux` classes (Python and Julia)

In Julia, use `LeptonWeighter.HAS_NUSQUIDS` to check availability at runtime.

## Version Management

Keep version in sync across: `configure` (VERSION variable), `pyproject.toml`, and `Makefile` (generated).
