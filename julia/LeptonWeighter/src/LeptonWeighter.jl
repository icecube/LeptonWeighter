"""
    LeptonWeighter

Julia bindings for the LeptonWeighter C++ library, which weights simulated neutrino
events from LeptonInjector simulations to physical neutrino fluxes.

# Basic Usage
```julia
using LeptonWeighter

# Create a flux model
flux = PowerLawFlux(1e-18, -2.0, 1e5)

# Load cross sections from spline files
xs = CrossSectionFromSpline(cc_nu, cc_nubar, nc_nu, nc_nubar)

# Load generators from LIC file
generators = make_generators_from_lic_file("config.lic")

# Create weighter
weighter = create_weighter(flux, xs, generators)

# Weight an event
event = Event()
event.energy = 1e5
weight = weighter(event)  # Returns Hz
```
"""
module LeptonWeighter

using CxxWrap

# Find the library path
function find_library()
    # Check environment variable first
    env_path = get(ENV, "LEPTONWEIGHTER_JL_LIB", nothing)
    if env_path !== nothing && isfile(env_path)
        return env_path
    end

    # Try common installation locations
    possible_paths = [
        joinpath(@__DIR__, "..", "..", "..", "lib", "libLeptonWeighterJL.dylib"),
        joinpath(@__DIR__, "..", "..", "..", "lib", "libLeptonWeighterJL.so"),
        "/usr/local/lib/libLeptonWeighterJL.dylib",
        "/usr/local/lib/libLeptonWeighterJL.so",
    ]

    for p in possible_paths
        if isfile(p)
            return p
        end
    end

    error("""
    Could not find LeptonWeighter Julia library. Options:
    1. Set LEPTONWEIGHTER_JL_LIB environment variable to the library path
    2. Build with 'make julia' and ensure library is in lib/
    """)
end

const _libpath = find_library()
@wrapmodule(() -> _libpath)

function __init__()
    @initcxx
end

# Include additional Julia code
include("types.jl")
include("convenience.jl")

# Export particle types
export ParticleType
export NuE, NuMu, NuTau, NuEBar, NuMuBar, NuTauBar
export EMinus, EPlus, MuMinus, MuPlus, TauMinus, TauPlus
export unknown, Hadrons

# Export main types
export Event
export Flux, ConstantFlux, PowerLawFlux
export CrossSection, CrossSectionFromSpline
export SimulationDetails, RangeSimulationDetails, VolumeSimulationDetails
export Generator, RangeGenerator, VolumeGenerator
export Weighter

# Export factory functions
export create_weighter, make_generators_from_lic_file, create_event

# Export convenience functions
export weight, evaluate_flux, probability, evaluate

# Export Event accessor functions
export energy, energy!, zenith, zenith!, azimuth, azimuth!
export interaction_x, interaction_x!, interaction_y, interaction_y!
export primary_type, primary_type!
export final_state_particle_0, final_state_particle_0!
export final_state_particle_1, final_state_particle_1!
export x, x!, y, y!, z, z!, radius, radius!
export total_column_depth, total_column_depth!

# Export feature detection
export HAS_NUSQUIDS

# Conditional exports for nuSQuIDS features
if @isdefined(nuSQUIDSAtmFlux)
    export nuSQUIDSAtmFlux, nuSQUIDSFlux
    export GlashowResonanceCrossSection
    export get_effective_tau_weight, get_effective_tau_oneweight
end

end # module
