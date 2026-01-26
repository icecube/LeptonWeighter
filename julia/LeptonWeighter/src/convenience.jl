# Convenience functions and pretty printing for LeptonWeighter

# Keyword argument wrapper for PowerLawFlux
"""
    PowerLawFlux(normalization, spectral_index; pivot=1e5)

Create a power-law flux model: normalization * (E/pivot)^spectral_index

# Arguments
- `normalization`: Flux normalization (e.g., 1e-18 for atmospheric neutrinos)
- `spectral_index`: Power law index (typically negative, e.g., -2.0)
- `pivot`: Pivot energy in GeV (default: 1e5 = 100 TeV)

# Example
```julia
flux = PowerLawFlux(1e-18, -2.0; pivot=1e5)
```
"""
function PowerLawFlux(normalization::Real, spectral_index::Real; pivot::Real=1e5)
    PowerLawFlux(Float64(normalization), Float64(spectral_index), Float64(pivot))
end

# Alias for MakeGeneratorsFromLICFile with Julia naming convention
"""
    make_generators_from_lic_file(path::String)

Load generators from a LeptonInjector configuration file (.lic format).

Returns a vector of `Generator` objects that can be used with `create_weighter`.

# Example
```julia
generators = make_generators_from_lic_file("simulation.lic")
```
"""
make_generators_from_lic_file(path::String) = MakeGeneratorsFromLICFile(path)

# Pretty printing

function Base.show(io::IO, ::MIME"text/plain", e::Event)
    println(io, "LeptonWeighter.Event:")
    println(io, "  Primary type: ", e.primary_type)
    println(io, "  Final state particles: ", e.final_state_particle_0, ", ", e.final_state_particle_1)
    println(io, "  Energy: ", e.energy, " GeV")
    println(io, "  Direction: zenith=", e.zenith, " rad, azimuth=", e.azimuth, " rad")
    println(io, "  Vertex: (", e.x, ", ", e.y, ", ", e.z, ") m")
    println(io, "  Bjorken: x=", e.interaction_x, ", y=", e.interaction_y)
    println(io, "  Radius: ", e.radius, " m")
    print(io, "  Column depth: ", e.total_column_depth, " g/cm^2")
end

function Base.show(io::IO, flux::ConstantFlux)
    print(io, "ConstantFlux()")
end

function Base.show(io::IO, flux::PowerLawFlux)
    print(io, "PowerLawFlux()")
end

function Base.show(io::IO, w::Weighter)
    print(io, "Weighter()")
end

function Base.show(io::IO, g::RangeGenerator)
    print(io, "RangeGenerator()")
end

function Base.show(io::IO, g::VolumeGenerator)
    print(io, "VolumeGenerator()")
end

function Base.show(io::IO, xs::CrossSectionFromSpline)
    print(io, "CrossSectionFromSpline()")
end

function Base.show(io::IO, ::MIME"text/plain", sd::RangeSimulationDetails)
    println(io, "RangeSimulationDetails:")
    println(io, "  Number of events: ", numberOfEvents(sd))
    println(io, "  Energy range: [", energyMin(sd), ", ", energyMax(sd), "] GeV")
    println(io, "  Zenith range: [", zenithMin(sd), ", ", zenithMax(sd), "] rad")
    println(io, "  Azimuth range: [", azimuthMin(sd), ", ", azimuthMax(sd), "] rad")
    println(io, "  Power law index: ", powerlawIndex(sd))
    println(io, "  Injection radius: ", injectionRadius(sd), " m")
    print(io, "  Injection cap: ", injectionCap(sd), " m")
end

function Base.show(io::IO, ::MIME"text/plain", sd::VolumeSimulationDetails)
    println(io, "VolumeSimulationDetails:")
    println(io, "  Number of events: ", numberOfEvents(sd))
    println(io, "  Energy range: [", energyMin(sd), ", ", energyMax(sd), "] GeV")
    println(io, "  Zenith range: [", zenithMin(sd), ", ", zenithMax(sd), "] rad")
    println(io, "  Azimuth range: [", azimuthMin(sd), ", ", azimuthMax(sd), "] rad")
    println(io, "  Power law index: ", powerlawIndex(sd))
    println(io, "  Cylinder radius: ", cylinderRadius(sd), " m")
    print(io, "  Cylinder height: ", cylinderHeight(sd), " m")
end

# Helper function to create a fully populated Event
"""
    create_event(;
        primary_type=unknown,
        final_state_particle_0=unknown,
        final_state_particle_1=unknown,
        energy=0.0,
        zenith=0.0,
        azimuth=0.0,
        interaction_x=0.0,
        interaction_y=0.0,
        x=0.0, y=0.0, z=0.0,
        radius=0.0,
        total_column_depth=0.0
    )

Create an Event with the specified properties.

# Example
```julia
event = create_event(
    primary_type=NuMu,
    final_state_particle_0=MuMinus,
    final_state_particle_1=Hadrons,
    energy=1e6,
    zenith=1.57,
    interaction_x=0.3,
    interaction_y=0.5
)
```
"""
function create_event(;
    primary_type=nothing,
    final_state_particle_0=nothing,
    final_state_particle_1=nothing,
    energy=0.0,
    zenith=0.0,
    azimuth=0.0,
    interaction_x=0.0,
    interaction_y=0.0,
    x=0.0, y=0.0, z=0.0,
    radius=0.0,
    total_column_depth=0.0
)
    e = Event()
    if primary_type !== nothing
        primary_type!(e, primary_type)
    end
    if final_state_particle_0 !== nothing
        final_state_particle_0!(e, final_state_particle_0)
    end
    if final_state_particle_1 !== nothing
        final_state_particle_1!(e, final_state_particle_1)
    end
    energy!(e, energy)
    zenith!(e, zenith)
    azimuth!(e, azimuth)
    interaction_x!(e, interaction_x)
    interaction_y!(e, interaction_y)
    x!(e, x)
    y!(e, y)
    z!(e, z)
    radius!(e, radius)
    total_column_depth!(e, total_column_depth)
    return e
end
