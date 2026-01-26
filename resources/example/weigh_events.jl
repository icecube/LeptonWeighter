#!/usr/bin/env julia
"""
weigh_events.jl - Basic LeptonWeighter Example with Power-Law Flux (Julia)

This calculates the weight of each event using a simple power-law flux model.
Can be run directly with default parameters or customized via command-line arguments.
Does not require nuSQuIDS.

Usage:
    julia weigh_events.jl                    # Use defaults
    julia weigh_events.jl --help             # Show all options
    julia weigh_events.jl --lic config.lic   # Specify LIC file

Requires:
    - LeptonWeighter Julia package
    - HDF5.jl package

Author: Adapted from Python version by Ben Smithers
"""

using LeptonWeighter
using HDF5
using Printf
using ArgParse

# Get the directory where this script is located
const SCRIPT_DIR = @__DIR__
const DATA_DIR = joinpath(SCRIPT_DIR, "..", "data")

function parse_commandline()
    s = ArgParseSettings(description="LeptonWeighter example with power-law flux (Julia)")

    @add_arg_table! s begin
        "--lic"
            help = "Path to LeptonInjector configuration file"
            default = joinpath(SCRIPT_DIR, "config.lic")
        "--events"
            help = "Path to HDF5 file with events"
            default = joinpath(SCRIPT_DIR, "data_output.h5")
        "--xs-nu-cc"
            help = "Neutrino CC differential cross section spline"
            default = joinpath(DATA_DIR, "dsdxdy-numu-N-cc-HERAPDF15NLO_EIG_central.fits")
        "--xs-nubar-cc"
            help = "Antineutrino CC differential cross section spline"
            default = joinpath(DATA_DIR, "dsdxdy-numubar-N-cc-HERAPDF15NLO_EIG_central.fits")
        "--xs-nu-nc"
            help = "Neutrino NC differential cross section spline"
            default = joinpath(DATA_DIR, "dsdxdy-numu-N-nc-HERAPDF15NLO_EIG_central.fits")
        "--xs-nubar-nc"
            help = "Antineutrino NC differential cross section spline"
            default = joinpath(DATA_DIR, "dsdxdy-numubar-N-nc-HERAPDF15NLO_EIG_central.fits")
        "--flux-norm"
            help = "Flux normalization (GeV^-1 cm^-2 sr^-1 s^-1)"
            arg_type = Float64
            default = 1e-18
        "--flux-index"
            help = "Spectral index (negative for falling spectrum)"
            arg_type = Float64
            default = -2.0
        "--flux-pivot"
            help = "Pivot energy (GeV)"
            arg_type = Float64
            default = 1e5
        "--livetime"
            help = "Livetime in seconds (default: 1 year)"
            arg_type = Float64
            default = 3.1536e7
    end

    return parse_args(s)
end

"""
    get_weight(weighter, props, livetime)

Accepts the properties array of an event and returns the weight.

To convert this to one working with i3-LeptonInjector, you will need
to modify the event loop and this function.
"""
function get_weight(weighter, props, livetime)
    event = Event()
    event.energy = props[1]
    event.zenith = props[2]
    event.azimuth = props[3]
    event.interaction_x = props[4]
    event.interaction_y = props[5]
    # Note: ParticleType conversion from Int would need to be handled
    # For now, assume props contains appropriate particle type codes
    # event.final_state_particle_0 = ParticleType(Int(props[6]))
    # event.final_state_particle_1 = ParticleType(Int(props[7]))
    # event.primary_type = ParticleType(Int(props[8]))
    event.radius = props[10]
    event.total_column_depth = props[11]
    event.x = 0.0
    event.y = 0.0
    event.z = 0.0

    weight = weighter(event)

    if isnan(weight)
        error("Bad Weight!")
    end

    return weight * livetime
end

function main()
    args = parse_commandline()

    println("LeptonWeighter Power-Law Flux Example (Julia)")
    println("=" ^ 40)
    println("LIC file: $(args["lic"])")
    println("Events file: $(args["events"])")
    @printf("Flux: %.2e * (E/%.0e GeV)^%.1f\n",
            args["flux-norm"], args["flux-pivot"], args["flux-index"])
    @printf("Livetime: %.2e s\n", args["livetime"])
    println()

    # Create generator from LIC file
    net_generation = make_generators_from_lic_file(args["lic"])
    println("Loaded $(length(net_generation)) generator(s) from LIC file")

    # Load cross sections
    xs = CrossSectionFromSpline(
        args["xs-nu-cc"],
        args["xs-nubar-cc"],
        args["xs-nu-nc"],
        args["xs-nubar-nc"]
    )

    # Create flux model (using keyword argument syntax)
    flux = PowerLawFlux(args["flux-norm"], args["flux-index"]; pivot=args["flux-pivot"])

    # Build weighter
    weighter = create_weighter(flux, xs, net_generation)

    # Load data and weight events
    println()
    println("Event Weights (rate * livetime):")
    println("-" ^ 40)

    h5open(args["events"], "r") do data_file
        total_events = 0
        for injector in keys(data_file)
            events = read(data_file[injector]["properties"])
            for event_idx in axes(events, 1)
                weight = get_weight(weighter, events[event_idx, :], args["livetime"])
                @printf("Event %d: %.6e\n", total_events, weight)
                total_events += 1
            end
        end
        println()
        println("Processed $total_events events")
    end
end

# Run main if this is the main script
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
