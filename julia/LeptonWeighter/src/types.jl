# Type extensions for LeptonWeighter types
# Note: Due to Julia 1.12 world age restrictions, we avoid redefining methods
# on CxxWrap-generated types during module precompilation.

# Property-style access for Event using getproperty/setproperty!
# This allows event.energy instead of energy(event)

const EVENT_FIELDS = (
    :primary_type, :final_state_particle_0, :final_state_particle_1,
    :interaction_x, :interaction_y, :energy, :azimuth, :zenith,
    :x, :y, :z, :radius, :total_column_depth
)

# Note: We don't override getproperty/setproperty! for CxxWrap types
# as it interferes with CxxWrap's internal cpp_object handling.
# Use the accessor functions directly instead:
#   energy(event)       # get
#   energy!(event, val) # set

# Alias for convenience
"""
    evaluate_flux(flux, event)

Evaluate the flux at the given event.
"""
evaluate_flux(flux, event) = evaluate(flux, event)
