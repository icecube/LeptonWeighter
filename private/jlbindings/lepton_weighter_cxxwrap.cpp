// LeptonWeighter Julia Bindings using CxxWrap.jl
// This file provides Julia bindings that mirror the Python (pybind11) API

#include <LeptonWeighter/Event.h>
#include <LeptonWeighter/ParticleType.h>
#include <LeptonWeighter/Weighter.h>

#ifdef NUS_FOUND
#include <LeptonWeighter/nuSQFluxInterface.h>
#endif

#include <jlcxx/jlcxx.hpp>
#include <jlcxx/stl.hpp>

// Tell CxxWrap these are NOT mirrored types (they are wrapped C++ types)
namespace jlcxx {
    template<> struct IsMirroredType<LW::Event> : std::false_type { };
    template<> struct IsMirroredType<LW::Flux> : std::false_type { };
    template<> struct IsMirroredType<LW::CrossSection> : std::false_type { };
    template<> struct IsMirroredType<LW::Generator> : std::false_type { };
    template<> struct IsMirroredType<LW::SimulationDetails> : std::false_type { };
}

// Declare inheritance relationships for CxxWrap
namespace jlcxx {
    // Flux hierarchy
    template<> struct SuperType<LW::ConstantFlux> { typedef LW::Flux type; };
    template<> struct SuperType<LW::PowerLawFlux> { typedef LW::Flux type; };
#ifdef NUS_FOUND
    template<> struct SuperType<LW::nuSQUIDSAtmFlux<>> { typedef LW::Flux type; };
    template<> struct SuperType<LW::nuSQUIDSFlux> { typedef LW::Flux type; };
#endif

    // CrossSection hierarchy
    template<> struct SuperType<LW::CrossSectionFromSpline> { typedef LW::CrossSection type; };
#ifdef NUS_FOUND
    template<> struct SuperType<LW::GlashowResonanceCrossSection> { typedef LW::CrossSection type; };
#endif

    // SimulationDetails hierarchy
    template<> struct SuperType<LW::RangeSimulationDetails> { typedef LW::SimulationDetails type; };
    template<> struct SuperType<LW::VolumeSimulationDetails> { typedef LW::SimulationDetails type; };

    // Generator hierarchy
    template<> struct SuperType<LW::RangeGenerator> { typedef LW::Generator type; };
    template<> struct SuperType<LW::VolumeGenerator> { typedef LW::Generator type; };
}

// Factory functions for Weighter (to handle multiple constructor overloads)
std::shared_ptr<LW::Weighter> create_weighter_single(
    std::shared_ptr<LW::Flux> flux,
    std::shared_ptr<LW::CrossSection> cs,
    std::shared_ptr<LW::Generator> g) {
    return std::make_shared<LW::Weighter>(flux, cs, g);
}

std::shared_ptr<LW::Weighter> create_weighter_single_flux_multi_gen(
    std::shared_ptr<LW::Flux> flux,
    std::shared_ptr<LW::CrossSection> cs,
    std::vector<std::shared_ptr<LW::Generator>> gv) {
    return std::make_shared<LW::Weighter>(flux, cs, gv);
}

std::shared_ptr<LW::Weighter> create_weighter_multi_flux_single_gen(
    std::vector<std::shared_ptr<LW::Flux>> fv,
    std::shared_ptr<LW::CrossSection> cs,
    std::shared_ptr<LW::Generator> g) {
    return std::make_shared<LW::Weighter>(fv, cs, g);
}

std::shared_ptr<LW::Weighter> create_weighter_multi(
    std::vector<std::shared_ptr<LW::Flux>> fv,
    std::shared_ptr<LW::CrossSection> cs,
    std::vector<std::shared_ptr<LW::Generator>> gv) {
    return std::make_shared<LW::Weighter>(fv, cs, gv);
}

std::shared_ptr<LW::Weighter> create_weighter_oneweight_multi(
    std::shared_ptr<LW::CrossSection> cs,
    std::vector<std::shared_ptr<LW::Generator>> gv) {
    return std::make_shared<LW::Weighter>(cs, gv);
}

std::shared_ptr<LW::Weighter> create_weighter_oneweight_single(
    std::shared_ptr<LW::CrossSection> cs,
    std::shared_ptr<LW::Generator> g) {
    return std::make_shared<LW::Weighter>(cs, g);
}

JLCXX_MODULE define_julia_module(jlcxx::Module& mod)
{
    //========================================================//
    // PARTICLE ENUM
    //========================================================//

    mod.add_bits<LW::ParticleType>("ParticleType", jlcxx::julia_type("CppEnum"));
    mod.set_const("NuE", LW::ParticleType::NuE);
    mod.set_const("NuMu", LW::ParticleType::NuMu);
    mod.set_const("NuTau", LW::ParticleType::NuTau);
    mod.set_const("NuEBar", LW::ParticleType::NuEBar);
    mod.set_const("NuMuBar", LW::ParticleType::NuMuBar);
    mod.set_const("NuTauBar", LW::ParticleType::NuTauBar);
    mod.set_const("EMinus", LW::ParticleType::EMinus);
    mod.set_const("EPlus", LW::ParticleType::EPlus);
    mod.set_const("MuMinus", LW::ParticleType::MuMinus);
    mod.set_const("MuPlus", LW::ParticleType::MuPlus);
    mod.set_const("TauMinus", LW::ParticleType::TauMinus);
    mod.set_const("TauPlus", LW::ParticleType::TauPlus);
    mod.set_const("unknown", LW::ParticleType::unknown);
    mod.set_const("Hadrons", LW::ParticleType::Hadrons);

    //========================================================//
    // EVENT
    //========================================================//

    mod.add_type<LW::Event>("Event")
        .constructor<>();

    // Event property accessors - using module-level methods since TypeWrapper doesn't support free functions
    mod.method("primary_type", [](LW::Event& e) { return e.primary_type; });
    mod.method("primary_type!", [](LW::Event& e, LW::ParticleType pt) { e.primary_type = pt; });
    mod.method("final_state_particle_0", [](LW::Event& e) { return e.final_state_particle_0; });
    mod.method("final_state_particle_0!", [](LW::Event& e, LW::ParticleType pt) { e.final_state_particle_0 = pt; });
    mod.method("final_state_particle_1", [](LW::Event& e) { return e.final_state_particle_1; });
    mod.method("final_state_particle_1!", [](LW::Event& e, LW::ParticleType pt) { e.final_state_particle_1 = pt; });
    mod.method("interaction_x", [](LW::Event& e) { return e.interaction_x; });
    mod.method("interaction_x!", [](LW::Event& e, double v) { e.interaction_x = v; });
    mod.method("interaction_y", [](LW::Event& e) { return e.interaction_y; });
    mod.method("interaction_y!", [](LW::Event& e, double v) { e.interaction_y = v; });
    mod.method("energy", [](LW::Event& e) { return e.energy; });
    mod.method("energy!", [](LW::Event& e, double v) { e.energy = v; });
    mod.method("azimuth", [](LW::Event& e) { return e.azimuth; });
    mod.method("azimuth!", [](LW::Event& e, double v) { e.azimuth = v; });
    mod.method("zenith", [](LW::Event& e) { return e.zenith; });
    mod.method("zenith!", [](LW::Event& e, double v) { e.zenith = v; });
    mod.method("x", [](LW::Event& e) { return e.x; });
    mod.method("x!", [](LW::Event& e, double v) { e.x = v; });
    mod.method("y", [](LW::Event& e) { return e.y; });
    mod.method("y!", [](LW::Event& e, double v) { e.y = v; });
    mod.method("z", [](LW::Event& e) { return e.z; });
    mod.method("z!", [](LW::Event& e, double v) { e.z = v; });
    mod.method("radius", [](LW::Event& e) { return e.radius; });
    mod.method("radius!", [](LW::Event& e, double v) { e.radius = v; });
    mod.method("total_column_depth", [](LW::Event& e) { return e.total_column_depth; });
    mod.method("total_column_depth!", [](LW::Event& e, double v) { e.total_column_depth = v; });

    //========================================================//
    // SIMULATION DETAILS
    //========================================================//

    mod.add_type<LW::SimulationDetails>("SimulationDetails")
        .method("numberOfEvents", &LW::SimulationDetails::Get_NumberOfEvents)
        .method("year", &LW::SimulationDetails::Get_Year)
        .method("final_state_particle_0", &LW::SimulationDetails::Get_ParticleType0)
        .method("final_state_particle_1", &LW::SimulationDetails::Get_ParticleType1)
        .method("azimuthMin", &LW::SimulationDetails::Get_MinAzimuth)
        .method("azimuthMax", &LW::SimulationDetails::Get_MaxAzimuth)
        .method("zenithMin", &LW::SimulationDetails::Get_MinZenith)
        .method("zenithMax", &LW::SimulationDetails::Get_MaxZenith)
        .method("energyMin", &LW::SimulationDetails::Get_MinEnergy)
        .method("energyMax", &LW::SimulationDetails::Get_MaxEnergy)
        .method("powerlawIndex", &LW::SimulationDetails::Get_PowerLawIndex);

    mod.add_type<LW::RangeSimulationDetails>("RangeSimulationDetails", jlcxx::julia_base_type<LW::SimulationDetails>())
        .constructor<const std::string&>()
        .method("injectionRadius", &LW::RangeSimulationDetails::Get_InjectionRadius)
        .method("injectionCap", &LW::RangeSimulationDetails::Get_InjectionCap);

    mod.add_type<LW::VolumeSimulationDetails>("VolumeSimulationDetails", jlcxx::julia_base_type<LW::SimulationDetails>())
        .constructor<const std::string&>()
        .method("cylinderRadius", &LW::VolumeSimulationDetails::Get_CylinderRadius)
        .method("cylinderHeight", &LW::VolumeSimulationDetails::Get_CylinderHeight);

    //========================================================//
    // GENERATORS
    //========================================================//

    mod.add_type<LW::Generator>("Generator")
        .method("probability", &LW::Generator::probability);

    mod.add_type<LW::RangeGenerator>("RangeGenerator", jlcxx::julia_base_type<LW::Generator>())
        .constructor<LW::RangeSimulationDetails>()
        .method("simulation_details", &LW::RangeGenerator::GetSimulationDetails);

    mod.add_type<LW::VolumeGenerator>("VolumeGenerator", jlcxx::julia_base_type<LW::Generator>())
        .constructor<LW::VolumeSimulationDetails>()
        .method("simulation_details", &LW::VolumeGenerator::GetVolumeSimulationDetails);

    // Factory function for generators from LIC file
    mod.method("MakeGeneratorsFromLICFile", &LW::MakeGeneratorsFromLICFile);

    //========================================================//
    // FLUX
    //========================================================//

    mod.add_type<LW::Flux>("Flux")
        .method("evaluate", &LW::Flux::EvaluateFlux);

    mod.add_type<LW::ConstantFlux>("ConstantFlux", jlcxx::julia_base_type<LW::Flux>())
        .constructor<double>();

    mod.add_type<LW::PowerLawFlux>("PowerLawFlux", jlcxx::julia_base_type<LW::Flux>())
        .constructor<double, double, double>();

#ifdef NUS_FOUND
    mod.add_type<LW::nuSQUIDSAtmFlux<>>("nuSQUIDSAtmFlux", jlcxx::julia_base_type<LW::Flux>())
        .constructor<std::string>();

    mod.add_type<LW::nuSQUIDSFlux>("nuSQUIDSFlux", jlcxx::julia_base_type<LW::Flux>())
        .constructor<std::string>();
#endif

    //========================================================//
    // CROSS SECTION
    //========================================================//

    mod.add_type<LW::CrossSection>("CrossSection")
        .method("DoubleDifferentialCrossSection", &LW::CrossSection::DoubleDifferentialCrossSection);

    mod.add_type<LW::CrossSectionFromSpline>("CrossSectionFromSpline", jlcxx::julia_base_type<LW::CrossSection>())
        .constructor<std::string, std::string, std::string, std::string>();

#ifdef NUS_FOUND
    mod.add_type<LW::GlashowResonanceCrossSection>("GlashowResonanceCrossSection", jlcxx::julia_base_type<LW::CrossSection>())
        .constructor<>();
#endif

    //========================================================//
    // WEIGHTER
    //========================================================//

    mod.add_type<LW::Weighter>("Weighter")
        .method("weight", &LW::Weighter::weight)
        .method("get_oneweight", &LW::Weighter::get_oneweight)
        .method("get_total_flux", &LW::Weighter::get_total_flux)
        .method("add_flux", &LW::Weighter::add_flux)
        .method("add_generator", &LW::Weighter::add_generator)
#ifdef NUS_FOUND
        .method("get_effective_tau_weight", &LW::Weighter::get_effective_tau_weight)
        .method("get_effective_tau_oneweight", &LW::Weighter::get_effective_tau_oneweight)
#endif
        ;

    // Factory functions for different constructor overloads
    mod.method("create_weighter", &create_weighter_single);
    mod.method("create_weighter", &create_weighter_single_flux_multi_gen);
    mod.method("create_weighter", &create_weighter_multi_flux_single_gen);
    mod.method("create_weighter", &create_weighter_multi);
    mod.method("create_weighter", &create_weighter_oneweight_multi);
    mod.method("create_weighter", &create_weighter_oneweight_single);

    //========================================================//
    // FEATURE DETECTION
    //========================================================//

#ifdef NUS_FOUND
    mod.set_const("HAS_NUSQUIDS", true);
#else
    mod.set_const("HAS_NUSQUIDS", false);
#endif
}
