using Test
using LeptonWeighter

@testset "LeptonWeighter.jl" begin

    @testset "ParticleType enum" begin
        # Test that particle types are defined
        @test NuE isa ParticleType
        @test NuMu isa ParticleType
        @test NuTau isa ParticleType
        @test NuEBar isa ParticleType
        @test NuMuBar isa ParticleType
        @test NuTauBar isa ParticleType
        @test EMinus isa ParticleType
        @test EPlus isa ParticleType
        @test MuMinus isa ParticleType
        @test MuPlus isa ParticleType
        @test TauMinus isa ParticleType
        @test TauPlus isa ParticleType
        @test unknown isa ParticleType
        @test Hadrons isa ParticleType
    end

    @testset "Event creation and access" begin
        # Test default constructor
        e = Event()
        @test e isa Event

        # Test property setters
        e.primary_type = NuMu
        e.final_state_particle_0 = MuMinus
        e.final_state_particle_1 = Hadrons
        e.energy = 1e6
        e.zenith = 1.57
        e.azimuth = 0.5
        e.interaction_x = 0.3
        e.interaction_y = 0.5
        e.x = 0.0
        e.y = 0.0
        e.z = -500.0
        e.radius = 100.0
        e.total_column_depth = 1e4

        # Test property getters
        @test e.primary_type == NuMu
        @test e.final_state_particle_0 == MuMinus
        @test e.final_state_particle_1 == Hadrons
        @test e.energy == 1e6
        @test e.zenith == 1.57
        @test e.azimuth == 0.5
        @test e.interaction_x == 0.3
        @test e.interaction_y == 0.5
        @test e.x == 0.0
        @test e.y == 0.0
        @test e.z == -500.0
        @test e.radius == 100.0
        @test e.total_column_depth == 1e4

        # Test keyword constructor
        e2 = Event(
            primary_type=NuE,
            final_state_particle_0=EMinus,
            final_state_particle_1=Hadrons,
            energy=1e5,
            zenith=1.0
        )
        @test e2.primary_type == NuE
        @test e2.energy == 1e5
        @test e2.zenith == 1.0
    end

    @testset "ConstantFlux" begin
        flux = ConstantFlux(1.0)
        @test flux isa Flux
        @test flux isa ConstantFlux

        e = Event()
        e.energy = 1e5
        @test flux(e) == 1.0
    end

    @testset "PowerLawFlux" begin
        # Test positional constructor
        flux1 = PowerLawFlux(1e-18, -2.0, 1e5)
        @test flux1 isa Flux
        @test flux1 isa PowerLawFlux

        # Test keyword constructor
        flux2 = PowerLawFlux(1e-18, -2.0; pivot=1e5)
        @test flux2 isa PowerLawFlux

        # Test flux evaluation
        e = Event()
        e.energy = 1e5  # At pivot energy
        val = flux1(e)
        @test val ≈ 1e-18  # At pivot, should equal normalization

        # Test energy dependence
        e.energy = 1e6  # 10x pivot
        val2 = flux1(e)
        @test val2 ≈ 1e-18 * (1e6/1e5)^(-2.0)  # Should be 1e-20
    end

    @testset "Feature detection" begin
        @test HAS_NUSQUIDS isa Bool
    end

    @testset "CrossSectionFromSpline construction" begin
        # We can't test full functionality without actual spline files,
        # but we can test that the type exists
        @test CrossSectionFromSpline <: CrossSection
    end

    @testset "Generator types" begin
        @test RangeGenerator <: Generator
        @test VolumeGenerator <: Generator
    end

    @testset "Weighter type" begin
        @test Weighter <: Any
        # create_weighter function should exist
        @test isdefined(LeptonWeighter, :create_weighter)
    end

    @testset "Pretty printing" begin
        e = Event(
            primary_type=NuMu,
            final_state_particle_0=MuMinus,
            final_state_particle_1=Hadrons,
            energy=1e6
        )

        # Test that show methods don't error
        io = IOBuffer()
        show(io, MIME"text/plain"(), e)
        str = String(take!(io))
        @test contains(str, "Event")
        @test contains(str, "Energy")
    end

    # Conditional tests for nuSQuIDS features
    if HAS_NUSQUIDS
        @testset "nuSQuIDS features" begin
            @test GlashowResonanceCrossSection <: CrossSection
            @test nuSQUIDSAtmFlux <: Flux
            @test nuSQUIDSFlux <: Flux
        end
    end

end
